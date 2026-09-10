# GNOME personal layer: composes the oxc.desktop.gnome library module
# (GTK/fonts/cursor/interface theming — option-driven) with personal dconf
# preferences. Desktop structure lives in the module; this file carries
# taste: workspace layout, input sources, location, power behavior.
{
  lib,
  ...
}:
{
  oxc.desktop.gnome.enable = true;

  # Session-wide nix profile visibility (PATH + XDG_DATA_DIRS via
  # environment.d) — standalone-HM requirement, module-owned.
  oxc.session.nix-profile.enable = true;

  dconf.settings = {
    "com/github/stsdc/monitor/settings" = {
      background-state = true;
      indicator-state = true;
      indicator-cpu-state = false;
      indicator-gpu-state = false;
      indicator-memory-state = false;
      indicator-network-download-state = true;
      indicator-network-upload-state = true;
      indicator-temperature-state = true;
    };

    "desktop/ibus/panel" = {
      show-icon-on-systray = false;
      use-custom-font = true;
      custom-font = "Work Sans 10";
    };

    "desktop/ibus/panel/emoji" = {
      font = "JoyPixels 16";
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "grp:alt_shift_toggle"
        "caps:none"
      ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 7200;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left = [ "<Primary><Alt>Left" ];
      switch-to-workspace-right = [ "<Primary><Alt>Right" ];
      switch-windows = [ "<Alt> Tab" ];
      switch-windows-backward = [ "<Shift><Alt> Tab" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      audible-bell = false;
      button-layout = ":minimize,maximize,close";
      num-workspaces = 8;
      titlebar-font = "Work Sans Semi-Bold 12";
      workspace-names = [
        "Web"
        "Work"
        "Chat"
        "Code"
        "Virt"
        "Cast"
        "Fun"
        "Stuff"
      ];
    };

    "org/gnome/GWeather" = {
      locations = "[<(uint32 2, <('Detroit', 'KDET', true, [(0.74017959717812587, -1.448797812080493)], [(0.73882277821762554, -1.4494218371012511)])>)>]";
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      dynamic-workspaces = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>Left" ];
      toggle-tiled-right = [ "<Super>Right" ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-ac-type = "nothing";
    };
  };
}
