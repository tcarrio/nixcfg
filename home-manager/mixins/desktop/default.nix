{ desktop, lib, pkgs, systemType, ... }:
{
  imports = (
    [
      ./emote.nix
      ./neovide.nix
      ./ghostty
      ./xresources.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix
  );
}
