# ZFS Operator Guide

Reference for managing ZFS on the hosts in this repository (currently
`orca`). Covers the mental model, this repo's actual pool layout, and the
two restoration procedures: single file/directory and full dataset.

Source of truth for the disk layout is `nixos/server/orca/disks.nix`
(disko). If this doc and disko disagree, disko wins — update this doc.

## Mental model

ZFS combines volume management, RAID, and a filesystem in one layer. The
hierarchy from top to bottom:

- **Pool** — the top-level object (`zroot`). One pool = one storage
  namespace with its own datasets and snapshots. Pools are imported by
  name at boot (`zpool import zroot`).
- **vdev** — a virtual device inside a pool. A vdev is a disk, a mirror
  of disks, or a RAIDZ group. The pool's data is striped across its
  vdevs. **Pool redundancy lives at the vdev level**: a pool of five
  single-disk vdevs loses the pool when any one disk dies; a pool of one
  raidz2 vdev tolerates two disk failures.
- **RAIDZ levels** — `raidz1` tolerates one failure per vdev, `raidz2`
  two, `raidz3` three. RAIDZ is wide-striping: parity is distributed,
  and blocks are spread across all member disks. Unlike mdadm RAID,
  there is no "spare disk" that maps 1:1 to a failed one — all disks
  participate in all data.
- **cache vdev (L2ARC)** — a read cache layered in front of the pool.
  Purely an optimization; losing it loses no data. On orca the SSD is
  the L2ARC for the HDD pool, so hot reads avoid spinning rust.
- **Dataset** (`zfs_fs`) — a filesystem inside the pool, named by its
  path from the pool root (`zroot/var`). Each dataset has its own
  mountpoint, properties, and snapshot namespace. Datasets are the unit
  of administration: snapshotting, compression, and recordsize are all
  per-dataset. A dataset is not a directory — but it *has* a directory
  where it is mounted.
- **Properties** — per-dataset (or inherited from parent) settings:
  `compression`, `mountpoint`, and the `com.sun:auto-snapshot*` flags
  that drive snapshot scheduling.
- **Snapshot** — a point-in-time, read-only, space-efficient copy of a
  *whole dataset*. Named `pool/dataset@label`. Snapshots hold the old
  blocks alive when files change; deleted data only frees space when
  the snapshot referencing it is destroyed. **Snapshots are per
  dataset, never per file** — restoring a single file means restoring
  from a dataset snapshot, selectively.
- **Clone** — a writable filesystem initialized from a snapshot. Cheap
  (copy-on-write). Useful to explore or restore from a snapshot without
  touching the live dataset.
- **send/receive** — dataset-level stream between pools or hosts
  (`zfs send pool/ds@snap | zfs recv pool/copy`). Used for backups and
  migration.

Everything is copy-on-write: writes never overwrite blocks in place,
which is why snapshots are free to create and rollback is fast.

## Orca layout

Defined in `nixos/server/orca/disks.nix`:

| Layer | Value |
| --- | --- |
| Pool | `zroot`, ashift=12, autotrim=on |
| Data vdev | raidz2 across 5x WD Red 1TB (`data-0` … `data-4`) — tolerates 2 disk failures |
| Cache vdev | Corsair 256G SSD (L2ARC read cache) |
| Pool options | compression=zstd, acltype=posixacl, xattr=sa, dnodesize=auto |

Datasets and snapshot policy (also disko-managed):

| Dataset | Mountpoint | Snapshots |
| --- | --- | --- |
| `zroot/etc` | `/etc` | daily, keep 91 |
| `zroot/home` | `/home` | weekly, keep 13 |
| `zroot/nix` | `/nix` | none |
| `zroot/var` | `/var` | hourly, keep 2184 (~3 months) |

Note: `nixos/server/orca/default.nix` sets `services.zfs.autoSnapshot` to
`frequent=0 hourly=0 daily=60 weekly=0`, which appears to conflict with
the dataset-level `com.sun:auto-snapshot:*` properties above. zfs-auto-
snapshot honors the per-dataset properties when set, but if you find
snapshots missing or unexpected, reconcile these two places — and trust
`zfs list -t snapshot` over either config file for ground truth.

ZFS datasets mentioned elsewhere in host configs (e.g. `zroot/media-*`
for media) are created out of band, not by disko.

## Daily operator commands

```bash
zpool status -v          # pool health, degraded/failed vdevs, scrub state
zpool list               # capacity per pool
zfs list -o name,used,available,mountpoint   # datasets + space
zfs list -t snapshot -r zroot/var           # snapshots of one dataset (and children)
zfs get com.sun:auto-snapshot zroot/var     # effective snapshot policy
```

Rules of thumb:

- Keep pool capacity below ~80%; RAIDZ rewrite/scrub performance degrades
  badly when close to full.
- Watch `zpool status` for `CKSUM` (repairable corruption) and `DEGRADED`
  columns. Non-zero CKSUM on healthy disks can indicate cable/controller
  problems.
- Scrubs are the only way ZFS detects and repairs silent corruption.
  Verify a scrub schedule exists (`systemd list-timers | grep zfs`).

## Restore: single file or directory

Every dataset exposes its snapshots as a hidden directory:

```
<mountpoint>/.zfs/snapshot/<label>/
```

`snapdir=hidden` (the default) keeps it out of `ls` output, but root can
still traverse it by exact name. This makes file-level restore a plain
copy — no clone, no send/receive.

Snapshot labels come from zfs-auto-snapshot, e.g.
`zfs-auto-snap:hourly-2026-10-18-1700` (note the colon — quote it in
shells if needed).

Find the snapshot you want:

```bash
zfs list -t snapshot -r zroot/var
```

Restore a directory (e.g. TREK's SQLite data):

```bash
sudo systemctl stop docker-trek.service      # stop whatever writes the data
sudo rsync -a --delete \
  /var/.zfs/snapshot/zfs-auto-snap:hourly-2026-10-18-1700/lib/trek/data/ \
  /var/lib/trek/data/
sudo systemctl start docker-trek.service
```

Restore a single file the same way — it is just a path under the
snapshot directory:

```bash
sudo cp /var/.zfs/snapshot/<label>/lib/trek/data/db.sqlite /var/lib/trek/data/
```

Caveats:

- **Stop the owning service first when the data is a database.** A
  snapshot of a live SQLite database is crash-consistent (SQLite
  recovers from its WAL on open), but copying a file *over* a database
  the application currently has open risks corruption.
- `rsync --delete` makes the destination exactly match the snapshot —
  anything created after the snapshot is removed. Drop `--delete` to
  only overlay older files.

## Restore: full dataset

Two approaches depending on whether you want to discard everything since
the snapshot.

### zfs rollback — revert the dataset to the snapshot

```bash
sudo zfs rollback zroot/var@zfs-auto-snap:hourly-2026-10-18-1700
```

Fast, but **destroys every change on the whole dataset since the
snapshot** — for `zroot/var` that is *all* services' state under `/var`
(docker volumes, Home Assistant, everything), not just the one you
cared about. The dataset must be unmounted (or use `-r` to destroy
newer snapshots, which is required when intermediate snapshots exist).
Only use this when you truly want the entire dataset back at that point
in time.

### clone + copy — restore without collateral damage

Clone the snapshot to a temporary mountpoint, copy what you need, then
destroy the clone:

```bash
sudo zfs clone -o mountpoint=/tmp/var-restore \
  zroot/var@zfs-auto-snap:hourly-2026-10-18-1700 zroot/var-restore

sudo rsync -a --delete /tmp/var-restore/lib/trek/data/ /var/lib/trek/data/

sudo zfs destroy zroot/var-restore
```

This is the dataset-scale version of the `.zfs/snapshot` trick: useful
when you want to browse the snapshot interactively or restore many
paths. For single files, the hidden snapshot directory is simpler.

### send/receive — restore to a new dataset

```bash
sudo zfs send zroot/var@zfs-auto-snap:hourly-2026-10-18-1700 \
  | sudo zfs recv zroot/var-restored
```

Good for keeping both versions around side by side. Heavier than a
clone (copies blocks instead of referencing them).

## Quick decision guide

| Situation | Use |
| --- | --- |
| One file or one service's directory back | `.zfs/snapshot` path + `rsync`/`cp` |
| Browse snapshot interactively | clone to `/tmp` mountpoint |
| Entire dataset to an earlier point, discard later changes | `zfs rollback` (understand the blast radius first) |
| Preserve both current and old versions as datasets | `zfs send | zfs recv` |
