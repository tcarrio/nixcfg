# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        120GB SSD

{ inputs, lib, pkgs, ... }: {
  imports = [
    (import ./disks.nix { })

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # fix for nixos-rebuild hangups on certain hardware
    ../../mixins/hardware/grub-legacy-boot.nix
    ../../mixins/services/pipewire.nix
  ];

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  oxc = {
    services = {
      tailscale.enable = true;
    };
    containerisation = {
      enable = true;
      engine = "podman";
    };
    virtualisation.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  services.nbd.server = {
    enable = false;
    listenAddress = "0.0.0.0";
    listenPort = 10809;

    extraOptions = {
      allowlist = true;
    };

    exports = {
      dvd-drive = {
        path = "/dev/sr0";
        allowAddresses = [ "192.168.40.0/24" "100.0.0.0/8" ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 10809 ];
  networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
