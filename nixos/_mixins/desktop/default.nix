{ desktop, lib, pkgs, ... }: {
  imports = [
    ../services/cups.nix

    # nix modules, as opposed to mix-ins, are always imported and managed by options
    ./beeper.nix
    ./bitwarden.nix
    ./brave.nix
    ./chromium.nix
    ./cinny.nix
    ./daw.nix
    ./discord.nix
    ./element.nix
    ./emacs.nix
    ./ente.nix
    ./evolution.nix
    ./firefox.nix
    ./fractal.nix
    ./google-chrome.nix
    ./logseq.nix
    ./lutris.nix
    ./microsoft-edge.nix
    ./obs-studio.nix
    ./opera.nix
    ./simple-scan.nix
    ./spotify.nix
    ./steam.nix
    ./tilix.nix
    ./vivaldi.nix
    ./vscode.nix
    ./zed.nix
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

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  programs.dconf.enable = true;

  # Disable xterm
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;
}
