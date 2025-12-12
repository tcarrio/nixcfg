{ desktop, lib, pkgs, ... }:
let
  desktopEnabledConfig = {
    imports = [
      ../services/cups.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

    boot = {
      kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" ];
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
  };
  desktopDisabledConfig = {
    hardware.graphics.enable = false;
    programs.dconf.enable = false;
  };
in
if desktop != null then desktopEnabledConfig else desktopDisabledConfig
