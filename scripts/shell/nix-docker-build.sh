#!/usr/bin/env bash
set -euo pipefail

# Cross-platform nix derivation builder for nixcfg.
#
# Builds foreign-architecture derivations (e.g. x86_64-linux from an
# arm64 Mac) inside Docker, with a committed-image nix store cache so
# substituted paths survive between runs.
#
# Usage:
#   nix-docker-build.sh [options] <flake-attribute>
#
# Options:
#   --platform <plat>   docker platform (default: linux/amd64)
#   --mode <mode>       eval | dry-run | build | shell (default: build)
#   --no-cache          do not reuse or refresh the warm-store cache image
#   --prune-cache       remove the cache image after the run
#   -h | --help         this help
#
# Examples:
#   nix-docker-build.sh 'homeConfigurations."tcarrio@obsidian".activationPackage'
#   nix-docker-build.sh --mode eval 'nixosConfigurations.obsidian.config.system.build.toplevel'
#   nix-docker-build.sh --mode shell
#
# Modes:
#   eval      evaluate the derivation path only (.drvPath is appended) —
#             works under any emulation, no builds performed
#   dry-run   resolve what would be fetched vs built from source
#   build     full build to a store path
#   shell     interactive shell in the warm image (for triage)
#
# Known limitation (colima + QEMU/binfmt WITHOUT Rosetta): from-source
# builds fail with
#     error: getting pseudoterminal attributes: Function not implemented
# The emulated perl build loop cannot allocate a PTY. Evaluation and
# substitution are unaffected. Remedies, in order of preference:
#   1. Install Rosetta and restart colima with `colima start --vz-rosetta`
#   2. Build on a native x86_64 host (e.g. orca over ssh-ng remote build)
#   3. Use --mode eval / --mode dry-run for validation short of building
#
# Operational notes:
#   - Bind mounts must live under the macOS home (colima virtiofs does
#     not share /tmp); this script mounts the repo, wherever it lives.
#   - The build container is named and always removed; the nix store is
#     preserved by `docker commit` into the cache image on every run
#     (including failures — partial downloads are valuable).
#   - Requires the docker VM to have >= 4 GiB memory (2 GiB OOM-kills
#     real builds); warn-only check below.

SCRIPT_NAME="$(basename "$0")"

usage() { sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'; }

die() { echo "ERROR: $*" >&2; exit 1; }

PLATFORM="linux/amd64"
MODE="build"
USE_CACHE=1
PRUNE_CACHE=0
ATTR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --platform) PLATFORM="${2:?}"; shift 2 ;;
    --mode) MODE="${2:?}"; shift 2 ;;
    --no-cache) USE_CACHE=0; shift ;;
    --prune-cache) PRUNE_CACHE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1" ;;
    *) ATTR="$1"; shift ;;
  esac
done

[ "$MODE" = "shell" ] || [ -n "$ATTR" ] || die "a flake attribute is required (see --help)"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[ -d "$REPO_ROOT/flake.nix" ] || [ -f "$REPO_ROOT/flake.nix" ] || die "flake.nix not found at $REPO_ROOT"

command -v docker >/dev/null 2>&1 || die "docker not found"
docker info >/dev/null 2>&1 || die "docker daemon not reachable"

# Resource guards (warn-only)
MEM_BYTES="$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo 0)"
if [ "$MEM_BYTES" -gt 0 ] && [ "$MEM_BYTES" -lt 4294967296 ]; then
  echo "WARN: docker VM has < 4 GiB memory; real builds may OOM." >&2
  echo "      colima stop && colima start --cpu 6 --memory 10" >&2
fi

PLATFORM_TAG="$(echo "$PLATFORM" | tr '/_' '--')"
BASE_IMAGE="nixos/nix:latest"
CACHE_IMAGE="nixcfg-builder:warm-${PLATFORM_TAG}"
CONTAINER="nixcfg-builder-$$"

if [ "$USE_CACHE" -eq 1 ] && docker image inspect "$CACHE_IMAGE" >/dev/null 2>&1; then
  RUN_IMAGE="$CACHE_IMAGE"
  echo ">> using warm cache image $CACHE_IMAGE"
else
  RUN_IMAGE="$BASE_IMAGE"
  echo ">> no cache image; starting from $BASE_IMAGE"
fi

INNER=$(cat <<'EOF'
set -u
export NIX_CONFIG="experimental-features = nix-command flakes pipe-operators"
cd /src || exit 11
case "${MODE:?}" in
  eval)
    nix eval --raw ".#${ATTR:?}.drvPath" && echo "EVAL-OK" > /tmp/status || echo "EVAL-FAIL" > /tmp/status
    ;;
  dry-run)
    # Full output preserved for post-run analysis; the trailing summary
    # lines (these N derivations will be built / fetched) are what matter.
    nix build --dry-run ".#${ATTR:?}" > /tmp/dryrun.log 2>&1
    grep -E "^this derivation|^these [0-9]+ derivations|^these [0-9]+ paths" /tmp/dryrun.log | tail -6
    echo "DRYRUN-DONE" > /tmp/status
    ;;
  build)
    if nix --option sandbox relaxed --print-build-logs build ".#${ATTR:?}" \
        --no-link --out-link /tmp/result; then
      echo "BUILD-OK" > /tmp/status
      readlink -f /tmp/result
    else
      echo "BUILD-FAIL" > /tmp/status
    fi
    ;;
  shell)
    exec bash -i
    ;;
esac
EOF
)

cleanup() {
  # Preserve the warmed store (downloads survive failures), then remove
  # the container so nothing accumulates.
  if [ "$USE_CACHE" -eq 1 ] && docker inspect "$CONTAINER" >/dev/null 2>&1; then
    docker commit "$CONTAINER" "$CACHE_IMAGE" >/dev/null 2>&1 \
      && echo ">> committed store to $CACHE_IMAGE" \
      || echo ">> WARN: cache commit failed"
  fi
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  if [ "$PRUNE_CACHE" -eq 1 ]; then
    docker rmi "$CACHE_IMAGE" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

case "$MODE" in
  shell)
    docker run -it --rm --name "$CONTAINER" --platform "$PLATFORM" \
      --mount "type=bind,src=$REPO_ROOT,dst=/src,readonly" \
      -e MODE=shell -e ATTR= \
      "$RUN_IMAGE" bash -c "$INNER"
    ;;
  *)
    docker run -d --name "$CONTAINER" --platform "$PLATFORM" \
      --mount "type=bind,src=$REPO_ROOT,dst=/src,readonly" \
      -e MODE="$MODE" -e ATTR="$ATTR" \
      "$RUN_IMAGE" bash -c "$INNER"
    echo ">> build started in $CONTAINER ($PLATFORM, mode=$MODE)"
    docker logs -f "$CONTAINER" 2>&1 | tee /tmp/nix-docker-build-$$.log | grep -vE '^(downloading|copying path|unpacking) ' &
    LOGPIPE=$!
    wait $LOGPIPE || true

    OUT="$(docker logs "$CONTAINER" 2>&1)"
    docker cp "$CONTAINER:/tmp/dryrun.log" "/tmp/nix-docker-build-$$.dryrun.log" 2>/dev/null || true
    STATUS="$(docker logs "$CONTAINER" 2>&1 | grep -oE '(EVAL-OK|EVAL-FAIL|BUILD-OK|BUILD-FAIL|DRYRUN-DONE)' | tail -1)"

    if echo "$OUT" | grep -q 'pseudoterminal attributes: Function not implemented'; then
      echo ""
      echo "!! PTY allocation failed under $(uname -m) emulation." >&2
      echo "   From-source builds need Rosetta or a native builder:" >&2
      echo "     softwareupdate --install-rosetta   # once, on the Mac" >&2
       echo "     colima stop && colima start --cpu 6 --memory 10 --vz-rosetta" >&2
      echo "   Or build remotely on a native x86_64 host." >&2
      exit 78
    fi

    case "$STATUS" in
      EVAL-OK|BUILD-OK|DRYRUN-DONE) exit 0 ;;
      *) echo ">> $MODE failed:"; echo "$OUT" | tail -20; exit 1 ;;
    esac
    ;;
esac
