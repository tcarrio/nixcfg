# see install/desktop.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      brightnessctl
      playerctl
      pamixer
      pavucontrol
      wireplumber
      fcitx5
      fcitx5-gtk
      # TODO: libsForQt5.fcitx5-qt for fcitx5-qt?
      # TODO: libsForQt5.fcitx5-configtool for fcitx5-configtool?
      wl-clip-persist
      nautilus
      sushi
      ffmpegthumbnailer
      mpv
      evince
      imv
      chromium
    ];
  };
}