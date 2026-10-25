# nixcfg → eru Refactor: Shared Core + carrio.me Cloudflare Migration

Status: **planned — not started** (2026-10-25)
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

## 4. Phase A — nixcfg core extraction

1. **Audit orca's imports**: everything `nixos/server/orca/*` pulls
   from outside its directory (mixins/hardware/grub-legacy-boot, oxc
   services mixins, `modules/shared` options, overlays, pkgs). This
   list is the minimum surface eru must be able to import.
2. **Expose consumable outputs** from nixcfg's flake:
   `nixosModules` (the mixin trees as importable module lists or a
   flakeModule), `lib` (the host factory helpers), `overlays`,
   `packages`. Host construction in `flake.nix` moves to calls
   against the exposed lib — no behavior change for remaining hosts.
3. **Keep host metadata in `oxc.*` options** (`modules/shared`), not
   specialArgs — already the convention; it is what makes cross-flake
   host building clean (no `inputs`/`hostname` specialArgs leaking
   into eru).
4. **Tag a release** (e.g. `core-v0.1`) for eru to pin.

Exit criteria: eru could `import nixcfg.nixosModules.<x>` and build a
trivial VM host from them; all existing nixcfg hosts still evaluate.

## 5. Phase B — orca moves into eru

1. **eru flake inputs**: `nixcfg` (git, pinned to the tag; dev
   override to local path), nixpkgs following nixcfg's pin,
   home-manager only if orca's config needs it (currently it does
   not — server mixin only).
2. **Host tree**: copy `nixos/server/orca/*` → `hosts/orca/`;
   rewrite relative imports of mixins/shared modules to nixcfg-input
   paths. Add `nixosConfigurations.orca` output (flake-parts top-level
   module; `nixpkgs.lib.nixosSystem` with nixcfg modules + orca tree).
3. **agenix in eru**: move orca's secret files
   (`services/acme/cloudflare.age`, `services/pinchflat/env.age`,
   `services/trek/env.age`, `services/paperless/password.age`, any
   tunnel credential added in Phase D). Same recipients — orca host
   key unchanged, files re-encrypted only if the recipient set
   changes. Add an `agenix` config at eru root; document agenix (NixOS
   hosts) vs sops (TF/Infisical) split in eru's README.
4. **Port map**: `oxc.ports` module stays in nixcfg core; orca's
   `ports.nix` moves with the host.
5. **Rebuild path**: Taskfile targets (`orca:build`,
   `orca:switch`) or update `rebuild-host` alias on orca to point at
   `~/Code/eru#orca`.
6. **Cutover**: build + switch orca from eru; verify generation
   parity (services up, Caddy certs renew path intact); then remove
   orca from nixcfg flake + `secrets/secrets.nix` entries in the same
   window so there is one source of truth.

Exit criteria: `nixos-rebuild switch --flake ~/Code/eru#orca` works;
orca absent from nixcfg outputs.

## 6. Phase C — carrio.me zone migration (old account → new account)

Cloudflare cannot move a zone between accounts; this is
create-replicate-switch.

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
   assignment. Immediately after propagation begins, deploy the new
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

## 8. Sequencing

A (core extraction) → B (orca → eru) → C (zone migration; token
deploy needs B's rebuild path) → D (tunnel; needs C — zone on new
account). C steps 1–5 can run in parallel with A/B.

## 9. Risks

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

## 10. Open decisions (non-blocking)

- Git flake input mechanics: GitHub private repo + deploy key vs
  public repo (nixcfg currently public-ish? verify before pinning).
- Tunnel credential in TF state vs Infisical-sourced.
- Google IdP setup on the new account's Zero Trust org (needs the
  workspace verification records — already in the zone's TXT set).
- Phoenix/nucs migration timing (follow-up plan once orca pattern
  proves out).
