{
  lib,
  writeShellApplication,
  # Source of this flake (`self`). Inputs are resolved against its flake.lock
  # via `--inputs-from`, so every shell uses the exact revs nixcfg has pinned.
  nixcfgSource,
}:

writeShellApplication {
  name = "devshell-for";

  # Use the host `nix` (daemon-compatible) rather than pinning one here.
  text = ''
    usage() {
      cat <<'EOF'
    Usage: devshell-for <input> <package>... [-- <command> [args...]]

    Enter a shell with packages taken from a pinned nixcfg nixpkgs input.

    Inputs (aliases coerce to the flake input name):
      nixpkgs
      nixpkgs-unstable, unstable
      nixpkgs-trunk, trunk
      nixpkgs-staging, staging

    Examples:
      devshell-for trunk nodejs_24
      devshell-for unstable nodejs_24 pnpm -- node --version
    EOF
    }

    if [ "$#" -lt 2 ]; then
      usage >&2
      exit 2
    fi

    case "$1" in
      -h|--help) usage; exit 0 ;;
      nixpkgs) input=nixpkgs ;;
      nixpkgs-unstable|unstable) input=nixpkgs-unstable ;;
      nixpkgs-trunk|trunk) input=nixpkgs-trunk ;;
      nixpkgs-staging|staging) input=nixpkgs-staging ;;
      *)
        echo "devshell-for: unknown input '$1'" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift

    installables=()
    while [ "$#" -gt 0 ]; do
      if [ "$1" = "--" ]; then
        shift
        break
      fi
      installables+=("$input#$1")
      shift
    done

    if [ "''${#installables[@]}" -eq 0 ]; then
      echo "devshell-for: no packages given" >&2
      exit 2
    fi

    cmd=()
    if [ "$#" -gt 0 ]; then
      cmd=(-c "$@")
    fi

    exec nix --extra-experimental-features "nix-command flakes" \
      shell --inputs-from "path:${nixcfgSource}" \
      "''${installables[@]}" "''${cmd[@]}"
  '';

  meta = {
    description = "Enter a shell with packages from a pinned nixcfg nixpkgs input (nixpkgs, unstable, trunk)";
    mainProgram = "devshell-for";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
