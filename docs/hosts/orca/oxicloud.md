# OxiCloud on orca

Operational reference for the OxiCloud deployment (`nixos/server/orca/oxicloud.nix`).
General database administration (peer auth, backup, the container/DB wiring
pattern) lives in [`../../postgresql-admin-guide.md`](../../postgresql-admin-guide.md);
ZFS snapshot/restore in [`../../zfs-user-guide.md`](../../zfs-user-guide.md).

## Deployment shape

| Piece | Value |
| --- | --- |
| App | OCI container `docker.io/diocrafts/oxicloud:0.9.3` (pinned tag — bump deliberately) |
| Database | native `services.postgresql` on orca, db + role `oxicloud`, unix-socket peer auth |
| Storage | `/var/lib/oxicloud/storage` (content-addressed blob store) |
| Exposure | `https://oxicloud.carrio.me` via Caddy (Cloudflare DNS-01), container port `127.0.0.1:8086` only |
| Migrations | app-internal — embedded SQLx migrations run at every startup, nothing to do on the NixOS side |

Upstream: <https://github.com/AtalayaLabs/OxiCloud> — `example.env` in the
repo documents every environment variable (authoritative source).

## Admin account

First run: open `https://oxicloud.carrio.me` — the first-run setup flow
(`POST /api/setup`) creates the setup-admin account. This is a one-time
gate; once any admin exists the endpoint is closed. Do this before
exposing the instance to anyone else.

## User management

Four provisioning paths:

1. **Admin-created** — admin panel → users (`POST /api/admin/users`). No
   email required; admin sets the initial credentials. Quotas applied from
   the `OXICLOUD_DEFAULT_*_QUOTA_BYTES` values below.
2. **Public signup** — `POST /api/auth/register`. **Open by default**
   (auth methods default to `password,magic_link`; rate limit 5 attempts/
   hour/IP). Gate by sender domain if open signup is unwanted:
   `OXICLOUD_REGISTRATION_ALLOWED_EMAIL_DOMAINS=carrio.me`.
3. **Magic-link invite** — share-by-email sends a login link. Requires
   SMTP (below); returns 503 when `OXICLOUD_SMTP_HOST` is empty.
4. **OIDC JIT** — first SSO login auto-provisions an account (default
   on), `OXICLOUD_OIDC_ADMIN_GROUPS=admins` grants the admin role from
   IdP group membership.

Default quotas (override per-deployment in the module):

```nix
OXICLOUD_DEFAULT_USER_QUOTA_BYTES = 1073741824;   # 1 GiB, non-admin
OXICLOUD_DEFAULT_ADMIN_QUOTA_BYTES = 107374182400; # 100 GiB, admin
```

## Environment variables: where each kind goes

Precedence in `docker run`: **`-e` (beats) image `ENV` (beats)
`--env-file`**. This is the rule that decides placement, plus "secrets
never enter the Nix store":

| Kind | Example | Mechanism |
| --- | --- | --- |
| Non-secret config, incl. anything the image bakes a default for | `OXICLOUD_BASE_URL`, `OXICLOUD_DB_CONNECTION_STRING` | `virtualisation.oci-containers.containers.<name>.environment` — becomes `-e`, overrides image defaults, values land in the world-readable store (fine: no secrets) |
| Secrets for keys the image does **not** bake | `OXICLOUD_SMTP_PASS` | `environmentFiles` (agenix) — `--env-file` loses to image `ENV`, so only safe for keys with no baked default |
| Secrets for keys the image **does** bake | (none currently) | neither works directly — needs an entrypoint wrapper that sources a mounted secret file |

Incident to remember: the DB connection string originally rode in
`environmentFiles` and silently lost to the image's built-in
`postgres://postgres@localhost` default. `docker inspect oxicloud
--format '{{json .Config.Env}}'` shows what the container actually
received; `docker inspect oxicloud --format '{{json .Config.Image}}'` +
the image's Dockerfile shows what it bakes.

Currently set in the module (`environment`, all non-secret):

```nix
OXICLOUD_SERVER_HOST = "0.0.0.0";        # inside the container only
OXICLOUD_SERVER_PORT = "8086";
OXICLOUD_BASE_URL = "https://oxicloud.carrio.me";  # REQUIRED — auth validates against it
OXICLOUD_STORAGE_PATH = "/app/storage";
OXICLOUD_TEMP_DIR = "/app/storage/tmp";  # disk-backed, not tmpfs /tmp (video EXIF probes)
OXICLOUD_DB_CONNECTION_STRING = "postgres://oxicloud@%2Frun%2Fpostgresql/oxicloud"; # socket, peer auth
```

## Email

SMTP only — upstream ships no provider-API integrations. Anything that
speaks SMTP works:

| Provider | Compatible | Notes |
| --- | --- | --- |
| Resend | yes | `smtp.resend.com:587` STARTTLS, user `resend`, password = API key, From must be a verified domain |
| SES, Postmark, Mailgun, Gmail (app password) | yes | standard SMTP endpoints |
| Cloudflare Email Routing | **no** | inbound forwarding only, cannot send |

Wiring (Resend example) — non-secret parts in `environment`, password via
agenix:

```nix
environment = {
  OXICLOUD_SMTP_HOST = "smtp.resend.com";
  OXICLOUD_SMTP_PORT = "587";
  OXICLOUD_SMTP_USER = "resend";
  OXICLOUD_SMTP_FROM = "OxiCloud <noreply@carrio.me>";
  OXICLOUD_SMTP_TLS = "starttls";
};
# plus: environmentFiles with OXICLOUD_SMTP_PASS from agenix
# (safe here — the image bakes no SMTP defaults)
```

Two upstream behaviors to know:

- **No spool, no retry** — every send is a single attempt. Acceptable
  direct-to-Resend at this scale; upstream suggests a local MTA smarthost
  (msmtp-mta/postfix) if delivery durability ever matters.
- **`OXICLOUD_JOBS_NOTIFY_EMAIL_TO` fails the boot** if set while SMTP is
  unconfigured — intentional (a monitoring channel that silently drops is
  worse than no start). Test the whole chain via the `notify_selftest`
  job in the admin panel.

## Operations

```bash
# logs
journalctl -u docker-oxicloud.service -f

# restart after crash loop (systemd start-limit)
sudo systemctl reset-failed docker-oxicloud.service

# psql access / backups — see postgresql-admin-guide.md
sudo -u oxicloud psql oxicloud
```

**Backups pair the DB with the blob store**: shares reference blobs by
hash in `/var/lib/oxicloud/storage`. `pg_dump` alone restores metadata
pointing at missing files; snapshot/rsync the storage dir together with
the dump (both live on `zroot/var`, so hourly ZFS snapshots cover
crash-consistency — logical dumps remain the authoritative backup).

**Upgrades**: bump the pinned image tag in the module, `rebuild-host`.
Migrations run on the app's next startup — sqlx migrations are
forward-only, so keep the ZFS snapshot from before the upgrade as the
rollback point (see zfs-user-guide.md restore procedures).

## Known pitfalls

- **`chown: /app/storage: Operation not permitted`** — the image
  entrypoint starts as root to chown storage to the app user (uid 1001)
  before dropping privileges via su-exec. `--cap-drop=ALL` without
  `--cap-add=CHOWN/SETUID/SETGID` crash-loops the container.
- **`--env-file` silently losing to image `ENV`** — see the placement
  table above.
- **TLS alert on `oxicloud.carrio.me`** — cert issuance failed; check
  `journalctl -u caddy` for ACME/Cloudflare errors (token needs
  zone-level DNS edit on `carrio.me` to create `_acme-challenge` TXT
  records for new subdomains).
