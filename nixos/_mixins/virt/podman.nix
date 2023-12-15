{ config, desktop, lib, pkgs, ... }:
{
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;

  #https://nixos.wiki/wiki/Podman
  environment.systemPackages = with pkgs; [
    buildah
    distrobox
    fuse-overlayfs
    podman-compose
    podman-tui
  ];

  virtualisation = {
    podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      dockerCompat = true;
      enable = true;
      enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };
}
