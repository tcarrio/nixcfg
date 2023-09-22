{ lib, pkgs, ... }: {
  imports = [
    ../../nixos/console/auth0.nix
    ../../nixos/console/direnv.nix
    ../../nixos/console/helix.nix
    ../../nixos/console/kubectl.nix
    ../../nixos/desktop/spotify.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
  ];
}
