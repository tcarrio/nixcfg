{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.deb;

  # Homebrew-like semantics for deb packages: a declarative list of package
  # names that `deb-sync` converges towards with apt. Applying the list is
  # non-deterministic (repo state, apt version) and — like brew — removing an
  # entry does NOT uninstall the package; cleanup stays a manual `apt remove`.
  #
  # System binaries are referenced by absolute path because
  # writeShellApplication constrains PATH to its runtimeInputs, and dpkg/apt
  # only exist on the Debian-family host, not in the Nix closure.
  debSync = pkgs.writeShellApplication {
    name = "deb-sync";
    text = ''
      set -euo pipefail

      PACKAGES=(
      ${lib.concatMapStringsSep "\n" (p: "  ${lib.escapeShellArg p}") cfg.packages}
      )

      if [ ''${#PACKAGES[@]} -eq 0 ]; then
        echo "oxc.deb.packages is empty; nothing to sync."
        exit 0
      fi

      missing=()
      for pkg in "''${PACKAGES[@]}"; do
        if /usr/bin/dpkg-query -W -f="''${Status}" "$pkg" 2>/dev/null | /usr/bin/grep -q "install ok installed"; then
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
      exec /usr/bin/sudo /usr/bin/apt-get install -y "''${missing[@]}"
    '';
  };

  debList = pkgs.writeShellApplication {
    name = "deb-list";
    text = ''
      cat <<'EOF'
      ${lib.concatMapStringsSep "\n" (p: p) cfg.packages}
      EOF
    '';
  };
in
{
  options.oxc.deb.packages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      Deb package names managed on non-NixOS Linux hosts. Applied manually
      via `deb-sync` (see the deb:* tasks in Taskfile.yml). Entries are
      installed if missing; removal from this list does not uninstall.
    '';
  };

  config = lib.mkIf (cfg.packages != [ ]) {
    home.packages = [
      debSync
      debList
    ];
  };
}
