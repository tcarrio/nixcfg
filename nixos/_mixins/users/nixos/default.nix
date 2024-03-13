{ config, desktop, lib, pkgs, sshMatrix, username, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  install-system = pkgs.writeScriptBin "install-system" ''
    #!${pkgs.stdenv.shell}

    #set -euo pipefail

    TARGET_HOST="''${1:-}"
    TARGET_USER="''${2:-tcarrio}"
    TARGET_TYPE="''${3:-}"

    if [ "$(id -u)" -eq 0 ]; then
      echo "ERROR! $(basename "$0") should be run as a regular user"
      exit 1
    fi

    if [ ! -d "$HOME/0xc/nix-config/.git" ]; then
      git clone https://github.com/tcarrio/nix-config.git "$HOME/0xc/nix-config"
    fi

    pushd "$HOME/0xc/nix-config"

    if [[ -z "$TARGET_HOST" ]]; then
      echo "ERROR! $(basename "$0") requires a hostname as the first argument"
      echo "       The following hosts are available"
      ls -1 nixos/*/default.nix | cut -d'/' -f2 | grep -v iso
      exit 1
    fi

    if [[ -z "$TARGET_USER" ]]; then
      echo "ERROR! $(basename "$0") requires a username as the second argument"
      echo "       The following users are available"
      ls -1 nixos/_mixins/users/ | grep -v -E "nixos|root"
      exit 1
    fi

    if [[ -z "$TARGET_TYPE" ]]; then
      echo "ERROR! $(basename "$0") requires a type as the third argument"
      echo "       The following types are available"
      ls -1 nixos/ | grep -v -E "nixos|root|_mixins"
      exit 1
    fi

    TARGET_HOST_ROOT="nixos/$TARGET_TYPE/$TARGET_HOST"

    if [ ! -e "$TARGET_HOST_ROOT/disks.nix" ]; then
      echo "ERROR! $(basename "$0") could not find the required $TARGET_HOST_ROOT/disks.nix"
      exit 1
    fi

    # Check if the machine we're provisioning expects a keyfile to unlock a disk.
    # If it does, generate a new key, and write to a known location.
    if grep -q "data.keyfile" "$TARGET_HOST_ROOT/disks.nix"; then
      echo -n "$(head -c32 /dev/random | base64)" > /tmp/data.keyfile
    fi

    echo "WARNING! The disks in $TARGET_HOST are about to get wiped"
    echo "         NixOS will be re-installed"
    echo "         This is a destructive operation"
    echo
    read -p "Are you sure? [y/N]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo true

      sudo nix run github:nix-community/disko \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        -- \
        --mode zap_create_mount \
        "$TARGET_HOST_ROOT/disks.nix"

      sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

      # Rsync nix-config to the target install and set the remote origin to SSH.
      rsync -a --delete "$HOME/0xc/" "/mnt/home/$TARGET_USER/0xc/"
      pushd "/mnt/home/$TARGET_USER/0xc/nix-config"
      git remote set-url origin git@github.com:tcarrio/nix-config.git
      popd

      # If there is a keyfile for a data disk, put copy it to the root partition and
      # ensure the permissions are set appropriately.
      if [[ -f "/tmp/data.keyfile" ]]; then
        sudo cp /tmp/data.keyfile /mnt/etc/data.keyfile
        sudo chmod 0400 /mnt/etc/data.keyfile
      fi
    fi
  '';
in
{
  # Only include desktop components if one is supplied.
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;

  # TODO: Determine cause of error in
  # nix.registry.nixpkgs.to.path

  config.users.users.nixos = {
    description = "NixOS";
    extraGroups = [
      "audio"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    group = "nixos";
    isNormalUser = true;
    homeMode = "0755";

    hashedPassword = "$6$FGMdV6JzcaHdCnQt$yOu9i9B2NOxsb6MPg1yxgNOifyMC/QveHsADtTuTvxpahf0yb610y.fCkQolYgdAp4Ih1zHsRQS9U71yh5.iS1";
    openssh.authorizedKeys.keys = with sshMatrix.systems.glass; [
      tcarrio
      host
    ];

    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
  config.users.groups.nixos = {};

  config.system.stateVersion = lib.mkForce lib.trivial.release;
  config.environment.systemPackages = [ install-system ];
  config.services.kmscon.autologinUser = "${username}";
}
