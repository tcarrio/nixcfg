# Gigabyte GB-BXCEH-2955 (Celeron 2955U: Haswell)

{ inputs, lib, pkgs, hostname, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    ../../mixins/hardware/systemd-boot.nix
    ../../mixins/services/bluetooth.nix
  ];

  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  oxc.services.remote-builder = {
    enable = true;
    hosts.glass = {
      enable = true;
      local = true;
    };
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
    swraid.enable = true;
  };

  # Use passed hostname to configure basic networking
  networking.hostName = hostname;

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp3s0";
    networkConfig = {
      Address = "192.168.40.250/24";
      Gateway = "192.168.40.1";
      DNS = "192.168.40.1";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
