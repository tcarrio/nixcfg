{ lib, config, pkgs, username, ... }: {
  imports = [
    ./docker.nix
    ./nix-applications.nix
    ./podman.nix
    ./nix-spotify.nix
  ];  
}
