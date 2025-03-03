{ inputs, lib, pkgs, self, ... }:
let
  dnsHostName = "carrio.dev";
  internalDnsHostName = "int.${dnsHostName}";
  virtNetIface = "enu1u1";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    ../mixins/hardware/systemd-boot.nix
    # ../mixins/services/bluetooth.nix
    # ../mixins/users/tcarrio
    ../mixins/users/pxe
  ];

  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
    # loader.grub.enable = false;
    # loader.generic-extlinux-compatible.enable = true;
  };

  # Use passed hostname to configure basic networking
  networking = {
    defaultGateway = "192.168.40.1";
    interfaces.enp3s0.ipv4.addresses = [{
      address = "192.168.40.200";
      prefixLength = 24;
    }];
    nameservers = [ "192.168.40.1" ];
    useDHCP = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";


  # --- NETWORK --- #
  networking.hostName = "dns"; # Define your hostname.
  services.resolved.enable = false;

  environment.systemPackages = with pkgs; [
    wget
    parted
  ];

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      dhcp-authoritative = false;
      domain-needed = true;
      domain = "${internalDnsHostName}";
      local = "/${internalDnsHostName}";
      bogus-priv = true;
      rebind-domain-ok = "/plex.direct/";

      # DHCP OPTIONS (SUCH AS PXE, DNS SERVER, GATEWAY, ETC)
      dhcp-option = [
        "${virtNetIface}.10,3,10.50.10.1"
        "${virtNetIface}.10,6,10.50.10.2"
        "${virtNetIface}.20,3,10.50.20.1"
        "${virtNetIface}.20,6,10.50.20.2"
        "${virtNetIface}.30,3,10.50.30.1"
        "${virtNetIface}.30,6,10.50.30.2"
        "${virtNetIface}.40,3,10.50.40.1"
        "${virtNetIface}.40,6,10.50.40.2"
      ];

      # DHCP RANGES
      dhcp-range = [
        "${virtNetIface}.10,10.50.10.200,10.50.10.254,255.255.255.0,8h"
      ];

      # STATIC HOST MAPPINGS ("MAC_ADDRESS,IP_ADDRESS,HOSTNAME")
      dhcp-host = [
        "f4:4d:30:61:9b:19,192.168.40.200" # NUC 00
        "f4:4d:30:62:4c:26,192.168.40.201" # NUC 01
        "f4:4d:30:61:99:ab,192.168.40.202" # NUC 02
        "f4:4d:30:61:8c:cf,192.168.40.203" # NUC 03
        "f4:4d:30:61:99:ad,192.168.40.204" # NUC 04
        "f4:4d:30:61:8a:9d,192.168.40.205" # NUC 05
        "f4:4d:30:62:4a:76,192.168.40.206" # NUC 06
        "f4:4d:30:62:4a:43,192.168.40.207" # NUC 07
        "f4:4d:30:61:9a:e0,192.168.40.208" # NUC 08
        "f4:4d:30:61:99:ed,192.168.40.209" # NUC 09
      ];

      # DNS OVERRIDES
      address = [
        # "/cloud.${dnsHostName}/10.50.10.10"
        # "/photos.${dnsHostName}/10.50.10.10"
        # "/id.${dnsHostName}/10.50.10.10"
        # "/vault.${dnsHostName}/10.50.10.10"
        # "/overseerr.${dnsHostName}/10.50.10.10"
        # "/media.${internalDnsHostName}/10.50.10.10"
        # "/${dnsHostName}/10.50.10.10"
        # "/matrix.${dnsHostName}/10.50.10.10"
        # "/syncv3.${dnsHostName}/10.50.10.10"
        # "/cctv.${internalDnsHostName}/10.50.10.10"
        # "/archive.${internalDnsHostName}/10.50.10.10"
      ];
    };
  };

  services.netdata.enable = true;

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [
  #  22
  #  80
  #  443
  #  19999
  #];
  #networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
