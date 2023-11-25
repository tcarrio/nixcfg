{ lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    debootstrap # Terminal Debian installer
    lurk # Modern Unix `strace`
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "curses";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
