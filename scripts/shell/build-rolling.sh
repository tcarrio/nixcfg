#!/usr/bin/env bash

# A simple sequential build script for Nix flakes.
# Caching should be handled automatically by FlakeHub.
# Future optimizations may include better parallelization of builds.
#
# Currently, this is a sequential execution of `nix build` commands,
# each with only a single target.

outputs="$(nix flake show --json 2>/dev/null)"
current_system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

arch="$(echo $current_system | cut -d'-' -f1)"
os="$(echo $current_system | cut -d'-' -f2)"

SYSTEM_SPECIFIC_OUTPUTS=(
    "devShells"
    "packages"
)

DARWIN_SPECIFIC_OUTPUTS=(
    "darwinConfigurations"
)

LINUX_SPECIFIC_OUTPUTS=(
    "nixosConfigurations"
    "linuxPackages"
)

GENERAL_OUTPUTS=(
    "homeConfigurations"
)

jq_keys_of_outputs() {
    key="$1"

    echo $outputs | jq -r "(.$key // {}) | keys | .[]"
}

build_packages() {
    target_system="$1"

    while read pname
    do
        echo "Found package $pname for $target_system"
        echo "Starting build for $targetSystem.$pname"
        nix build ".#packages.$target_system.$pname"
    done < <(jq_keys_of_outputs "packages[\"$target_system\"]")
}

build_dev_shells() {
    target_system="$1"

    while read sname
    do
        echo "Found devShell $sname for $target_system"

        if nix eval .#devShells.aarch64-darwin."signalapp/Signal-Desktop" 1>/dev/null 2>/dev/null; then
            echo "Starting build for $targetSystem.$sname"
            nix build ".#devShells.$target_system.$sname"
        else
            echo "Skipping devShell $sname for $target_system, evaluation failed"
        fi
    done < <(jq_keys_of_outputs "devShells[\"$target_system\"]")
}

build_darwin_configurations() {
    target_system="$1"

    while read cname
    do
        echo "Found darwinConfiguration $cname for $target_system"
        host_system="$(nix eval .#darwinConfigurations.$cname.config.nixpkgs.hostPlatform.system 2>/dev/null | jq -r)"
        if [ "$host_system" = "$target_system" ]; then
            echo "Building Darwin configuration $cname for $target_system"
            nix build ".#darwinConfigurations.$cname"
        else
            echo "Skipping $cname expecting $host_system on $target_system"
        fi
    done < <(jq_keys_of_outputs "darwinConfigurations")
}

build_nixos_configurations() {
    target_system="$1"

    while read cname
    do
        echo "Found nixosConfiguration $cname for $target_system"
        host_system="$(nix eval .#nixosConfigurations.$cname.config.nixpkgs.hostPlatform.system 2>/dev/null | jq -r)"
        if [ "$host_system" = "$target_system" ]; then
            echo "Building NixOS configuration $cname for $target_system"
            nix build ".#nixosConfigurations.$cname"
        else
            echo "Skipping $cname expecting $host_system on $target_system"
        fi
    done < <(jq_keys_of_outputs "nixosConfigurations")
}

build_home_configurations() {
    target_system="$1"

    while read cname
    do
        echo "Found homeConfiguration $cname for $target_system"
    done < <(jq_keys_of_outputs "homeConfigurations")
}

build_packages $current_system
build_dev_shells $current_system

case "$os" in
    linux)
        build_nixos_configurations $current_system
        ;;
    darwin)
        echo "TODO: Introspection of darwinConfigurations keys"
        ;;
    *)
        ;;
esac

echo "No further actions taken for $current_system"
