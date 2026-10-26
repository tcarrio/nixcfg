# nixcfg → eru Refactor: Shared Core + carrio.me Cloudflare Migration

Status: **phases A+B implemented — cutover pending** (2026-10-25)
Scope: restructure nixcfg into a shared core consumed by `~/Code/eru`
(henceforth "eru"), move orca into eru, migrate the `carrio.me` zone
from the old Cloudflare account to the account eru manages, and land
the Cloudflare Tunnel + Access work as Terranix resources in eru.

Supersedes the management decisions in
`docs/plans/cloudflare-tunnels-spec.md` (§6 dashboard-vs-TF, §8): the
tunnel/DNS/Access resources now go through eru's Terranix stack, not
the dashboard and not nixcfg's `/infrastructure`. The NixOS-side
module design (spec §4) carries over into eru's host tree.

Related: `docs/plans/cloudflare-tunnels-spec.md`,
`docs/network/caddy-dns-tiers.md`, `docs/CADDY.md`.

---

## 1. Decisions (recorded 2026-10-25)

| Decision | Choice |
| --- | --- |
| Secrets for NixOS hosts in eru | **agenix** (coexists with eru's sops+age for TF/Infisical secrets; host keys unchanged, no re-encryption format change) |
| Host scope of this refactor | **Orca only**; phoenix/nucs/image builders stay in nixcfg until a follow-up |
| eru consumes nixcfg as | **git flake input** (pinned; local path override for development) |
| nixcfg `/infrastructure` stacks | **stay put** — out of scope |
| Tunnel/DNS/Access management | **Terranix in eru** (was "dashboard manual" pre-pivot) |
| Access IdP | **Google** |
| First exposed service | **dawarich** |

## 2. Current state

### nixcfg

- Flake builds all hosts inline via `lib/helpers.nix` (`mkHost`,
  `mkDarwin`, `mkHome`); mixins under `/nixos/mixins`, `/darwin`,
  `/home-manager`, shared module options under `/modules/shared`
  (`oxc.ports`, `oxc.carrionet`, etc. — host metadata as module
  options, not specialArgs).
- Server hosts: orca, phoenix, pxe-server, nuc0–nuc9, base images.
  Orca is the only one moving now.
- Cloudflare (OLD account) touchpoints:
  - `carrio.me` zone: public records, proxied hostnames, rewrite
    rules/rulesets, universal SSL.
  - ACME DNS-01 token: `secrets/services/acme/cloudflare.age`
    (Caddy on orca; account-scoped — dies with the old zone).
  - Split-horizon tailnet/localnet overrides are NOT in Cloudflare —
    they live in the resolver views (Tailscale DNS / NextDNS). Zone
    migration does not touch them, but they must keep answering.
- `/secrets` agenix tree with `secrets.nix` recipient matrix
  (`lib/ssh/systems.nix`, `lib/age-matrix.nix`).

### eru (`~/Code/eru`)

- flake-parts + Terranix `flakeModule`; per-stack
  `terranixConfigurations` (`carrio-org`, torinreine, …); OpenTofu;
  Cloudflare provider **v5**; Infisical data source for API tokens;
  R2 S3 backend (`tofu-state` bucket); devshell helpers `cftofu`,
  `cftofu-import`, `tofu-mv`.
- `carrio-org` stack: **carrio.dev live** (zone data + records as
  `cloudflare_dns_record`). **carrio.me partially imported**:
  `infrastructure/carrio-org/cloudflare/imported-carrio-me.nix` holds
  a cf-terraforming record dump (unwired, `zone-carrio-me` local
  commented out, no resources emitted).
- No NixOS host support; flake is devshell + Terranix only.
- Points at the NEW personal Cloudflare account (where carrio.dev
  lives).

## 3. Target state

```
nixcfg (shared core)                     eru (org + infra + servers)
├─ lib/        mkHost/mkDarwin/mkHome    ├─ flake.nix
├─ modules/    oxc.* shared options  ├───► inputs.nixcfg (git, pinned)
├─ nixos/mixins/ (hardware, services)│   ├─ hosts/orca/        (ex nixos/server/orca)
├─ overlays/, pkgs/, home-manager/    │   ├─ secrets/           (agenix, ex nixcfg orca secrets)
├─ darwin/, workstations, ISOs        │   ├─ infrastructure/carrio-org/
└─ /infrastructure (unchanged)        │      ├─ cloudflare/carrio-me.nix   (records → v5 resources)
                                      │      ├─ cloudflare/rulesets.nix    (rewrite rules)
                                      │      ├─ tunnel.nix                (cloudflare_tunnel)
                                      │      └─ access.nix                (Access apps + policies)
                                      └─ Taskfile: orca:build / orca:switch targets
```

- nixcfg keeps building workstations/darwin/ISOs exactly as today,
  minus orca. It gains a stable consumable surface (modules + lib +
  overlays + packages) for eru.
- All Cloudflare state for `carrio.me` + `carrio.dev` is Terranix in
  eru, on the new account.
- Tunnel + Access per `cloudflare-tunnels-spec.md` §3 matrix, first
  service dawarich, Google IdP.

## 4. Phase A — nixcfg core extraction — IMPLEMENTED (2026-10-25)

Implemented shape (differs from the original sketch below in that the
mkHost helpers were left intact for the remaining hosts rather than
extracted — orca alone was converted to the consumer pattern):

- `modules/shared/host.nix` — `oxc.host` options (hostname, username,
  systemType, desktop, stateVersion); `modules/shared/ssh.nix` —
  `oxc.ssh.matrix` option defaulting to the repo matrix.
- `modules/nixos/host-base/` — specialArgs-free base system module
  (counterpart to `nixos/default.nix`); flake composes input-dependent
  modules into `nixosModules.host-base` (modules aggregate + disko +
  vscode-server + NixVirt + handy + nix registry).
- `nixosModules.hardware-intel-pc`, `grub-legacy-boot`, `media-group`,
  `users-archon` — composed mixins for consumer host trees.
- `hosts/orca/` — consumer-shaped host tree; `nixosConfigurations.orca`
  is a plain `nixosSystem` over the exposed surface, no mkHost.
- Converted mixins: smartmon/archon/root read `oxc.*` options instead
  of specialArgs. Parity verified: systemd services, system packages,
  `oxc.ports`, Caddy vhosts identical to the mkHost build; toplevel
  evaluates clean on both paths.
- Original sketch:
  1. **Audit orca's imports**: everything the host pulls from outside
     its directory (mixins/hardware/grub-legacy-boot, oxc services
     mixins, `modules/shared` options, overlays, pkgs).
  2. **Expose consumable outputs** from nixcfg's flake.
  3. **Keep host metadata in `oxc.*` options** (`modules/shared`), not
     specialArgs.
  4. **Tag a release** (e.g. `core-v0.1`) for eru to pin — STILL
     PENDING (push + tag after review).

## 5. Phase B — orca moves into eru — IMPLEMENTED (2026-10-25), cutover pending

- eru `flake.nix`: `nixcfg` input (**path** for development — TODO:
  switch to `github:tcarrio/nixcfg` pinned once pushed) + `agenix`
  input (follows nixcfg's nixpkgs; darwin/home-manager follows nulled).
- `modules/hosts.nix` (flake-parts): `nixosConfigurations.orca` =
  nixosSystem over nixcfg's nixpkgs pin + `nixosModules.host-base` /
  `hardware-intel-pc` / `grub-legacy-boot` / `media-group` /
  `users-archon` + agenix + nixcfg overlays + `hosts/orca`.
- `hosts/orca/` — host tree copied from nixcfg, nixcfg-relative mixin
  imports removed (composed in `modules/hosts.nix`), rebuild aliases
  retargeted to `$HOME/Code/eru#orca`.
- `secrets/` — orca `.age` files copied as-is (same recipient set: no
  re-encryption needed); `secrets/secrets.nix` agenix rules with the
  recipient keys inlined (source of truth: nixcfg ssh/age matrices —
  keep in sync on rotation). agenix CLI added to the devshell.
- Taskfile: `orca:build`, `orca:switch`, `orca:eval`.
- Parity verified: systemd services + system packages identical to the
  nixcfg consumer build; toplevel evaluates clean.
- **Cutover (pending, on-host)**: clone eru on orca, run
  `nixos-rebuild switch --flake ~/Code/eru#orca` (or `task orca:switch`),
  verify services + Caddy cert renewal path, then remove orca from
  nixcfg (`hosts/orca/`, flake entry, `secrets/secrets.nix` orca
  entries) so there is one source of truth.

## 6. Phase C — carrio.me zone migration (old account → new account)

Cloudflare cannot move a zone between accounts; this is
create-replicate-switch.

**Status — steps 1–5 done (2026-10-25)**: zone `8de3c8a67387c334177650f428dca4e6`
created in "Tom@carrio.dev's Account" (`pending` until flip). Records
hand-authored in `infrastructure/carrio-org/cloudflare/carrio-me/` —
`orca.nix` (10 service A records → 192.168.1.83, DNS-only),
`mail.nix` (Google Workspace), `legacy-web.nix` (audio/photos/sshd/tom),
`redirects.nix` (ruleset scaffold: rules merge via the
`"carrio-me".redirect-rules` list option, resource materializes only
when non-empty), `access.nix` (Phase D stub). Stale
`imported-carrio-me.nix` deleted. Applied via `task co:tf:plan/apply`
(24 records, includes carrio.dev `gpgnet` drift-recreate); verified
against `lila.ns.cloudflare.com`. Old zone untouched and still
authoritative.

1. **New zone**: add `carrio.me` to the new account (plan level with
   rules/features parity for the rewrite rules). Uncomment
   `zone-carrio-me` local + zone data source in
   `infrastructure/carrio-org/cloudflare.nix`.
2. **Records as code**: rewrite `imported-carrio-me.nix` from the
   cf-terraforming dump into real `cloudflare_dns_record` resources
   (v5 naming — the dump predates the v5 rename). Note the existing
   dump is stale — regenerate with `cftofu generate` against the OLD
   account zone first, then translate.
3. **Rewrite rules**: `cftofu generate --resource-type
   cloudflare_ruleset -z <old-zone-id>` for every ruleset (redirect
   rules, page rules, WAF custom, TLS). Translate to Terranix
   `resource.cloudflare_ruleset` entries. Do the same for any
   Transform/Origin rules in use.
4. **Parity diff**: old-zone export (records + rules + proxy status +
   TTL) vs the new Terranix config — iterate until empty. MX/SPF/
   DKIM/DMARC values byte-identical (Google Workspace mail must not
   drift).
5. **Apply to new zone** while old zone still serves. Pre-warm
   universal SSL: enable proxy on the proxied hostnames in the new
   zone early (certificate issuance on the new zone takes minutes).
6. **ACME token**: mint a new-account token (`Zone:DNS:Edit` on
   `carrio.me`) and stage the agenix re-encryption of
   `acme/cloudflare.age` — but do NOT deploy before the nameserver
   flip: tokens are account-scoped, and pre-flip renewal would write
   DNS-01 TXT to the non-authoritative new zone and fail.
7. **Flip**: change nameservers at the registrar to the new
   assignment — old zone NS are `buck.ns.cloudflare.com` /
   `cheryl.ns.cloudflare.com`; new zone NS are `lila.ns.cloudflare.com` /
   `rustam.ns.cloudflare.com`. Immediately after propagation begins,
   deploy the new
   ACME token to orca (Phase B path). The unsafe window (old-zone
   answers + new-account token, or new-zone answers + old token) is
   minutes; schedule between Caddy renewal cycles so no renewal is
   due. Keep the OLD zone records fully intact during propagation —
   both zones answering identically makes stale resolver answers
   harmless.
8. **Watch**: `dig carrio.me NS +trace` across resolvers, SOA serial
   checks, Caddy cert renewal dry-run, mail flow (MX unchanged).
9. **Decommission** the old zone after a soak period (≥1 week; keep
   an export archive in eru).

Note: split-horizon tailnet/localnet overrides live in resolver
views, not Cloudflare — unaffected by the flip, but verify one
override per view answers correctly after cutover.

## 7. Phase D — Cloudflare Tunnel + Access via Terranix

Implements `cloudflare-tunnels-spec.md` with the management decision
revised to Terranix-in-eru.

1. **Tunnel**: `resource.cloudflare_tunnel.orca` in a new
   `tunnel.nix` (locally-managed secret — NOT remote-managed
   `cloudflare_tunnel_config`; ingress stays defined on the host so
   `oxc.ports` remains the single source of truth per spec §3.1B).
   Tunnel credential goes to agenix for the host; the TF-side secret
   lives in R2 state — documented, acceptable per spec §6.
2. **DNS**: `cloudflare_dns_record` — proxied CNAME
   `dawarich.carrio.me` → `<tunnel-id>.cfargotunnel.com`.
3. **Access**: `cloudflare_access_application` +
   `cloudflare_access_policy` for dawarich: Protect (Google IdP —
   requires Google IdP configured in the NEW account's Zero Trust
   org) + path-scoped Bypass for `/api/v1/*` (mobile app API-key
   clients, per spec §3.2–3.3).
4. **Host side**: `hosts/orca/cloudflared.nix` per spec §4 with two
   corrections found against the pinned nixpkgs module
   (e3e32b642a31): there is **no `tunnels.<name>.id` option** — the
   tunnel identity comes from the credentials file; and `default` is
   a plain string (`default = "http_status:404";`), not an attrset.
   Dawarich ingress only: `service =
   "http://127.0.0.1:${toString config.oxc.ports.dawarich}"`.
5. **Verify** per spec §7.1: external Access login → UI; mobile app
   posts to `/api/v1/*` without Access prompt; LAN dig still answers
   the local IP (no Cloudflare hop).

## 8. Phase E — all server hosts move to eru — IMPLEMENTED (2026-10-26)

The orca strategy applied to every remaining server definition;
nothing server-host-related remains in nixcfg (v2 branch). Repos now
split as: **eru = infrastructure + servers**, **nixcfg = common module
surface + workstations + ISO/netboot images**.

- nixcfg exposes `nixosModules.hardware-intel-nuc` (hardware-intel-pc
  + common-gpu-intel) so eru host trees need no nixos-hardware input.
- eru hosts: phoenix (NUC5PPYB, ollama Vulkan), nix-proxy-droplet
  (DO nginx proxy + ACME — acme/cloudflare.age still encrypted to
  orca's recipients only; add the droplet host key before deploy),
  nuc0-9 (shared `hosts/profiles/nuc.nix`, refreshed onto carrionet
  192.168.1.200-209 via `oxc.carrionet.hosts`; grub-legacy-boot now
  composed, which mkHost never did).
- Removed from nixcfg: hosts/orca + orca service secrets (live in
  eru), nuc trees + system-image generators + empty-recipient host-key
  placeholders, phoenix, nix-proxy-droplet, pxe-server and nuc-init
  (unwired/bit-rotted — netboot provider will be rebuilt in eru in a
  later refactor), mixins/servers/nuc-base.nix, mixins/users/pxe.
- Kept in nixcfg: generic-base-image generator, ISO/netboot images,
  mixins/servers/{netboot-api,pixiecore-pxe}.nix (obsidian imports
  pixiecore; the netboot-host refactor follows).

Cutover note: phoenix/nuc fleet/droplet still run their old
generations until each is rebuilt from eru (`nixos-rebuild switch
--flake ~/Code/eru#<host>` or the remote pattern in
eru docs/DEPLOYMENTS.md — confirm per-host build capacity first).

## 9. Sequencing

A (core extraction) → B (orca → eru) → C (zone migration; token
deploy needs B's rebuild path) → D (tunnel; needs C — zone on new
account). C steps 1–5 can run in parallel with A/B.

## 10. Risks

- **NS propagation window**: mitigated by keeping the old zone
  answering identically; delete nothing early.
- **ACME token/zone account mismatch window**: minutes-wide, timed
  between renewal cycles; a failed renewal retries.
- **Universal SSL re-issue on the new zone**: pre-warm proxied
  records before the flip.
- **Provider v5 renames** (`cloudflare_record` →
  `cloudflare_dns_record`, ruleset schema changes): translate, don't
  copy, the cf-terraforming dump.
- **Two-repo drift during transition**: pin the nixcfg tag; orca
  exists in exactly one flake at any time (remove from nixcfg at
  Phase B cutover, not before).
- **agenix + sops coexistence in eru**: two secret systems, one repo
  — document the boundary (agenix = NixOS host secrets, sops/Infisical
  = TF secrets).

## 11. Open decisions (non-blocking)

- Git flake input mechanics: GitHub private repo + deploy key vs
  public repo (nixcfg currently public-ish? verify before pinning).
- Tunnel credential in TF state vs Infisical-sourced.
- Google IdP setup on the new account's Zero Trust org (needs the
  workspace verification records — already in the zone's TXT set).
- Phoenix/nucs migration timing (follow-up plan once orca pattern
  proves out).
