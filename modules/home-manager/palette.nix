{ lib, config, ... }: {
  options.oxc.palette = {
    enable = mkEnableOption "palette";
    colors = {
      color0 = lib.mkOption {
        type = lib.types.string;
        default = "#141417"; #Black + DarkGrey
        description = "The color0 in the 16-color palette";
      };
      color8 = lib.mkOption {
        type = lib.types.string;
        default = "#434345";
        description = "The color8 in the 16-color palette";
      };
      color1 = lib.mkOption {
        type = lib.types.string;
        default = "#D62C2C"; #DarkRed + Red
        description = "The color1 in the 16-color palette";
      };
      color9 = lib.mkOption {
        type = lib.types.string;
        default = "#DE5656";
        description = "The color9 in the 16-color palette";
      };
      color2 = lib.mkOption {
        type = lib.types.string;
        default = "#42DD76"; #DarkGreen + Green
        description = "The color2 in the 16-color palette";
      };
      color10 =lib.mkOption {
        type = lib.types.string;
        default =  "#A1EEBB";
        description = "The color10 in the 16-color palette";
      };
      color3 = lib.mkOption {
        type = lib.types.string;
        default = "#FFB638"; #DarkYellow + Yellow
        description = "The color3 in the 16-color palette";
      };
      color11 =lib.mkOption {
        type = lib.types.string;
        default =  "#FFC560";
        description = "The color11 in the 16-color palette";
      };
      color4 = lib.mkOption {
        type = lib.types.string;
        default = "#28A9FF"; #DarkBlue + Blue
        description = "The color4 in the 16-color palette";
      };
      color12 =lib.mkOption {
        type = lib.types.string;
        default =  "#94D4FF";
        description = "The color12 in the 16-color palette";
      };
      color5 = lib.mkOption {
        type = lib.types.string;
        default = "#E66DFF"; #DarkMagenta + Magenta
        description = "The color5 in the 16-color palette";
      };
      color13 =lib.mkOption {
        type = lib.types.string;
        default =  "#F3B6FF";
        description = "The color13 in the 16-color palette";
      };
      color6 = lib.mkOption {
        type = lib.types.string;
        default = "#14E5D4"; #DarkCyan + Cyan
        description = "The color6 in the 16-color palette";
      };
      color14 =lib.mkOption {
        type = lib.types.string;
        default =  "#A1F5EE";
        description = "The color14 in the 16-color palette";
      };
      color7 = lib.mkOption {
        type = lib.types.string;
        default = "#c8c8c8"; #LightGrey + White
        description = "The color7 in the 16-color palette";
      };
      color15 =lib.mkOption {
        type = lib.types.string;
        default =  "#e9e9e9";
        description = "The color15 in the 16-color palette";
      };
    }
  };
  config = mkIf cfg.enable
    {
      home.file."${config.xdg.configHome}/amethyst/amethyst.yml".text = lib.generators.toYAML { } (
        baseSettings // cfg.settings
      );
    };
}
