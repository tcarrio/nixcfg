{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.gnome;
in
{
  options.oxc.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop theming (GTK, fonts, cursor, interface dconf)";

    colorScheme = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "Session color scheme — drives gtk.colorScheme and the interface color-scheme dconf key";
    };

    clockFormat = lib.mkOption {
      type = lib.types.enum [
        "12h"
        "24h"
      ];
      default = "24h";
      description = "Clock format for the shell and GTK file choosers";
    };

    textScalingFactor = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Interface text scaling factor";
    };

    enablePrimaryPaste = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable primary-paste (middle click) in GTK";
    };

    gtkTheme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Catppuccin-Mocha-Blue-Standard";
        description = ''
          GTK theme directory name. The default follows the catppuccin-gtk
          build scheme {theme}-{flavor}-{accent}-{size} (nixpkgs patches out
          the +default tweaks suffix) and matches the ghostty module's
          Catppuccin Mocha default.
        '';
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.unstable.catppuccin-gtk.override { variant = "mocha"; };
        defaultText = lib.literalExpression "pkgs.unstable.catppuccin-gtk (mocha)";
        description = "GTK theme package (requires the unstable overlay)";
      };
    };

    iconTheme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Numix-Square";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.numix-icon-theme-square;
      };
    };

    cursorTheme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Numix-Cursor";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.numix-cursor-theme;
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 24;
      };
    };

    font = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Work Sans";
        description = "GTK font family (HM appends the size for settings.ini)";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.work-sans;
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 11;
      };
    };

    # dconf font strings carry their own size (GNOME reads these, not
    # settings.ini), so they are full font descriptors.
    fonts = {
      # NOTE: dconf font-name is owned by HM's gtk module (derived from
      # the gtk font option above); this space intentionally has no
      # interface entry.
      document = lib.mkOption {
        type = lib.types.str;
        default = "Work Sans 12";
        description = "Document font (dconf document-font-name)";
      };
      monospace = lib.mkOption {
        type = lib.types.str;
        default = "FiraCode Nerd Font Medium 13";
        description = "Monospace font (dconf monospace-font-name)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      cursorTheme = {
        inherit (cfg.cursorTheme) name package;
        size = cfg.cursorTheme.size;
      };

      font = {
        inherit (cfg.font) name package size;
      };

      # The supported dark-mode switch on GNOME 46 (Ubuntu 24.04): drives
      # gtk-application-prefer-dark-theme in settings.ini AND the
      # org/gnome/desktop/interface color-scheme dconf key through HM's
      # gtk3/gtk4 modules — one owner instead of legacy flags racing the
      # desktop at activation.
      colorScheme = cfg.colorScheme;

      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      };

      gtk4 = {
        # Explicit theme adoption: HM's default changed from inheriting
        # gtk.theme to null in 26.05; this silences the warning and keeps
        # gtk4 apps themed consistently with gtk2/3.
        theme = config.gtk.theme;
      };

      iconTheme = {
        inherit (cfg.iconTheme) name package;
      };

      theme = {
        inherit (cfg.gtkTheme) name package;
      };
    };

    home.pointerCursor = {
      inherit (cfg.cursorTheme) name package;
      size = cfg.cursorTheme.size;
      gtk.enable = true;
      x11.enable = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        clock-format = cfg.clockFormat;
        color-scheme = "prefer-${cfg.colorScheme}";
        cursor-size = cfg.cursorTheme.size;
        cursor-theme = cfg.cursorTheme.name;
        document-font-name = cfg.fonts.document;
        gtk-theme = cfg.gtkTheme.name;
        gtk-enable-primary-paste = cfg.enablePrimaryPaste;
        icon-theme = cfg.iconTheme.name;
        monospace-font-name = cfg.fonts.monospace;
        text-scaling-factor = cfg.textScalingFactor;
      };

      "org/gtk/gtk4/Settings/FileChooser" = {
        inherit (cfg) clockFormat;
      };

      "org/gtk/Settings/FileChooser" = {
        inherit (cfg) clockFormat;
      };
    };
  };
}
