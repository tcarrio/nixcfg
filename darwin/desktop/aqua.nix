{
  pkgs,
  lib,
  desktop,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./mixins/desktop/aqua.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    unstable.neovide
  ];

  services.karabiner-elements.enable = mkDefault true;
}
