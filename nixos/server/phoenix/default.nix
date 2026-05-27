# NixOS configuration for phoenix

{
  inputs,
  lib,
  hostname ? "phoenix",
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./disks.nix
    ../../mixins/hardware/grub-legacy-boot.nix
  ];

  oxc.services.tailscale = {
    enable = true;
    autoconnect = false;
    ssh.enable = true;
  };

  oxc.containerisation.enable = true;
  oxc.virtualisation.enable = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  # Networking
  networking.hostName = hostname;
  # TODO: Migrate from DHCP to Nix configuration 
  # systemd.network.enable = true;
  # systemd.network.networks."20-lan" = {
  #   dns = [
  #     "45.90.28.130"
  #     "45.90.30.130"
  #   ];
  #   gateway = "192.168.1.1";
  #   matchConfig.Name = "enp3s0";
  #   address = ["192.168.1.80/24"];
  # };

  # AMD GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  environment.variables.ROC_ENABLE_PRE_VEGA = "1";

  # Host architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

