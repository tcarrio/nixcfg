# Gigabyte GB-BXCEH-2955 (Celeron 2955U: Haswell)

{ inputs, lib, pkgs, ... }:
let
  mkNetwork = mac: ipSuffix: {
    matchConfig.MACAddress = mac;
    networkConfig = {
      Address = "192.168.40.${ipSuffix}/24";
      Gateway = "192.168.40.1";
      DNS = "192.168.40.1";
    };
  };

  auto-install-system = pkgs.writeScriptBin "install-system" ''
    macAddr="$(${pkgs.iproute2}/bin/ip address show enp3s0 | grep link/ether | awk '{print $2}')"
    switch $macAddress
      case "f4:4d:30:61:9b:19"
        hostname="nuc0"
      case "f4:4d:30:62:4c:26"
        hostname="nuc1"
      case "f4:4d:30:61:99:ab"
        hostname="nuc2"
      case "f4:4d:30:61:8c:cf"
        hostname="nuc3"
      case "f4:4d:30:61:99:ad"
        hostname="nuc4"
      case "f4:4d:30:61:8a:9d"
        hostname="nuc5"
      case "f4:4d:30:62:4a:76"
        hostname="nuc6"
      case "f4:4d:30:62:4a:43"
        hostname="nuc7"
      case "f4:4d:30:61:9a:e0"
        hostname="nuc8"
      case "f4:4d:30:61:99:ed"
        hostname="nuc9"
      case '*'
        hostname=""
    end

    if [ -z "$hostname" ]
      echo "No hostname determined. Auto-install will exit now.
      exit 1
    fi

    if [ ! -d "$HOME/0xc/nix-config/.git" ]; then
      git clone https://github.com/tcarrio/nix-config.git "$HOME/0xc/nix-config"
    fi

    cd "$HOME/0xc/nix-config"

    nixos-rebuild --flake .#$hostname
  '';
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

  systemd.network = {
    enable = true;
    networks = {
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
  };

  environment.systemPackages = [ auto-install-system ];

  programs.fish.interactiveShellInit = ''
    auto-install-system
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
