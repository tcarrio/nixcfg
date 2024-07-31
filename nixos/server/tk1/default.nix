# Nvidia Tegra K1 Devboard

{ lib, pkgs, ... }:
{
  imports = [
    # TODO: Enable virtualization
    # ../mixins/virt
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ ];

    # TODO: validate newer version with U-Boot
    kernelPackages = lib.mkDefault pkgs.linuxPackages_4_9;
  };

  # TODO: Revert to DHCP MAC address allocated IPs after testing
  networking = {
    defaultGateway = "192.168.40.1";
    nameservers = [ "192.168.40.1" ];
    interfaces.enp3s0.ipv4.addresses = [{
      address = "192.168.40.185";
      prefixLength = 24;
    }];
    useDHCP = lib.mkForce false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "armv7l-linux";
}
