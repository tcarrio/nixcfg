{ lib, pkgs, ... }: {
  imports = [
    ../../nixos/console/kubectl.nix
    ../../nixos/desktop/helix.nix
    ../../nixos/desktop/spotify.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
  ];
}
