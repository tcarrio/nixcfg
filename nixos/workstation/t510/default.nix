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
  ];

  services.nbd.server = {
    enable = true;
    listenAddress = "0.0.0.0";

    exports = {
      dvd-drive = {
        path = "/dev/sr0";
        allowAddresses = [ "10.0.0.0/8" ];
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
