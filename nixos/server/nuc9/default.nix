# Host: Intel Corporation NUC5PPYB
# CPU: Intel Pentium N3700 (4) @ 2.400GHz
# GPU: Intel Atom/Celeron/Pentium Processor x5-E8000/J3xxx/N3xxx
# Memory: 7877MiB

{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../_mixins/hardware/systemd-boot.nix
    ../../_mixins/services/bluetooth.nix
    ../../_mixins/services/tailscale-autoconnect.nix
    ../../_mixins/virt
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "enp2s0";
    networkConfig = {
      Address = "192.168.1.209/24";
      Gateway = "192.168.1.1";
      DNS = "192.168.1.1";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
