# see install/fonts.sh
{ config, pkgs, lib, ... }:
let
  fonts = with pkgs; [
    # for ttf-font-awesome
    font-awesome

    noto-fonts

    # for noto-fonts-color-emoji
    noto-fonts-color-emoji

    # for noto-fonts-cjk      
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # TODO: noto-fonts-extra?

    nerd-fonts.caskaydia-mono
    
    # TODO: confirm for ia writer mono
    ia-writer-duospace

    # Symbols fix
    nerd-fonts.symbols-only

    # serif
    liberation_ttf

    # sans
    ubuntu-sans
  ];
in {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = fonts;

    fonts = {
      packages = fonts;

      fontconfig = {
        useEmbeddedBitmaps = true;
        defaultFonts = {
          serif = [
            "Liberation Serif"
            # "Vazirmatn"
          ];
          sansSerif = [
            "Ubuntu"
            # "Vazirmatn"
          ];
          monospace = [
            "Caskaydia Nerd Font Mono"
          ];
        };
      };
    };
  };
}
