{ inputs, lib, pkgs, ... }:
let
  ethIface = "enp2s0";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ../disks/nuc-sata-ext4.nix { })
  ];

  oxc.services.tailscale.enable = true;
  oxc.services.wait-online.enable = true;
  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  # ensure we aren't defaulting to NetworkManager with DHCP on
  networking.useDHCP = false;
  networking.interfaces."${ethIface}".wakeOnLan.enable = true;

  systemd.network.enable = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "${ethIface}";
    networkConfig = {
      # Address must be provided via systemd.network.networks."10-lan".networkConfig.Address
      Gateway = "192.168.40.1";
      DNS = "192.168.40.1";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
