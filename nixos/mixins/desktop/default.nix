{
  desktop,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  desktopEnabledConfig = {
    imports = [
      ../services/cups.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

    boot = {
      kernelParams = [
        "quiet"
        "vt.global_cursor_default=0"
        "mitigations=off"
      ];
      plymouth.enable = true;
    };

    # AppImage support & X11 automation
    environment.systemPackages = with pkgs; [
      appimage-run
      wmctrl
      xdotool
      ydotool
    ];

    hardware.graphics.enable = true;

    programs.dconf.enable = true;

    # Disable xterm
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.xserver.desktopManager.xterm.enable = false;

    # We support Flatpak as a default on desktop-enabled systems
    oxc.desktop.flatpak.enable = true;

    # Internal bridge: supply the locked zen-browser input to the (input-
    # agnostic) library module. Hosts enabling oxc.desktop.zen-browser get
    # this package by default.
    oxc.desktop.zen-browser.package =
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped;

    # Internal bridge: transmission flavor was historically derived from the
    # desktop environment; keep that mapping for internal hosts.
    oxc.desktop.transmission.flavor =
      {
        cinnamon = "gtk";
        cosmic = "gtk";
        gnome = "gtk";
        pantheon = "gtk";
        hyprland = "qt";
        i3 = "qt";
        kde = "qt";
        kde6 = "qt";
      }
      .${desktop} or "qt";
  };
  desktopDisabledConfig = {
    hardware.graphics.enable = false;
    programs.dconf.enable = false;
  };
in
if desktop != null then desktopEnabledConfig else desktopDisabledConfig
