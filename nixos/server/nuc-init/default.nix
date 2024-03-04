# Gigabyte GB-BXCEH-2955 (Celeron 2955U: Haswell)

{ inputs, lib, pkgs, ... }:
let
  mkNetwork = mac: ipSuffix: {
    matchConfig.MACAddress = mac;
    networkConfig = {
      Address = "192.168.1.${ipSuffix}/24";
      Gateway = "192.168.1.1";
      DNS = "192.168.1.1";
    };
  };
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # (import ./disks.nix { })
    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/services/bluetooth.nix
    ../../_mixins/virt
  ];

  # disable swap
  # swapDevices = [{
  #   device = "/swap";
  #   size = 2048;
  # }];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  systemd.network.networks = {
    "10-lan-200" = mkNetwork "f4:4d:30:61:9b:19" "200";
    "10-lan-201" = mkNetwork "f4:4d:30:62:4c:26" "201";
    "10-lan-202" = mkNetwork "f4:4d:30:61:99:ab" "202";
    "10-lan-203" = mkNetwork "f4:4d:30:61:8c:cf" "203";
    "10-lan-204" = mkNetwork "f4:4d:30:61:99:ad" "204";
    "10-lan-205" = mkNetwork "f4:4d:30:61:8a:9d" "205";
    "10-lan-206" = mkNetwork "f4:4d:30:62:4a:76" "206";
    "10-lan-207" = mkNetwork "f4:4d:30:62:4a:43" "207";
    "10-lan-208" = mkNetwork "f4:4d:30:61:9a:e0" "208";
    "10-lan-209" = mkNetwork "f4:4d:30:61:99:ed" "209";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
