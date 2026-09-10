{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.apt;

  # Managed set: plain names resolved from the host's configured apt
  # repositories, plus any name with an explicit source mapping.
  managedPackages = cfg.packages ++ (lib.attrNames cfg.sources);

  hasRepositories = cfg.repositories != { };

  # uname -m value per nix system for the runtime arch dispatch
  archMatch = {
    x86_64-linux = "x86_64";
    aarch64-linux = "aarch64";
  };

  # dpkg-query -f format is single-quoted in the rendered script so bash
  # never expands it — dpkg performs the ${Status} substitution itself.
  # Assembled from plain strings to avoid Nix ''-quote escape ambiguity:
  # dollar + brace as separate literals cannot be parsed as interpolation.
  dpkgFormat = "$" + "{Status}";
  dpkgCheck = ''
    if /usr/bin/dpkg-query -W -f='${dpkgFormat}' "$pkg" 2>/dev/null | /usr/bin/grep -q "install ok installed"; then
  '';

  # Deterministic build-time keyring: the armored public key is defined
  # inline in the configuration; dearmoring it here means /etc/apt/keyrings
  # receives a normal gpg keyring and apt's signed-by check is exact.
  repoKeyring =
    name: repo:
    pkgs.runCommand "${name}-archive-keyring.gpg" {
      nativeBuildInputs = [ pkgs.gnupg ];
    } ''
      gpg --dearmor --output "$out" "${pkgs.writeText "${name}-archive-keyring.asc" repo.key.text}"
    '';

  # Classic one-line sources entry (matches vendor documentation format):
  # deb [signed-by=/etc/apt/keyrings/<name>.gpg] <url> <suites...> <components...>
  repoSourcesLine =
    name: repo:
    "deb [signed-by=/etc/apt/keyrings/${name}.gpg] ${repo.url} ${
      lib.concatStringsSep " " (repo.suites ++ repo.components)
    }";

  repoSetup =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: repo:
        "ensure_repo ${lib.escapeShellArg name} ${lib.escapeShellArg "${repoKeyring name repo}"} ${
          lib.escapeShellArg (repoSourcesLine name repo)
        }"
      ) cfg.repositories
    );

  # Render the sources attrset as a shell case statement resolving a
  # package name to its download URL for the running architecture. The
  # inner case dispatches on uname -m; an empty result means no mapping
  # for this package/architecture.
  # Resolution preference is encoded by apt-sync: repository (top-level
  # oxc.apt.repositories) > url > upstream apt name.
  urlResolver =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: src:
        let
          # Single-quoted so runtime placeholders (''${ubuntu_version}) reach
          # apt-sync literally instead of expanding at case-evaluation.
          archCases = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              system: url: ''            ${archMatch.${system}}) echo ${lib.escapeShellArg url} ;;''
            ) src.url
          );
        in
        ''
          ${lib.escapeShellArg name})
            case "$(uname -m)" in
          ${archCases}
            esac
            ;;
        ''
      ) cfg.sources
    );

  # Homebrew-like semantics for apt packages: a declarative list of package
  # names and repositories that `apt-sync` converges towards with apt.
  # Applying is non-deterministic (repo state, apt version) and — like brew
  # without cleanup — removing an entry does NOT uninstall the package or
  # remove the repository's keyring/sources files; cleanup stays manual.
  #
  # Package name resolution order: (1) a repository managed under
  # oxc.apt.repositories (repo configured + apt update, then plain name),
  # (2) .deb download URL mapping, (3) plain `apt-get install <name>`
  # against the host's pre-configured repositories.
  #
  # System binaries are referenced by absolute path because
  # writeShellApplication constrains PATH to its runtimeInputs, and
  # dpkg/apt only exist on the Debian-family host, not in the Nix closure.
  aptSync = pkgs.writeShellApplication {
    name = "apt-sync";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      set -euo pipefail

      resolve_url() {
        case "$1" in
      ${urlResolver}
        esac
        # no mapping (or no URL for this architecture)
        echo ""
      }

      # Idempotent repository registration: installs the dearmored keyring
      # to /etc/apt/keyrings/<name>.gpg and the sources entry to
      # /etc/apt/sources.list.d/<name>.list only when content differs
      # (cmp-guarded) — converged repos cost zero sudo.
      REPO_CHANGED=0
      ensure_repo() {
        local name="$1" keyring_src="$2" sources_line="$3"
        local keyring_dst="/etc/apt/keyrings/''${name}.gpg"
        local sources_dst="/etc/apt/sources.list.d/''${name}.list"
        if ! /usr/bin/cmp -s "$keyring_src" "$keyring_dst" 2>/dev/null; then
          echo ">> repo $name: installing keyring -> $keyring_dst"
          /usr/bin/sudo /usr/bin/install -d -m 0755 /etc/apt/keyrings
          /usr/bin/sudo /usr/bin/install -D -m 0644 "$keyring_src" "$keyring_dst"
          REPO_CHANGED=1
        fi
        if [ ! -f "$sources_dst" ] || ! printf '%s\n' "$sources_line" | /usr/bin/cmp -s - "$sources_dst"; then
          echo ">> repo $name: writing $sources_dst"
          printf '%s\n' "$sources_line" | /usr/bin/sudo /usr/bin/tee "$sources_dst" >/dev/null
          REPO_CHANGED=1
        fi
      }
      ${lib.optionalString hasRepositories repoSetup}

      managed=(
      ${lib.concatMapStringsSep "\n" (p: "  ${lib.escapeShellArg p}") managedPackages}
      )

      if [ ''${#managed[@]} -eq 0 ] && [ "$REPO_CHANGED" -eq 0 ]; then
        echo "oxc.apt manages no packages or repositories; nothing to sync."
        exit 0
      fi

      missing=()
      for pkg in "''${managed[@]}"; do
      ${dpkgCheck}
          echo "ok      $pkg"
        else
          missing+=("$pkg")
        fi
      done

      if [ ''${#missing[@]} -eq 0 ] && [ "$REPO_CHANGED" -eq 0 ]; then
        echo "All managed apt state converged."
        exit 0
      fi

      # index refresh only when something actually changed or is missing —
      # converged runs stay offline-safe; the lock timeout rides out
      # unattended-upgrades holding the dpkg lock
      echo ">> apt: updating package index"
      /usr/bin/sudo /usr/bin/apt-get -o DPkg::Lock::Timeout=120 update

      if [ ''${#missing[@]} -eq 0 ]; then
        echo "Repositories configured; no packages missing."
        exit 0
      fi

      echo "Installing: ''${missing[*]}"
      # Ubuntu release (e.g. 24.04) for the ''${ubuntu_version} URL placeholder
      ubuntu_version=""
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release 2>/dev/null || true
        ubuntu_version="''${VERSION_ID:-}"
      fi
      for pkg in "''${missing[@]}"; do
        url="$(resolve_url "$pkg")"
        # runtime substitution of the ubuntu_version placeholder
        url="''${url//\$\{ubuntu_version\}/$ubuntu_version}"
        if [ -n "$url" ]; then
          echo ">> $pkg: downloading $url"
          deb="$(mktemp --suffix=.deb)"
          curl -fL "$url" -o "$deb"
          # path-qualified install: apt resolves the local .deb's dependencies
          # from the configured repositories
          /usr/bin/sudo /usr/bin/apt-get -o DPkg::Lock::Timeout=120 install -y "$deb"
          rm -f "$deb"
        elif /usr/bin/apt-cache policy "$pkg" 2>/dev/null | /usr/bin/grep -q "Candidate:"; then
          echo ">> $pkg: installing from configured apt repositories"
          /usr/bin/sudo /usr/bin/apt-get -o DPkg::Lock::Timeout=120 install -y "$pkg"
        else
          echo "!! $pkg: no URL mapping and no apt candidate — its repository is not configured." >&2
          echo "   Add an oxc.apt.sources.<name>.url mapping or an oxc.apt.repositories entry." >&2
          exit 1
        fi
      done
    '';
  };

  aptList = pkgs.writeShellApplication {
    name = "apt-list";
    text = ''
      cat <<'EOF'
      ${lib.concatMapStringsSep "\n" (p: p) managedPackages}
      EOF
    '';
  };
in
{
  options.oxc.apt = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Apt package names managed on non-NixOS Linux hosts, resolved against
        the host's configured apt repositories — including any managed via
        oxc.apt.repositories. Names needing a .deb download instead go in
        `oxc.apt.sources`. Entries are installed if missing; removal from
        this list does not uninstall.
      '';
    };

    repositories = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.str;
              description = "Repository URI (the apt source origin)";
            };
            suites = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Suite names (e.g. [ \"stable\" ] or [ \"./\" ] for flat repos)";
            };
            components = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "main" ];
              description = "Components (e.g. [ \"main\" ])";
            };
            key = {
              text = lib.mkOption {
                type = lib.types.str;
                description = ''
                  ASCII-armored public key INLINED in the configuration — the
                  definition is the source of truth, deterministic like any
                  flake derivation input. dearmored at build time and
                  installed to /etc/apt/keyrings/<name>.gpg.
                '';
              };
              fingerprint = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Expected key fingerprint (documentation/audit aid; not machine-checked)";
              };
            };
          };
        }
      );
      default = { };
      description = ''
        Custom apt repositories to manage: keyring under /etc/apt/keyrings,
        sources entry under /etc/apt/sources.list.d, then `apt update` and
        plain-name package installs. Idempotent and cmp-guarded — converged
        repositories cost zero sudo. Removal of an entry does not uninstall
        the repository files (brew-without-cleanup semantics).
      '';
    };

    sources = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = ''
                Per-system .deb download URLs (keys are nix systems:
                x86_64-linux, aarch64-linux). Preferred when a package is
                not available from any configured repository. Should be a
                "latest" style URL so the mapping survives upstream releases;
                when the URL embeds the Ubuntu release (e.g.
                ..._amd64_24.04.deb), use the ''${ubuntu_version} placeholder
                — apt-sync substitutes the running host's release at runtime.
                Prefer oxc.apt.repositories when the vendor provides a signed
                repository; keys are not verified for raw URL downloads —
                treat the transport (https) as the trust boundary.
              '';
            };
          };
        }
      );
      default = { };
      description = ''
        Source mappings for managed packages not installable from any
        configured apt repository. Keys implicitly join the managed set
        (no need to also list them in `packages`). Resolution preference:
        repository > url > plain name.
      '';
    };

    onActivation = {
      enable = lib.mkEnableOption "converging managed apt state during home-manager activation (nix-darwin homebrew-style)";
    };
  };

  config = {
    home.packages = lib.mkIf (managedPackages != [ ] || hasRepositories) [
      aptSync
      aptList
    ];

    # nix-darwin converges its declarative Brewfile via `brew bundle` at
    # activation; the apt equivalent runs apt-sync after the profile is
    # installed. Idempotent — converged state installs nothing and never
    # prompts for sudo; missing packages or changed repositories install
    # interactively (sudo password prompt requires a terminal-run switch);
    # a failed sync fails the switch, matching darwin-rebuild's homebrew
    # semantics.
    home.activation.aptSync = lib.mkIf (cfg.onActivation.enable && (managedPackages != [ ] || hasRepositories)) (
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        $DRY_RUN_CMD echo ">> apt: converging managed state"
        ${aptSync}/bin/apt-sync
      ''
    );
  };
}
