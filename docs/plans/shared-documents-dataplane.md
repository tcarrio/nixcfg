# Shared Documents Data Plane — Design Plan

Status: **planned — not started** (2026-10-25)
Companion plan: `orca-backup-dr-plan.md` (datasets/snapshots/offsite). This
plan builds on that plan's `oxc.zfs.datasets` module; implementing this
first requires at least its Phase 1 (dataset management) to exist.
This file is a complete handoff: a fresh agent with empty context can
implement from this document alone.

---

## 1. Problem statement

Document-ish services on orca each keep files in their own private store:

| Service | Storage today | Shared-filesystem potential |
| --- | --- | --- |
| paperless-ngx (`nixos/server/orca/paperless.nix`) | `/var/lib/paperless` (media dir + postgres db) | HIGH — designed consume-dir + exporter edges |
| stirling-pdf | `/var/lib/stirling-pdf` (config only; stateless transformer) | NONE NEEDED |
| oxicloud (`nixos/server/orca/oxicloud.nix`) | `/var/lib/oxicloud/storage` + postgres catalog | BLOCKED (see research) |
| jellyfin / pinchflat | `/data/media`, `/media/youtube` via `media-server` group | ALREADY SHARED — existing proof of the pattern |
| collabora, dawarich, trek, hass | own state / dbs | NONE NEEDED |

Goal: a common ZFS-backed documents namespace under `/data/documents`
where files enter from many sources (SMB drop, scanner, scripts), flow
through paperless (OCR, tagging, PDF/A), and land in a plain-file archive
browsable by humans and other services — without fighting app-native
storage models.

Non-goals: object storage (nothing can use it — see research), forcing
OxiCloud participation, media library changes.

## 2. Research findings (verified 2026-10-25)

### 2.1 Paperless: consume + export edges are designed for this

- `services.paperless.consumptionDir` (NixOS option, confirmed in the
  pinned nixpkgs rev da6dc0e) — any directory; files dropped there are
  consumed + OCR'd. Consumer deletes/moves files after processing, so it
  needs read+delete on the drop dir, not just read.
  `PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS` turns subdirectory names into tags
  (set via `services.paperless.settings`).
- Document exporter (docs.paperless-ngx.com/administration): exports
  **documents + thumbnails + metadata + full database contents**
  (`manifest.json` with correspondents, tags, settings). Incremental —
  re-runs update an existing export, rsync-friendly. Flags: `-d` remove
  files from deleted documents, `-p` split into `archive/ originals/
  thumbnails/ json/` folders, `-sm` per-document JSON, `-f` use custom
  filename format, `-na`/`-nt` skip archive/thumbnails (smaller backups).
- `document_importer` rebuilds a **complete fresh instance** from an
  export; should be run against an empty instance, ideally the same
  paperless version (export is an exact DB image). NixOS pins the version
  to the nixpkgs rev, so restore = same flake = same version. Exporter
  runs as a systemd timer via `services.paperless.exporter.enable`
  (+ `.directory`, `.settings` for CLI args, `.onCalendar`).
- API tokens are NOT exported — re-create after a restore.

### 2.2 OxiCloud: cannot join a shared FS today

Verified against upstream (repo moved: `DioCrafts/OxiCloud` →
`AtalayaLabs/OxiCloud`; we run `docker.io/diocrafts/oxicloud:0.9.3`):

- Catalog is postgres-backed; **no feature to index or serve arbitrary
  external directories**. Pointing it at `/data/documents` does nothing.
- **External mounts** (S3/WebDAV providers appearing as folders) and
  **S3 storage backend** are on the roadmap (TODO-LIST.md "Storage
  optimizations"), NOT shipped.
- What exists today: full RFC 4918 WebDAV **server** — OxiCloud can be
  mounted BY clients. A client-side scripted pull (WebDAV → inbox) is the
  only bridge into the plane. Optional, defer.

Decision: OxiCloud remains a parallel island (own catalog, own backups per
the DR plan). Re-evaluate when upstream ships external mounts.

### 2.3 Others

- Stirling: stateless PDF toolkit — no storage to share. No change.
- Collabora: WOPI-only editor, stores nothing. No change.
- Dawarich/TREK/HA: self-contained state, covered by DR-plan datasets.
- Jellyfin/pinchflat: the `media-server` group (gid 1300,
  `nixos/mixins/permissions/groups/media.nix`) IS the precedent —
  this plan replicates that pattern for documents.

## 3. Target architecture

```
zroot/data/documents              (parent, no direct writes)
├── inbox/     zroot/data/documents/inbox      — drop zone, group-writable
└── archive/   zroot/data/documents/archive    — paperless exporter target,
                                                 group-readable, paperless-writable
```

Data flow:

```
SMB drop / scanner / script
        │
        ▼
/data/documents/inbox  ──paperless consumer──▶  paperless (OCR, tag, PDF/A)
                                                     │ exporter timer (incremental)
                                                     ▼
                                       /data/documents/archive
                                       (originals/ archive/ json/ — browsable,
                                        restic-backed-up, instance-rebuildable)
```

### 3.1 Permissions

New group mixin, mirroring media-server:

```nix
# nixos/mixins/permissions/groups/documents.nix
users.groups.documents = {
  # Shared document drop/archive group (see docs/plans/shared-documents-dataplane.md)
  gid = 1301;
};
```

- `paperless` user: member of `documents` (needs read+delete on inbox,
  write on archive).
- Human/SMB users that should drop files: member of `documents`.
- `inbox`: `2770 root:documents` (setgid so new files inherit the group).
  Note: `services.paperless.consumptionDirIsPublic = false` (default)
  makes the NixOS tmpfiles rule `0770 paperless:paperless` — OVERRIDE it:
  add our own tmpfiles rule for `/data/documents/inbox` AFTER module
  rules, or set `consumptionDirIsPublic = true` (0777 — rejected) —
  use a custom tmpfiles entry with a lexically-later name
  (e.g. `systemd.tmpfiles.settings."20-documents-plane"`) so it wins.
- `archive`: `2770 paperless:documents` — paperless writes, group reads.

### 3.2 Paperless wiring (modify `nixos/server/orca/paperless.nix`)

```nix
services.paperless = {
  consumptionDir = "/data/documents/inbox";
  settings.PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;  # optional
  exporter = {
    enable = true;
    directory = "/data/documents/archive";
    # CLI args to document_exporter:
    settings = [ "-d" "-p" "-sm" ];  # prune deleted, folder split, per-doc json
    startAt = "*-*-* 04:30:00";      # after postgres dumps (01:30), before restic (03:00)? reconcile with DR plan timers
  };
};
users.users.paperless.extraGroups = [ "documents" ];
```

Exporter caveats to honor: never point `-d` at a dir that contains foreign
files; archive dataset is paperless-owned output, humans read-only in
practice.

### 3.3 SMB exposure (orca as the file server)

Decision: orca exports `/data/documents` via Samba (NixOS `services.samba`),
LAN + tailnet, no guest:

```nix
services.samba = {
  enable = true;
  openFirewall = false;  # explicit rule below
  shares.documents = {
    path = "/data/documents";
    browseable = "yes";
    "read only" = "no";
    "valid users" = "tcarrio @documents";
    "create mask" = "0660";
    "directory mask" = "2770";
  };
  # disable printer service etc. per module defaults
};
networking.firewall.allowedTCPPorts = [ 445 ];  # SMB2/3 only; claim in oxc.ports (see 3.5)
```

Synology alternative (mount orca's share / rsync from NAS) was rejected as
the primary path: orca owns the plane, the NAS is the backup target
(rclone/restic already in the DR plan). If SMB-from-orca is unwanted, the
fallback is Synology Sync/task pulling `archive/` for offsite copies only.

### 3.4 ZFS datasets + snapshots

Datasets declared via the DR plan's `oxc.zfs.datasets` (dependency):

```nix
oxc.zfs.datasets = {
  "zroot/data/documents/inbox"   = { backup.enable = false; };  # transient drop zone: snapshots daily, no offsite
  "zroot/data/documents/archive" = { backup.enable = true;  };  # the corpus: snapshots + restic offsite
};
```

Snapshot policy (sanoid, via DR plan templates): inbox daily keep 7;
archive daily keep 14 + weekly keep 8. The archive is also the canonical
paperless rebuild source — restic offsite of `archive/` reduces the
paperless DB dump to a convenience (export contains full DB image).

### 3.5 Port claim

SMB = TCP 445. Add to `nixos/server/orca/ports.nix`:

```nix
samba = 445; # documents data plane SMB (paperless.nix plane; LAN + tailnet)
```

Firewall: extend `networking.firewall.allowedTCPPorts` (currently
22/443). Restricting to LAN interface only (enp2s0) vs tailnet too is an
open decision — default proposal: allow 445 on both (interface-specific
rules), since tailnet SMB to orca is wanted for off-LAN drop.

## 4. Files to create / modify

| Path | Action |
| --- | --- |
| `nixos/mixins/permissions/groups/documents.nix` | CREATE — documents group, gid 1301 |
| `nixos/server/orca/paperless.nix` | MODIFY — consumptionDir, exporter, extraGroups |
| `nixos/server/orca/default.nix` (or new `samba.nix`) | CREATE samba config — prefer new `nixos/server/orca/samba.nix` following per-service file convention |
| `nixos/server/orca/ports.nix` | MODIFY — claim `samba = 445` |
| DR-plan module (`modules/nixos/services/zfs-backup.nix`) | DEPENDS — datasets declared once it exists |
| `docs/zfs-user-guide.md` / `docs/backup-restore.md` | MODIFY at implementation — documents datasets, paperless restore-from-export runbook |

## 5. Implementation phases

1. **Group + datasets + permissions** (needs DR-plan Phase 1 module).
   Verify: datasets exist, modes `2770`, `sudo -u paperless touch` works in
   both dirs.
2. **Paperless wiring** (consumptionDir + exporter + extraGroups).
   Verify: drop a PDF in inbox as a documents-group user → consumed;
   `journalctl -u paperless-consumer -f`; exporter timer fires →
   `archive/originals/…` populated; second run is incremental.
3. **Samba.** Verify: mount from a LAN client and a tailnet client
   (`mount -t cifs //orca/documents`), drop file → consumed; `smbclient
   -L orca` sane; port 445 claimed + firewall allows only it.
4. **Docs.** Restore runbook: rebuild paperless from `archive/` via
   `document_importer` against a fresh instance (empty db, same version),
   re-create API tokens; update zfs-user-guide dataset table.

## 6. Decisions made / deferred

- MADE: no object store; no OxiCloud integration; paperless = processor
  over the plane; exporter archive = canonical rebuild source; orca hosts
  SMB, NAS stays a backup target.
- DEFERRED: network scanner into inbox (SANE/hplip — future);
  `PAPERLESS_FILENAME_FORMAT` + exporter `-f` (nice browsing names);
  WebDAV pull bridge from OxiCloud (optional, low value now);
  subdir-tag conventions for inbox.

## 7. Risks / notes

- Exporter `-d` deletes files in archive that paperless no longer knows —
  archive must never hold foreign files. Enforce by ownership
  (`paperless:documents` 2770) + documentation.
- Same-version import constraint is satisfied by flake pinning; note it in
  the restore runbook anyway (restore = checkout the nixpkgs rev recorded
  in the export's `manifest.json` era... simpler: restore with the same
  flake commit that produced the export).
- SMB on tailnet: latency poor over relays; fine for occasional drops.
- gid 1301 collision check at implementation: `getent group 1301`.
