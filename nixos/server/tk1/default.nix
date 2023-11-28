# Nvidia Tegra K1 Devboard

{ inputs, lib, pkgs, ... }:
{
  imports = [
    ../_mixins/virt
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" "sd_nod" ];
    kernelModules = [];

    # TODO: validate newer version with U-Boot
    kernelPackages = lib.mkDefault pkgs.linuxPackages_4_9;
  };

  # Use passed hostname to configure basic networking
  networking = {
    defaultGateway = "192.168.1.1";
    interfaces.enp3s0.ipv4.addresses = [{
      address = "192.168.1.185"; # test IP
      prefixLength = 24;
    }];
    nameservers = [ "192.168.1.1" ];
    useDHCP = lib.mkForce false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "armv7l-linux";
}
