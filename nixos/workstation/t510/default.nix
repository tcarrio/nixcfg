# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        120GB SSD

{ inputs, lib, pkgs, ... }: {
  imports = [
    # TODO: Incorporate diskos
    (import ./disks.nix { })
    # ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # fix for nixos-rebuild hangups on certain hardware
    ../../_mixins/hardware/disable-nm-wait.nix
    ../../_mixins/hardware/grub-legacy-boot.nix
    ../../_mixins/services/pipewire.nix
    ../../_mixins/services/tailscale.nix
    ../../_mixins/virt
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  environment.systemPackages = with pkgs; [
    zoom-us
  ];

  services.nbd.server = {
    enable = true;
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
