# Motherboard: Supermicro X9SCL/X9SCM
# CPU:         Intel Celeron G1610T (2) @ 2.300GHz
# GPU:         Matrox Electronics Systems Ltd. X9SCM-F Motherboard
# RAM:         16GB DDR3
# SATA:        WD 300GB HDD
# SATA:        Corsair 256G
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD

{ inputs, lib, pkgs, hostname, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    ../../mixins/hardware/grub-legacy-boot.nix
    ../../mixins/services/bluetooth.nix
  ];

  # boot.swraid.enable = true;
  # systemd.services."mdmonitor".environment = {
  #   # Override mdmonitor to log to syslog instead of emailing or alerting
  #   MDADM_MONITOR_ARGS = "--scan --syslog";
  # };

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
