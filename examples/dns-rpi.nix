{ config, pkgs, ... }:

{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # --- NETWORK --- #
  networking.hostName = "dns"; # Define your hostname.
  networking.useDHCP = false;
  services.resolved.enable = false;

  systemd.network.enable = true;
  systemd.network = {
    netdevs = {
      "20-vlan10" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan10";
        };
        vlanConfig.Id = 10;
      };
      "20-vlan20" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
        };
        vlanConfig.Id = 20;
      };
      "20-vlan30" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan30";
        };
        vlanConfig.Id = 30;
      };
      "20-vlan40" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan40";
        };
        vlanConfig.Id = 40;
      };
    };
    networks = {
      "30-enu1u1" = {
        matchConfig.Name = "enu1u1";
        vlan = [
          "vlan10"
          "vlan20"
          "vlan30"
          "vlan40"
        ];
      };

      # VLANs
      "50-vlan10" = {
        matchConfig.Name = "vlan10";
        address = [
          "10.50.10.2/24"
        ];
        routes = [
          { routeConfig.Gateway = "10.50.10.1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
      "50-vlan20" = {
        matchConfig.Name = "vlan20";
        address = [
          "10.50.20.2/24"
        ];
        routes = [
          { routeConfig.Gateway = "10.50.20.1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
      "50-vlan30" = {
        matchConfig.Name = "vlan30";
        address = [
          "10.50.30.2/24"
        ];
        routes = [
          { routeConfig.Gateway = "10.50.30.1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
      "50-vlan40" = {
        matchConfig.Name = "vlan40";
        address = [
          "10.50.40.2/24"
        ];
        routes = [
          { routeConfig.Gateway = "10.50.40.1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure console keymap
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    home = "/home/alex";
    extraGroups = [ "wheel" "libvirtd" "docker" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "INSERT SSH KEY HERE" ];
    hashedPassword = "INSERT HASHED PASSWORD HERE";
  };

  environment.systemPackages = with pkgs; [
    wget
    parted
  ];


  networking.extraHosts =
    ''
      10.50.10.2 dns dns.int.example.uk
      10.50.20.2 dns dns.int.example.uk
      10.50.30.2 dns dns.int.example.uk
      10.50.40.2 dns dns.int.example.uk
    '';

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      dhcp-authoritative = true;
      domain-needed = true;
      domain = "int.example.com";
      local = "/int.example.com";
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
        "/cloud.example.com/10.50.10.10"
        "/photos.example.com/10.50.10.10"
        "/id.example.com/10.50.10.10"
        "/vault.example.com/10.50.10.10"
        "/overseerr.example.com/10.50.10.10"
        "/media.int.example.com/10.50.10.10"
        "/example.com/10.50.10.10"
        "/matrix.example.com/10.50.10.10"
        "/syncv3.example.com/10.50.10.10"
        "/cctv.int.example.com/10.50.10.10"
        "/archive.int.example.com/10.50.10.10"
      ];
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
