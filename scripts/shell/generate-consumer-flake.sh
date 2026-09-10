#!/usr/bin/env bash
set -euo pipefail

# Scaffolds an external consumer flake that imports nixcfg as a flake
# input — the functional equivalent of thomascarrio@greybox expressed as a
# consumer of the nixcfg library, based on numtide/blueprint's
# home-manager-standalone structure (hosts/<host>/users/<user>.nix ->
# homeConfigurations."<user>@<host>" under legacyPackages.<system>).
#
# Inputs are pinned to the same revs as this repo's flake.lock so the
# consumer resolves identically to the internal definition.
#
# Usage: generate-consumer-flake.sh [hostname] [username]
# Defaults: greybox / thomascarrio. Re-runnable; overwrites the tree.
# Output: OUT_DIR (default: ../nixcfg-consumer — outside the repo, since
# nix refuses untracked paths inside a git tree).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/scripts/consumer"
OUT_DIR="${OUT_DIR:-$(dirname "$REPO_ROOT")/nixcfg-consumer}"

HOSTNAME_ARG="${1:-greybox}"
USERNAME_ARG="${2:-thomascarrio}"

# Resolve revs through the ROOT input wiring — flake.lock keeps orphaned
# duplicate nodes (nixpkgs_N, home-manager_N) from follows-graph churn,
# and the top-level names may point at those duplicates instead.
lockrev() { jq -r --arg k "$1" '.nodes.root.inputs[$k] as $n | .nodes[$n].locked.rev' "$REPO_ROOT/flake.lock"; }
NIXPKGS_REV="$(lockrev nixpkgs)"
UNSTABLE_REV="$(lockrev nixpkgs-unstable)"
HM_REV="$(lockrev home-manager)"

# Never clobber an initialized consumer repo — regenerate into a git
# checkout is the user's call (stash/merge), not the generator's.
if [ -e "$OUT_DIR/.git" ] && [ "''${FORCE:-0}" != "1" ]; then
  echo "REFUSING: $OUT_DIR is a git repository (history would be at risk)." >&2
  echo "Re-run with FORCE=1 to overwrite generated files anyway (git-tracked" >&2
  echo "changes will surface as diffs to review; untracked files are replaced)." >&2
  exit 1
fi

mkdir -p "$OUT_DIR/hosts/$HOSTNAME_ARG/users"

subst() {
  sed \
    -e "s|__HOSTNAME__|$HOSTNAME_ARG|g" \
    -e "s|__USERNAME__|$USERNAME_ARG|g" \
    -e "s|__NIXCFG_PATH__|$REPO_ROOT|g" \
    -e "s|__NIXPKGS_REV__|$NIXPKGS_REV|g" \
    -e "s|__NIXPKGS_UNSTABLE_REV__|$UNSTABLE_REV|g" \
    -e "s|__HOME_MANAGER_REV__|$HM_REV|g" \
    "$1" > "$2"
}

subst "$TEMPLATE_DIR/flake.nix.template" "$OUT_DIR/flake.nix"
subst "$TEMPLATE_DIR/user.nix.template" "$OUT_DIR/hosts/$HOSTNAME_ARG/users/$USERNAME_ARG.nix"

echo "Generated consumer flake in $OUT_DIR (outside the repo: nix refuses"
echo "untracked paths inside a git tree, so gitignoring in-repo is not enough)"
echo "Inputs pinned to nixcfg's lock: nixpkgs=$NIXPKGS_REV unstable=$UNSTABLE_REV hm=$HM_REV"
echo "First run / after nixcfg changes: refresh the path input lock:"
echo "  (cd $OUT_DIR && nix flake update nixcfg)"
echo "Validate (blueprint nests homeConfigurations per system):"
echo "  nix eval $OUT_DIR#legacyPackages.x86_64-linux.homeConfigurations.\"$USERNAME_ARG@$HOSTNAME_ARG\".activationPackage.drvPath"
