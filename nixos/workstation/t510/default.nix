# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        120GB SSD

{ inputs, lib, config, pkgs, modulesPath, ... }:
let
  containerization = "docker";
in
{
  imports = [
    # TODO: Incorporate diskos
    # (import ./disks.nix { })
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../_mixins/hardware/systemd-boot.nix
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

  services = {
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
