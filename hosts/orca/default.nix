# Motherboard: Supermicro X9SCL/X9SCM
# CPU:         Intel(R) Xeon(R) E3-1270 V2 (8) @ 3.50 GHz
# GPU:         Matrox Electronics Systems Ltd. X9SCM-F Motherboard
# RAM:         32GB DDR3
# SATA:        WD 300GB HDD
# SATA:        Corsair 256G
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD
# SATA:        WD Red 1TB HDD

# Consumer-style host tree: built from nixcfg's exposed modules
# (nixosModules.host-base + hardware-intel-pc) with plain
# nixpkgs.lib.nixosSystem — no mkHost, no specialArgs. The composition
# lives in flake.nix next to `hosts/orca`; the same shape is what an
# external flake (eru) uses to build this host.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inetConfig = {
    dns = [ "192.168.1.1" ];
    gateway = [ "192.168.1.1" ];
  };
in
{
  imports = [
    ./collabora.nix
    ./dawarich.nix
    ./disks.nix
    ./hass.nix
    # ./haos.nix
    ./media-server.nix
    ./pinchflat.nix
    ./oxicloud.nix
    ./paperless.nix
    ./ports.nix
    ./stirling-pdf.nix
    ./trek.nix
    ../../nixos/mixins/hardware/grub-legacy-boot.nix
    # User profile import lives in the host tree: host-base cannot select
    # import paths from oxc.host options (infinite recursion).
    ../../nixos/mixins/users/archon
  ];

  oxc.host = {
    hostname = "orca";
    username = "archon";
    systemType = "server";
  };

  # Host-tree-owned aliases (the base module carries only the
  # tool-agnostic set): these point at THIS repo, so they change with
  # the host when it moves between flakes.
  programs.fish.shellAliases = {
    rebuild-host = "sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg";
    rebuild-lock = "pushd $HOME/0xc/nixcfg && nix flake lock --recreate-lock-file && popd";
  };

  boot.swraid = {
    enable = true;
    mdadmConf = "MAILADDR dev-null@carrio.dev";
  };

  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  oxc.services.tailscale = {
    enable = true;
    autoconnect = true;
    ssh.enable = true;
    services = [
    ];
  };

  # Hardware config
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usbhid"
      "uas"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_5_15;
  };

  networking.hostName = "orca";
  networking.hostId = builtins.hashString "sha512" config.oxc.host.hostname |> builtins.substring 0 8;

  systemd.network.enable = true;
  systemd.network.networks."20-lan" = {
    inherit (inetConfig) dns gateway;
    matchConfig.Name = "enp2s0";
    address = [ "${builtins.head config.oxc.carrionet.hosts."orca"}/24" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.zfs.autoSnapshot = {
    enable = true;
    # datasets have specific snapshot retention defined explicitly.
    frequent = 0;
    hourly = 0;
    daily = 60;
    weekly = 0;
  };
  # Disable force import to avoid data loss scenarios
  boot.zfs.forceImportRoot = false;
}
