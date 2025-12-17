{ config, lib, pkgs, ... }:
let
  mkTheme = name: package: { inherit name package; };

  # Reusable references for icon, cursor, and GTK theme configs
  iconTheme = mkTheme "Numix-Square" pkgs.numix-icon-theme-square;
  cursorTheme = mkTheme "Numix-Cursor" pkgs.numix-cursor-theme;
  gtkTheme = mkTheme "NumixStandard" pkgs.numix-solarized-gtk-theme;
in
{
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

    # "net/launchpad/plank/docks/dock1" = {
    #   alignment = "center";
    #   hide-mode = "window-dodge";
    #   icon-size = 48;
    #   pinned-only = false;
    #   position = "left";
    #   theme = "Transparent";
    # };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "grp:alt_shift_toggle" "caps:none" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = cursorTheme.name;
      document-font-name = "Work Sans 12";
      font-name = lib.mkDefault "Work Sans 12";
      gtk-theme = "org.gnome.theme";
      gtk-enable-primary-paste = true;
      icon-theme = iconTheme.name;
      monospace-font-name = "FiraCode Nerd Font Medium 13";
      text-scaling-factor = 1.0;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 7200;
    };

    # "org/gnome/desktop/sound" = {
    #   theme-name = "elementary";
    # };

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
      workspace-names = [ "Web" "Work" "Chat" "Code" "Virt" "Cast" "Fun" "Stuff" ];
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

    # "org/gnome/settings-daemon/plugins/media-keys" = {
    #   custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    # };

    # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    #   binding = "<Super>e";
    #   command = "io.elementary.files -n ~/";
    #   name = "io.elementary.files -n ~/";
    # };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-ac-type = "nothing";
    };

    #"org/gnome/settings-daemon/plugins/xsettings" = {
    #  overrides = "{\'Gtk/DialogsUseHeader\': <0>, \'Gtk/ShellShowsAppMenu\': <0>, \'Gtk/EnablePrimaryPaste\': <1>, \'Gtk/DecorationLayout\': <\':minimize,maximize,close,menu\'>, \'Gtk/ShowUnicodeMenu\': <0>}";
    #};

    "org/gtk/gtk4/Settings/FileChooser" = {
      clock-format = "24h";
    };

    "org/gtk/Settings/FileChooser" = {
      clock-format = "24h";
    };
  };

  gtk = {
    enable = true;
    cursorTheme = cursorTheme // {
      size = 24;
    };

    font = {
      name = "Work Sans 12";
      package = pkgs.work-sans;
    };

    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    inherit iconTheme;

    theme = {
      name = "org.gnome.theme";
      inherit (gtkTheme) package;
    };
  };

  home.pointerCursor = cursorTheme // {
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
