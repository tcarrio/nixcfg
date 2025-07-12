# see install/fonts.sh
{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      # for ttf-font-awesome
      font-awesome

      noto-fonts

      # for noto-fonts-emoji
      noto-fonts-color-emoji

      # for noto-fonts-cjk      
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # TODO: noto-fonts-extra?

      nerd-fonts.caskaydia-mono
      
      # TODO: confirm for ia writer mono
      ia-writer-duospace
    ];
  };
}
