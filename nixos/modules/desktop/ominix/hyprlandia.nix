# see install/hyprlandia.sh
{ config, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    programs.hyprland.enable = true;

    # Fix for setting path for Hyprland so opening links detect programs
    programs.hyprland.systemd.setPath.enable = true;

    programs.hyprlock.enable = true;

    # TODO: Configurable XWayland support?
    programs.hyprland.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
      hyprshot
      hyprpicker
      hypridle
      polkit_gnome # for polkit-gnome
      hyprland-qtutils
      wofi
      waybar
      mako
      swaybg
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # TODO: Remove or use for icon fix?
    # programs.dconf.profiles.user.databases = [
    #   {
    #     settings."org/gnome/desktop/interface" = {
    #       gtk-theme = "Adwaita";
    #       icon-theme = "Flat-Remix-Red-Dark";
    #       font-name = "Noto Sans Medium 11";
    #       document-font-name = "Noto Sans Medium 11";
    #       monospace-font-name = "Noto Sans Mono Medium 11";
    #     };
    #   }
    # ];

    # TODO: auto-login for Hyprland
  };
}
