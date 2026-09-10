# GNOME workstation profile: the full standalone-home-manager GNOME Linux
# composition — console profile, desktop module set (ghostty/emote/neovide/
# xresources), GNOME theming, session nix-profile visibility, and the
# home-manager-only rebuild aliases. This is the external-consumer surface
# replicating the greybox shape; identity (git user, ssh config, apt
# repositories/keys) stays with the consumer.
{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.profiles.gnome-workstation;
in
{
  options.oxc.profiles.gnome-workstation.enable =
    lib.mkEnableOption "the oxc GNOME workstation profile (standalone-HM GNOME Linux)";

  config = lib.mkIf cfg.enable {
    oxc.profiles.console.enable = lib.mkDefault true;

    # Desktop module set (the internal desktop-mixin defaults)
    oxc.desktop.emote.enable = lib.mkDefault true;
    oxc.desktop.neovide.enable = lib.mkDefault true;
    oxc.desktop.ghostty.enable = lib.mkDefault true;
    oxc.desktop.xresources.enable = lib.mkDefault true;

    # GNOME theming (GTK/fonts/cursor/interface dconf)
    oxc.desktop.gnome.enable = lib.mkDefault true;

    # Session-wide nix profile visibility
    oxc.session.nix-profile.enable = lib.mkDefault true;
  };
}
