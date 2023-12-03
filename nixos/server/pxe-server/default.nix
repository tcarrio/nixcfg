{ inputs, lib, pkgs, ... }:
let
  dnsHostName = "carrio.dev";
  internalDnsHostName = "int.${dnsHostName}";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    (import ./disks.nix { })
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/bluetooth.nix
    ../_mixins/services/zerotier.nix
    ../_mixins/users/tcarrio
    ../_mixins/users/pxe
    ../_mixins/virt
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" "sd_nod" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
    # loader.grub.enable = false;
    # loader.generic-extlinux-compatible.enable = true;
  };

  # Use passed hostname to configure basic networking
  networking = {
    defaultGateway = "192.168.1.1";
    interfaces.enp3s0.ipv4.addresses = [{
      address = "192.168.1.200";
      prefixLength = 24;
    }];
    nameservers = [ "192.168.1.1" ];
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
        "8.8.8.8"
        "8.8.4.4"
      ];
      dhcp-authoritative = false;
      domain-needed = true;
      domain = "${internalDnsHostName}";
      local = "/${internalDnsHostName}";
      bogus-priv = true;
      rebind-domain-ok = "/plex.direct/";

      # DHCP OPTIONS (SUCH AS PXE, DNS SERVER, GATEWAY, ETC)
      dhcp-option = [
        "enu1u1.10,3,10.50.10.1"
        "enu1u1.10,6,10.50.10.2"
        "enu1u1.20,3,10.50.20.1"
        "enu1u1.20,6,10.50.20.2"
        "enu1u1.30,3,10.50.30.1"
        "enu1u1.30,6,10.50.30.2"
        "enu1u1.40,3,10.50.40.1"
        "enu1u1.40,6,10.50.40.2"
      ];

      # DHCP RANGES
      dhcp-range = [
        "enu1u1.10,10.50.10.200,10.50.10.254,255.255.255.0,8h"
        "enu1u1.20,10.50.20.10,10.50.20.254,255.255.255.0,8h"
        "enu1u1.30,10.50.30.10,10.50.30.254,255.255.255.0,8h"
        "enu1u1.40,10.50.40.200,10.50.40.254,255.255.255.0,8h"
      ];

      # STATIC HOST MAPPINGS ("MAC_ADDRESS,IP_ADDRESS,HOSTNAME")
      dhcp-host = [
        "xx:xx:xx:xx:xx:xx,10.50.10.3,switch"
        "xx:xx:xx:xx:xx:xx,10.50.10.4,ap"
        "xx:xx:xx:xx:xx:xx,10.50.10.10,bedrock"
        "xx:xx:xx:xx:xx:xx,10.50.10.11,hass"
        "xx:xx:xx:xx:xx:xx,10.50.10.12,mainsail"

        "xx:xx:xx:xx:xx:xx,10.50.40.10,hass-iot"
        "xx:xx:xx:xx:xx:xx,10.50.40.11,glow-ihd"
        "xx:xx:xx:xx:xx:xx,10.50.40.12,printer"
        "xx:xx:xx:xx:xx:xx,10.50.40.13,cctv-iot"
        "xx:xx:xx:xx:xx:xx,10.50.40.14,cctv-front"
        "xx:xx:xx:xx:xx:xx,10.50.40.15,cctv-side"
        "xx:xx:xx:xx:xx:xx,10.50.40.16,cctv-rear"
        "xx:xx:xx:xx:xx:xx,10.50.40.17,doorbell"
        "xx:xx:xx:xx:xx:xx,10.50.40.18,cctv-downstairs"
      ];

      # DNS OVERRIDES
      address = [
        "/cloud.${dnsHostName}/10.50.10.10"
        "/photos.${dnsHostName}/10.50.10.10"
        "/id.${dnsHostName}/10.50.10.10"
        "/vault.${dnsHostName}/10.50.10.10"
        "/overseerr.${dnsHostName}/10.50.10.10"
        "/media.${internalDnsHostName}/10.50.10.10"
        "/${dnsHostName}/10.50.10.10"
        "/matrix.${dnsHostName}/10.50.10.10"
        "/syncv3.${dnsHostName}/10.50.10.10"
        "/cctv.${internalDnsHostName}/10.50.10.10"
        "/archive.${internalDnsHostName}/10.50.10.10"
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
  system.stateVersion = "23.11"; # Did you read the comment?
}
