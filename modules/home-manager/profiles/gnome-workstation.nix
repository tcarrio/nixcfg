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
  options.oxc.profiles.gnome-workstation = {
    enable = lib.mkEnableOption "the oxc GNOME workstation profile (standalone-HM GNOME Linux)";

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/0xc/nixcfg";
      description = "Flake path used by the rebuild-home alias";
    };

    flakeTarget = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Flake target (<user>@<host>) for the rebuild-home alias; typically
        the consuming homeConfigurations entry name. The rebuild aliases
        are only generated when this is set.
      '';
    };
  };

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

    # Home-manager-only life: no system configuration to rebuild. The
    # rebuild-home alias is generated only with an explicit flakeTarget.
    programs.fish.shellAliases = lib.mkIf (cfg.flakeTarget != null) {
      rebuild-home = "home-manager switch -b backup --flake ${cfg.flakePath}#${cfg.flakeTarget}";
      rebuild-all = "nix-gc && rebuild-home";
      nix-gc = "nix-collect-garbage --delete-older-than 28d";
      rebuild-host = "echo 'No system layer on this host — see docs/non-nixos-linux.md' && return 1";
    };
  };
}
