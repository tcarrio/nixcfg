{ desktop, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (config.oxc.palette) colors;
in
{
  imports = [
    ./neovide.nix
  ]
  ++ lib.optionals (system == "linux") [
    ./alacritty.nix
    ./emote.nix
    ./tilix.nix
    ./xresources.nix
  ]
  ++ lib.optionals (system == "darwin") [
    ./ghostty.nix
  ]
  ++ lib.optionals (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
}
