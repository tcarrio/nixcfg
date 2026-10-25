# PostgreSQL Administration Guide

Reference for managing PostgreSQL on hosts in this repository (currently
`orca`). Covers the no-credentials authentication model used here, manual
access, backup/restore, and how services are wired up.

## Authentication model: no passwords

Native NixOS services that use postgres (and the container integrations in
this repo) do not use passwords at all. Authentication is **peer auth over
the unix socket**:

- Postgres listens on `/run/postgresql/.s.PGSQL.5432`.
- `pg_hba.conf`'s `local all all peer` line (NixOS default) authenticates
  the connecting process by kernel-verified uid.
- The OS user name must match the database role name.

Identity = OS user = DB role. There is no credential to generate, store,
rotate, or leak. The role has no password set, so TCP connections that
require one (the default `host ... md5` lines) are denied by design.

Consequence for access: on the host, `sudo -u <user>` *is* the
credential. Remote access always goes through `ssh` first; postgres is
never network-exposed beyond loopback.

## Manual connection

```bash
# as the application role (exactly what the app sees)
sudo -u oxicloud psql oxicloud

# as the postgres superuser (full control)
sudo -u postgres psql oxicloud

# list databases / roles
sudo -u postgres psql -c '\l'
sudo -u postgres psql -c '\du'
```

TCP (`psql -h 127.0.0.1 ...`) will fail for these roles — no password
exists and no HBA entry grants them network access. This is intended.

## Wiring services up (the pattern)

Native NixOS services (gitea, home-assistant, etc.) get this for free:
they run on the host as their own OS user and connect via the socket.

Containerized services can reproduce the same pattern — see
`nixos/server/orca/oxicloud.nix` for the reference implementation:

1. **Declare the database and role** with `services.postgresql`:

   ```nix
   services.postgresql = {
     enable = true;
     ensureDatabases = [ "oxicloud" ];
     ensureUsers = [{ name = "oxicloud"; ensureDBOwnership = true; }];
   };
   ```

   `ensure*` options are create-only: they never drop or reinitialize.
   First start creates the role and database; every later start is a
   no-op check.

2. **Declare a host user whose uid matches the image's app user** (e.g.
   the OxiCloud image runs its app as uid 1001):

   ```nix
   users.users.oxicloud = {
     uid = 1001;
     isSystemUser = true;
     group = "nogroup";
   };
   ```

3. **Bind-mount the socket into the container** (read-write — connecting
   to a unix socket requires write access on the socket inode):

   ```nix
   volumes = [ "/run/postgresql:/run/postgresql" ];
   ```

4. **Connect via the socket in the connection string**, percent-encoding
   the socket directory as the host (libpq/SQLx convention):

   ```
   postgres://oxicloud@%2Frun%2Fpostgresql/oxicloud
   ```

5. **Order the container after postgres** (`after`/`requires`
   `postgresql.service`) so the socket exists first.

Two container-specific pitfalls this pattern avoids:

- **`--env-file` loses to image `ENV`** — `docker run` gives precedence to
  the image's built-in environment over `--env-file` entries, but *not*
  over `-e`. With no password in the connection string, it can live in
  plain `virtualisation.oci-containers` `environment` (which becomes
  `-e`) and reliably override the image default.
- **Password distribution** — a password must reach both postgres and the
  container; the usual NixOS mechanisms (store paths, `ensureUsers`)
  leak it to the world-readable store, so the alternatives involve
  LoadCredential/preStart plumbing or entrypoint wrappers. Peer auth
  makes all of that unnecessary.

### Migrations

Services that ship their own migrations (e.g. OxiCloud's embedded SQLx
migrations, run at startup via `sqlx::migrate!().run(pool)`) need nothing
on the NixOS side beyond the database existing. Schema changes arrive with
new image versions. For services without self-migration, run
`psql -f <migration.sql>` as the service role during deploy or wrap it in
a systemd oneshot ordered after `postgresql.service`.

## Backup

**Logical dumps are the trustworthy backup** (consistent, portable,
restorable to any version):

```bash
# dump (custom format, compressed)
sudo -u postgres pg_dump -Fc oxicloud > oxicloud-$(date +%F).dump

# restore (wipe and reload)
sudo -u postgres pg_restore -d oxicloud --clean oxicloud-YYYY-MM-DD.dump

# inspect a dump without restoring
pg_restore --list oxicloud-YYYY-MM-DD.dump
```

**NixOS-native scheduled backups**:

```nix
services.postgresqlBackup = {
  enable = true;
  databases = [ "oxicloud" ];
  location = "/var/lib/backup/postgresql";
  startAt = "*-*-* 03:15:00";
};
```

One custom-format dump per database, gzip'd, rotation via systemd timer.

**ZFS snapshots are not a substitute** — a snapshot of a running postgres
is crash-consistent at best (WAL recovery on restore), unlike `pg_dump`
which is transactionally consistent. Snapshots are fine as
point-in-time recovery *within* an outage window; use both.

**Backup the whole service, not just the DB.** Application blob stores
that reference database rows by hash (e.g. OxiCloud's
`/var/lib/oxicloud/storage`) must be backed up together with the database
— a database whose blob hashes point at missing files is worse than
either half alone.

## Operational notes

### Collation version mismatch

After a glibc upgrade (e.g. 2.40 → 2.42), postgres refuses operations on
databases created under the old glibc:

```
ERROR:  database "template1" has a collation version mismatch
DETAIL:  The database was created using collation version 2.40, but the
operating system provides version 2.42.
```

This surfaced on orca as a `postgresql-setup.service` failure during
`nixos-rebuild`. NixOS will not fix it automatically: the data directory
is mutable state (`/var/lib/postgresql`) that NixOS never touches, and
neither possible fix is safe to automate (`REFRESH COLLATION VERSION`
asserts nothing changed and can hide index corruption; `REINDEX` is the
real fix but touches all data).

Remediation:

```bash
# 1. reindex (actual repair) — order matters, do this first
sudo -u postgres reindexdb --all

# 2. refresh the recorded collation version (clears the mismatch)
sudo -u postgres psql postgres  -c 'ALTER DATABASE postgres  REFRESH COLLATION VERSION;'
sudo -u postgres psql template1 -c 'ALTER DATABASE template1 REFRESH COLLATION VERSION;'
sudo -u postgres vacuumdb --all --analyze

# 3. re-run the failed rebuild
```

If the instance holds no data worth keeping, wiping `/var/lib/postgresql`
and rebuilding is equivalent and simpler — initdb then stamps the current
glibc.

### Where state lives

- Data directory: `/var/lib/postgresql/<schema-version>/` (on the
  `zroot/var` dataset on orca — covered by its hourly snapshots)
- Socket: `/run/postgresql/` (tmpfs, recreated at boot)
- Config: generated by NixOS from `services.postgresql.settings` and
  `.authentication`; do not edit generated files
