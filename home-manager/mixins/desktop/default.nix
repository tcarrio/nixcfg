{
  desktop,
  inputs,
  lib,
  ...
}:
{
  # Desktop profile: composes oxc.desktop library modules with personal
  # values. emote/ghostty/xresources + the per-DE theming module.
  oxc.desktop.emote.enable = lib.mkDefault true;
  oxc.desktop.neovide.enable = lib.mkDefault true;
  oxc.desktop.ghostty.enable = lib.mkDefault true;
  oxc.desktop.ghostty.themesSource = inputs.ghostty-catppuccin;
  oxc.desktop.xresources.enable = lib.mkDefault true;

  imports =
    lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
}
