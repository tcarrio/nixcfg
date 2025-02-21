{ lib, config, ... }:
let
  cfg = config.oxc.services.auto-install;
in
{
  options.oxc.services.flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for Flatpak";
    };

    flathub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the Flathub repository for Flatpak";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    services.journald.console = "/dev/tty1";

    nix.settings.substituters = lib.mkForce [];

    systemd.services.install = {
      description = "Bootstrap a NixOS installation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "polkit.service" ];
      path = [ "/run/current-system/sw/" ];
      script = with pkgs; ''
        # this is just for debugging purposes, can be removed when it all works
        echo 'journalctl -fb -n100 -uinstall' >> ~nixos/.bash_history

        set -euxo pipefail

        wait-for() {
          for _ in seq 10; do
            if $@; then
              break
            fi
            sleep 1
          done
        }

        dev=/dev/sda
        [ -b /dev/nvme0n1 ] && dev=/dev/nvme0n1
        [ -b /dev/vda ] && dev=/dev/vda

        # the cryptic type stands for "EFI system partition"
        ${utillinux}/bin/sfdisk --wipe=always "$dev" <<-END
          label: gpt

          name=BOOT, size=512MiB, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
          name=SWAP, size=8GiB, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F
          name=NIXOS
        END

        sync

        wait-for [ -b /dev/disk/by-partlabel/BOOT ]
        wait-for mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/BOOT

        wait-for [ -b /dev/disk/by-partlabel/SWAP ]
        wait-for mkswap -L swap /dev/disk/by-partlabel/SWAP


        wait-for [ -b /dev/disk/by-partlabel/NIXOS ]
        mkfs.ext4 -L nixos /dev/disk/by-partlabel/NIXOS

        sync
        wait-for [ -b /dev/disk/by-label/swap ]
        swapon /dev/disk/by-label/swap

        wait-for [ -b /dev/disk/by-label/nixos ]
        mount /dev/disk/by-label/nixos /mnt

        mkdir /mnt/boot
        wait-for mount /dev/disk/by-label/boot /mnt/boot


        mkdir -p /mnt/etc/nixos
        cp -r ${./configuration}/* /mnt/etc/nixos/
        chmod -R 755 /mnt/etc/nixos

        # add parameters so that nix does not try to contact a cache as we expect
        # to be offline anyway
        ${config.system.build.nixos-install}/bin/nixos-install \
          --system ${evaluatedSystem.config.system.build.toplevel} \
          --no-root-passwd \
          --cores 0

        echo 'Done. Shutting off.'
        ${systemd}/bin/systemctl poweroff
      '';
      environment = config.nix.envVars // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/root";
      };
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}