{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.ghostty;

  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  linuxOptions = lib.mkIf isLinux {
    # Enable Nix management of the Ghostty package on Linux only
    package = cfg.linuxPackage;
  };
  darwinOptions = lib.mkIf isDarwin {
    package = pkgs.empty;
    settings = {
      # Use the latest nightly builds (brew-managed on darwin)
      auto-update-channel = "tip";
    };
  };
in
{
  options.oxc.desktop.ghostty = {
    enable = lib.mkEnableOption "the Ghostty terminal with Catppuccin theming";

    # Catppuccin theme store (github:catppuccin/ghostty); internal hosts
    # pass their locked input via themesSource.
    themesSource = lib.mkOption {
      type = lib.types.path;
      description = "Path to a ghostty themes store";
    };

    font-family = lib.mkOption {
      type = lib.types.str;
      default = "Ubuntu Mono derivative Powerline";
      description = "Primary ghostty font";
    };

    font-size = lib.mkOption {
      type = lib.types.int;
      default = 14;
      description = "Primary ghostty font size";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "Catppuccin Mocha";
      description = "ghostty theme name (resolved against themesSource)";
    };

    linuxPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.ghostty;
      defaultText = lib.literalExpression "pkgs.unstable.ghostty";
      description = "Ghostty package on Linux (requires unstable overlay)";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra programs.ghostty.settings to merge";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}/ghostty/themes".source = "${cfg.themesSource}/themes";

    programs.ghostty = lib.mkMerge [
      {
        enable = true;
        settings =
          {
            inherit (cfg) font-family font-size theme;
          }
          // cfg.extraSettings;
      }
      linuxOptions
      darwinOptions
    ];
  };
}
