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

  # Render the sources attrset as a shell case statement resolving a
  # package name to its download URL for the running architecture. The
  # inner case dispatches on uname -m; an empty result means no mapping
  # for this package/architecture.
  # Resolution preference is encoded by apt-sync: repository (unimplemented)
  # > url > upstream apt name.
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

  # Homebrew-like semantics for deb packages: a declarative list of package
  # names that `apt-sync` converges towards with apt. Applying the list is
  # non-deterministic (repo state, apt version) and — like brew — removing an
  # entry does NOT uninstall the package; cleanup stays a manual `apt remove`.
  #
  # Name resolution order: (1) custom apt repository mapping [unimplemented],
  # (2) .deb download URL mapping, (3) plain `apt-get install <name>` against
  # the host's configured repositories.
  #
  # System binaries are referenced by absolute path because
  # writeShellApplication constrains PATH to its runtimeInputs, and dpkg/apt
  # only exist on the Debian-family host, not in the Nix closure.
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

      managed=(
      ${lib.concatMapStringsSep "\n" (p: "  ${lib.escapeShellArg p}") managedPackages}
      )

      if [ ''${#managed[@]} -eq 0 ]; then
        echo "oxc.apt manages no packages; nothing to sync."
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

      if [ ''${#missing[@]} -eq 0 ]; then
        echo "All managed deb packages installed."
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
          # from the configured repositories; the lock timeout rides out
          # unattended-upgrades holding the apt dpkg lock
          /usr/bin/sudo /usr/bin/apt-get -o DPkg::Lock::Timeout=120 install -y "$deb"
          rm -f "$deb"
        elif /usr/bin/apt-cache policy "$pkg" 2>/dev/null | /usr/bin/grep -q "Candidate:"; then
          echo ">> $pkg: installing from configured apt repositories"
          /usr/bin/sudo /usr/bin/apt-get -o DPkg::Lock::Timeout=120 install -y "$pkg"
        else
          echo "!! $pkg: no URL mapping and no apt candidate — its repository is not configured." >&2
          echo "   Add an oxc.apt.sources.<name>.url mapping, or configure the apt repository." >&2
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
        Deb package names managed on non-NixOS Linux hosts, resolved against
        the host's configured apt repositories (upstream Ubuntu/Debian by
        default). Names needing a custom source go in `oxc.apt.sources`
        instead. Applied manually via `apt-sync` (see the deb:* tasks in
        Taskfile.yml). Entries are installed if missing; removal from this
        list does not uninstall.
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
                not available from the configured repositories. Should be a
                "latest" style URL so the mapping survives upstream releases;
                when the URL embeds the Ubuntu release (e.g.
                ..._amd64_24.04.deb), use the ''${ubuntu_version} placeholder
                — apt-sync substitutes the running host's release at runtime.
                Keys are not verified — treat the transport (https) as the
                trust boundary, as apt repository signing is not yet wired up.
              '';
            };
            repository = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Custom apt repository (NOT YET IMPLEMENTED; must stay null).";
            };
          };
        }
      );
      default = { };
      description = ''
        Source mappings for managed deb packages that are not installable
        from the host's configured apt repositories. Keys implicitly join
        the managed set (no need to also list them in `packages`).
        Resolution preference: repository (unimplemented) > url > plain name.
      '';
    };

    onActivation = {
      enable = lib.mkEnableOption "converging managed deb packages during home-manager activation (nix-darwin homebrew-style)";
    };
  };

  config = {
    assertions = [
      {
        assertion = lib.all (src: src.repository == null) (builtins.attrValues cfg.sources);
        message = "oxc.apt.sources.<name>.repository is not implemented yet (sudo/interactive keyring setup unresolved); use url mappings.";
      }
    ];

    home.packages = lib.mkIf (managedPackages != [ ]) [
      aptSync
      aptList
    ];

    # nix-darwin converges its Brewfile via `brew bundle` at activation;
    # the deb equivalent runs apt-sync after the profile is installed.
    # Idempotent — converged state installs nothing and never prompts for
    # sudo; missing packages install interactively (sudo password prompt
    # requires a terminal-run switch); a failed sync fails the switch,
    # matching darwin-rebuild's homebrew semantics.
    home.activation.aptSync = lib.mkIf (cfg.onActivation.enable && managedPackages != [ ]) (
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        $DRY_RUN_CMD echo ">> deb: converging managed packages"
        ${aptSync}/bin/apt-sync
      ''
    );
  };
}
