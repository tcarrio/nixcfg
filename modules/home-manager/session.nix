{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.session.nix-profile;
in
{
  options.oxc.session.nix-profile = {
    enable = lib.mkEnableOption "nix profile visibility for the whole user session";
  };

  config = lib.mkIf cfg.enable {
    # Nix profile visibility for the whole session (GNOME Shell children,
    # GUI-launched terminals, D-Bus activated services, apps inheriting the
    # system theme). On a standalone-HM host nothing else places the user
    # profile on the session environment: /etc/profile.d/nix.sh only reaches
    # login bash shells, and hm-session-vars only carries explicit
    # sessionPath entries. Without PATH here, GUI terminals lack profile
    # binaries; without XDG_DATA_DIRS, GTK apps cannot discover the
    # profile's installed themes. environment.d feeds every systemd user
    # session consumer; the systemd user manager always carries a default
    # PATH for ''${PATH} to expand against. (environment.d is only read at
    # user-manager start, which survives logout on Ubuntu/GNOME — see the
    # fish conf.d PATH bootstrap for the immediate layer.)
    xdg.configFile."environment.d/10-nix-profile.conf".text = ''
      PATH=${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:''${PATH}
      XDG_DATA_DIRS=${config.home.homeDirectory}/.nix-profile/share:/usr/local/share:/usr/share
    '';

    home.sessionVariables.XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}";
  };
}
