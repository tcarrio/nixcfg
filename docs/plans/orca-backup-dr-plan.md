# Orca Backup & DR Plan

Status: **planned — not started** (2026-10-25)
Owner context: this file is the complete handoff. A fresh agent with an empty
context should be able to implement this plan from this document plus the
repository pointers inside it, without any conversation history.

---

## 1. Problem statement

Orca (`nixos/server/orca/`) runs stateful services (Dawarich, OxiCloud, TREK,
Jellyfin/Pinchflat, Home Assistant, PostgreSQL) on a single ZFS pool. Current
protection:

- `zroot` pool: raidz2 across 5x 1TB WD Red (tolerates 2 disk failures) +
  L2ARC SSD. No off-host copy of anything.
- `services.zfs.autoSnapshot` in `nixos/server/orca/default.nix`
  (`frequent=0 hourly=0 daily=60 weekly=0`), which partially conflicts with
  per-dataset `com.sun:auto-snapshot*` properties set by disko (see
  `docs/zfs-user-guide.md` for the known conflict).
- Snapshots are coarse: everything lives on the monolithic `zroot/var`
  dataset. Rolling back one service means rolling back all of `/var`.
- PostgreSQL has no scheduled dumps. The only copies of `dawarich` /
  `oxicloud` databases are crash-consistent ZFS snapshots.
- Nothing leaves the host. A pool-level failure (dual-disk loss, site loss,
  accidental `zfs destroy`) loses all data.

Goals (agreed with user):

1. **Off-host backups** pushed to external sources (Synology NAS; Neon for
   Postgres).
2. **Constant snapshots at daily (or finer) granularity** for restoration.
3. **Pre-`nixos-rebuild` snapshots**: before every rebuild, snapshot the
   data datasets so both the NixOS system generation AND the data can be
   returned to pre-apply state.
4. **Per-service dataset granularity**: snapshot/rollback scoped to e.g.
   Dawarich or TREK, not all of `/var`.
5. **Opt-in service list**: only services explicitly chosen get datasets +
   backup coverage — NOT every service ever enabled.
6. **Declarative dataset management**: post-install datasets are declared in
   config (fixing the current out-of-band drift, e.g. `zroot/media-youtube`
   created by hand), without re-running disko destructively.

## 2. Research findings (constraints that shaped the design)

### 2.1 Synology cannot receive ZFS replication

Syncoid / `zfs send | zfs recv` require ZFS on BOTH ends. Synology DSM
exposes only btrfs/ext4. Therefore ZFS replication to the NAS is impossible
without an intermediary ZFS host (none exists). File-level encrypted backup
(restic) is the correct NAS link.

btrfs snapshots on the Synology only protect NAS-side state after data
lands (optional complement via DSM's Snapshot Replication package); they
are not the backup mechanism itself.

Reference: sanoid issue #564 ("syncoid to non-zfs backup system"),
https://github.com/jimsalterjrs/sanoid/issues/564

### 2.2 Postgres on ZFS: snapshots are crash-consistent, not portable

A ZFS snapshot of the PostgreSQL data directory with WAL on the same
dataset is atomic and crash-consistent; Postgres recovers via WAL replay.
Good for fast local restore points. It is NOT an offsite backup: logical
dumps (`pg_dump`) are portable, verifiable, and version-independent.
Plan uses both: dumps as the trustworthy artifact, snapshots as
convenience.

### 2.3 NixOS has no pre-apply hook

`nixos-rebuild` and `switch-to-configuration` expose no pre-switch hook.
`system.activationScripts` fire AFTER activation — too late. Overriding the
`nixos-rebuild` package with a patched copy is fragile across nixpkgs
updates. Conclusion: a wrapper script, installed as a system package
(`writeShellScriptBin` in `environment.systemPackages`), is the standard and
correct approach. Note: system generations are already rollback-safe for
free (boot menu / `nixos-rebuild switch --rollback`); only DATA needs
pre-switch snapshots.

### 2.4 Tooling available in the pinned nixpkgs (stable 26.05, all confirmed)

| Module / package | Purpose |
| --- | --- |
| `services.sanoid` | template-driven ZFS snapshot policy + pruning (replaces `services.zfs.autoSnapshot`) |
| `services.syncoid` | ZFS→ZFS replication (unused for now; only relevant if a ZFS target ever appears) |
| `services.postgresqlBackup` | nightly `pg_dump` per database, custom format, retention |
| `services.pgbackrest` | PITR/WAL archiving (available; overkill at current scale — deferred) |
| `services.restic.backups` | encrypted, deduplicated push backup; supports rclone backend |
| `pkgs.rclone` | speaks SFTP to the NAS so restic needs no binary on the NAS |

### 2.5 Neon as Postgres offsite/DR

Nightly job: create a fresh branch via the Neon API, `pg_dump` each
database locally, `pg_restore` into the branch, verify row counts, delete
branches older than N days. This yields an offsite copy AND a nightly
restore test (an untested backup is not a backup). Requires a Neon API key
and project id.

## 3. Target architecture

Four layers, all declarative:

```
L1  per-service ZFS datasets        (granularity: rollback one service)
L2  sanoid snapshot policy          (constant snapshots + pruning)
L3  logical Postgres dumps          (portable, verifiable artifacts)
L4  off-host push                   (restic→Synology; Neon branch DR)
    + rebuild-server wrapper        (pre-apply snapshots, gen↔snap mapping)
```

### 3.1 Layer 1 — per-service datasets

New datasets under `zroot/var/lib/` (nested children of existing
`zroot/var`, mountpoints inherit):

| Dataset | Mountpoint | Contents |
| --- | --- | --- |
| `zroot/var/lib/dawarich` | `/var/lib/dawarich` | Dawarich state (module StateDirectory) |
| `zroot/var/lib/trek` | `/var/lib/trek/{data,uploads}` | TREK SQLite + uploads |
| `zroot/var/lib/oxicloud` | `/var/lib/oxicloud/storage` | OxiCloud blobs |
| `zroot/var/lib/postgresql` | `/var/lib/postgresql` | PG data + WAL together (atomic snapshots) |
| `zroot/var/lib/backup` | `/var/lib/backup/postgresql` | dump target (from postgresqlBackup) |

Existing out-of-band datasets to declare (already on disk, no migration
needed — declaration only): `zroot/data/media` (`/data/media`,
`media-server.nix`) and `zroot/media-youtube` (`/media/youtube`,
`pinchflat.nix`). Verify actual names with `zfs list` before declaring.

Deliberately NOT given datasets (per user opt-in decision): stirling-pdf
(rebuildable config), collabora, pinchflat media (large, re-downloadable
media — snapshots only via existing `zroot/var`/media datasets, NOT shipped
offsite), caddy, mosquitto/zigbee2mqtt. Open question, resolve at
implementation time: Home Assistant `/var/lib/hass` (SQLite recorder +
entity registry — small and genuinely stateful; recommend including, ask
user).

#### Dataset management: `oxc.zfs.datasets`

disko stays the install-time source of truth and must NOT be re-run against
the live pool. A new option in a shared host-level module owns post-install
dataset creation idempotently:

```nix
# sketch — modules/nixos/services/zfs-backup.nix (new, opt-in per host)
oxc.zfs.datasets = {
  "zroot/var/lib/dawarich" = {
    mountpoint = "/var/lib/dawarich";   # informational; zfs handles it
    backup.enable = true;               # opts INTO L2 snapshot + L4 offsite
  };
  "zroot/data/media" = {
    mountpoint = "/data/media";
    backup.enable = false;              # declared but not backed up
  };
};
```

Implementation: a oneshot systemd service ordered before
`local-fs.target`/sysinit (or an activation script) running, per dataset:
`zfs create -o com.sun:auto-snapshot=false <ds>` only if `zfs list <ds>`
fails. Idempotent, non-destructive, never destroys or modifies existing
datasets. `backup.enable` drives sanoid + restic membership (single list =
the opt-in surface).

#### One-time migration (existing data onto nested datasets)

For each of dawarich / trek / oxicloud / postgresql:

```bash
sudo systemctl stop dawarich.target docker-trek.service docker-oxicloud.service postgresql.service
sudo mv /var/lib/dawarich /var/lib/dawarich.old          # must vacate: zfs create shadows non-empty dirs
sudo zfs create zroot/var/lib/dawarich                   # module does this on activation; or here manually
sudo rsync -aHAX /var/lib/dawarich.old/ /var/lib/dawarich/
sudo rm -rf /var/lib/dawarich.old
# ownership: dawarich user owns its StateDirectory; postgres owns /var/lib/postgresql (uid 70-ish per NixOS)
sudo systemctl start postgresql.service dawarich.target docker-oxicloud.service docker-trek.service
```

Do PostgreSQL LAST, after `postgresqlBackup` is configured and a first dump
exists (belt and suspenders before moving the data dir).

### 3.2 Layer 2 — sanoid (replaces `services.zfs.autoSnapshot`)

Remove the `services.zfs.autoSnapshot` block from
`nixos/server/orca/default.nix` (resolving the documented conflict in
`docs/zfs-user-guide.md`) and configure `services.sanoid` instead. Snapshot
policy derived from `oxc.zfs.datasets` (`backup.enable = true`) plus
system datasets:

| Dataset(s) | frequent (15m) | hourly | daily | weekly | monthly |
| --- | --- | --- | --- | --- | --- |
| dawarich, postgresql | keep 4h (16) | keep 48 | keep 14 | 0 | 0 |
| trek, oxicloud, backup dumps | 0 | keep 24 | keep 14 | 0 | 0 |
| `zroot/etc` | 0 | 0 | keep 91 | 0 | 0 |
| `zroot/home` | 0 | 0 | 0 | keep 13 | 0 |
| `zroot/var` (remainder) | 0 | keep 24 | keep 14 | 0 | 0 |

sanoid owns pruning; retention of `pre-switch-*` snapshots (below) is
manual — sanoid must NOT prune them (use a separate naming pattern outside
sanoid's templates, which it ignores by default).

### 3.3 Layer 3 — Postgres dumps

```nix
services.postgresqlBackup = {
  enable = true;
  location = "/var/lib/backup/postgresql";
  databases = [ "dawarich" "oxicloud" ];   # hass NOT on postgres today (sqlite); revisit if moved
  startAt = "*-*-* 01:30:00";
  compression = "zstd";                    # if option unavailable in 26.05, drop
};
```

`/var/lib/backup` is its own dataset (5.1) so dumps snapshot independently
and ride Layer 4 offsite.

### 3.4 Layer 4a — restic → Synology DS418

Target: `nas-ds418-00.griffin-cobra.ts.net` (tailnet). DS418 = ARM
RTD1293, 1GB RAM, btrfs. **restic runs entirely on orca via the rclone
backend** — rclone speaks SFTP; no restic binary needed on the NAS (its 1GB
RAM is irrelevant; orca does all chunking/encryption).

```nix
# sketch
services.restic.backups.orca = {
  repository = "rclone:nas:orca-restic";       # rclone remote name "nas"
  rcloneConfigFile = <agenix-generated rclone.conf>;  # or EnvironmentFile w/ RCLONE_CONFIG_*
  passwordFile = <agenix restic repo password>;
  paths = <derived from oxc.zfs.datasets backup.enable + /var/lib/backup + /etc/nixos>;
  pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 6" ];
  startAt = "*-*-* 03:00:00";
  timerConfig = { Persistent = true; };
  backupPrepareCommand = /* optional: pg_dump --flush? no: postgresqlBackup timer covers */;
};
```

Details:

- rclone remote `nas`: type sftp, host `nas-ds418-00.griffin-cobra.ts.net`,
  user e.g. `restic`, key_file from agenix, `server_command_interleave`/
  default sftp subsystem fine. Host key pinned via `known_hosts` entry in
  the config (rclone `--sftp-ask-password=false`, use
  `strict_host_keyChecking` equivalent: rclone sftp option
  `known_hosts_file`).
- Repo layout: single repo, paths tagged by dataset:
  `/var/lib/dawarich`, `/var/lib/trek`, ..., `/var/lib/backup/postgresql`,
  `/etc` (covers agenix-encrypted secrets at rest only if `/etc` is dumped
  — the age keys live in `/etc/agenix`? NO: age identity lives at
  `/var/lib/sops-nix`-like path — for agenix it's the host age identity
  configured on this host; locate at implementation time and include it in
  paths, since without it encrypted secrets are unrecoverable).
- Exclude: `*.sock`, `/var/lib/postgresql` data dir (dumps suffice; the
  live data dir is huge and crash-state), media datasets.
- Validation: `services.restic.backups.<name>.checkOpts` / a weekly
  `restic check --read-data-subset=1G`.

### 3.5 Layer 4b — Neon nightly branch DR

New module or orca-local file `nixos/server/orca/neon-dr.nix`:

- systemd service `neon-dr` + timer (`*-*-* 02:30:00`, Persistent).
- Script (packaged with `pkgs.writeShellApplication` or a small python
  script if the Neon API pagination demands it — start with curl+jq):
  1. `POST /branches` (Neon API v2? verify current API at implementation)
     → branch `orca-dr-YYYYMMDD`, obtains connection string.
  2. For each db in `[ dawarich oxicloud ]`:
     `sudo -u postgres pg_dump -Fc <db>` → restore into branch via
     `pg_restore -d <neon-conn>`.
  3. Verify: `psql -d <neon-conn> -c 'select count(*) from <known table>'`
     per db (pick a stable table per db; dawarich: `points`; oxicloud:
     whatever exists — check at implementation).
  4. Delete branches named `orca-dr-*` older than 7 days.
- Credentials via agenix: `NEON_API_KEY`; project id plain in nix.
- Failure = non-zero exit → systemd unit failed → visible in `systemctl
  --failed`. (Optional later: Prometheus/healthchecks.io ping; not in v1.)

### 3.6 `rebuild-server` wrapper

System package (not a fish alias), defined in the same zfs-backup module,
installed only on hosts where the module is enabled:

```
rebuild-server:
  1. for ds in (oxc.zfs.datasets where backup.enable or all managed ds?):
       ALL managed datasets (not just backup-enabled) get pre-switch snaps:
       zfs snapshot <ds>@pre-switch-$(date +%Y%m%d-%H%M)
     plus zroot/etc and zroot/var (coarse safety net)
  2. gen_before=$(nix-env -p /nix/var/nix/profiles/system --list-generations | tail -1)
  3. nixos-rebuild switch --flake ~/0xc/nixcfg   # prints closure diff itself
  4. gen_after=$(...); print + logger -t rebuild-server: "gen <n> ↔ pre-switch-<ts>"
Rollback recipe printed on demand via `rebuild-server --rollback-help`.
```

Rollback procedure (goes into docs): pick the pre-switch snapshot from the
journal mapping, then per dataset `systemctl stop <svc>; zfs rollback
<ds>@pre-switch-...; systemctl start <svc>`, and `nixos-rebuild switch
--rollback` (or boot menu entry) for the system side.

Note: wrapper snapshots all `oxc.zfs.datasets` entries (managed surface),
since a rebuild can touch any service, not only backup-enabled ones.

## 4. Files to create / modify

| Path | Action |
| --- | --- |
| `modules/nixos/services/zfs-backup.nix` | CREATE — `oxc.zfs.datasets` option, dataset-ensure service, sanoid wiring, restic wiring, `rebuild-server` package |
| `modules/nixos/services/default.nix` | MODIFY — import new module |
| `nixos/server/orca/default.nix` | MODIFY — remove `services.zfs.autoSnapshot`, enable module + dataset list |
| `nixos/server/orca/neon-dr.nix` | CREATE — Neon branch DR service + timer |
| `secrets/services/restic/orca-repo-password.age` | CREATE (agenix) |
| `secrets/services/restic/rclone-nas.age` (or ssh key age file) | CREATE (agenix) |
| `secrets/services/neon/api-key.age` | CREATE (agenix) |
| `lib/age-matrix.nix` | MODIFY — add new secrets to matrix |
| `docs/backup-restore.md` | CREATE — operator runbook: restore from snapshot / dump / restic / Neon; rollback pairing |
| `docs/zfs-user-guide.md` | MODIFY — dataset table incl. per-service datasets, sanoid replaces autoSnapshot, pre-switch snapshots |

Port-map convention: if any port is introduced (none expected), it MUST be
claimed in `nixos/server/orca/ports.nix` (`oxc.ports`, dup-asserted). No
ports are expected in this work.

## 5. Secrets checklist (user-side, one-time)

1. **DS418**: enable SSH/SFTP; create `restic` user; create shared folder
   e.g. `orca-restic`; place orca's ed25519 public key in
   `~restic/.ssh/authorized_keys`; record host key fingerprint.
2. **agenix**: create repo password (`openssl rand -base64 32`), rclone
   config / SSH private key, Neon API key; rekey per `lib/age-matrix.nix`.
3. **Neon**: create project; record project id; generate API key; confirm
   plan limits (storage + branch count; free tier may cap branches — if
   branch-per-night exceeds limits, fall back to single `orca-dr` branch
   dropped+recreated nightly).

## 6. Implementation phases (each independently shippable + verifiable)

1. **Datasets module + migration.** `oxc.zfs.datasets`, declaration of all
   L1 datasets, one-time migration runbook executed by user on orca.
   Verify: `zfs list` shows datasets; services start; data intact
   (`systemctl status`, app smoke tests).
2. **sanoid.** Replace autoSnapshot, wire templates. Verify: `systemctl
   list-timers | grep sanoid`; snapshots appear at expected cadence; old
   zfs-auto-snap behavior gone.
3. **`rebuild-server`.** Verify: run it; `zfs list -t snapshot | grep
   pre-switch`; journal shows gen↔snapshot mapping; rollback-help prints
   sane recipe.
4. **postgresqlBackup.** Verify: timer fires; dump files land in
   `/var/lib/backup/postgresql`; `pg_restore --list` parses one.
5. **restic → NAS.** Verify: initial backup completes; `restic snapshots`;
   prune runs; restore one file to `/tmp` from the NAS repo.
6. **Neon DR.** Verify: branch created; restore verification passes;
   old branches pruned; deliberate failure (bad key) surfaces as failed
   unit.
7. **Docs.** Update zfs-user-guide; write backup-restore.md runbook; update
   this file's status to "implemented".

## 7. Deferred / out of scope

- pgBackRest PITR (revisit if WAL-level recovery ever needed)
- syncoid to a future ZFS target (e.g. second ZFS host)
- DSM-side btrfs snapshots on DS418 (optional NAS-local complement)
- healthchecks.io / alerting integration for failed backup units
- Media datasets (jellyfin library, youtube) offsite — re-downloadable,
  excluded by design
- hass on postgres (would join databases lists if ever migrated)
