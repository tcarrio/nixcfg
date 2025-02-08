{ lib, config, pkgs, ... }:
let
  cfg = config.oxc.desktop.fonts;

  optionalList = condition: list: if condition then list else [];
in
{
  options.oxc.desktop.fonts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the minimal suite of font configurations";
    };
    ultraMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the ultra, over the top suite of font configurations";
    };
    emoji = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable emoji font sets";
    };
    japanese = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Japanese font sets";
    };
  };

  config = lib.mkIf cfg.ultraMode {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; (optionalList cfg.ultraMode [
        (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
        fira
        fira-go
        liberation_ttf
        source-serif
        ubuntu_font_family
        work-sans
      ]) ++ (optionalList (cfg.ultraMode || cfg.japanese) [
        ipafont
        kochi-substitute
      ]) ++ (optionalList (cfg.ultraMode || cfg.emoji) [
        joypixels
        noto-fonts-emoji
      ]);

      # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
      enableDefaultPackages = cfg.ultraMode;

      fontconfig = lib.mkIf cfg.ultraMode {
        antialias = true;
        defaultFonts = {
          serif = [ "Source Serif" "IPAPMincho" ];
          sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" "IPAGothic" ];
          monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" "IPAGothic" ];
          emoji = [ "Joypixels" "Noto Color Emoji" ];
        };
        enable = true;
        hinting = {
          autohint = false;
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "light";
        };
      };
    };

    nixpkgs.config = lib.mkIf (cfg.ultraMode || cfg.emoji) {
      joypixels.acceptLicense = true;
    };
  };
}
