{ desktop, lib, pkgs, ... }:
{
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;

  #https://nixos.wiki/wiki/Docker
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation = {
    docker.enable = true;
    docker.storageDriver = "btrfs";
  };
}
