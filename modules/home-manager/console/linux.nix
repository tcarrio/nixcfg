{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.linux;
in
{
  options.oxc.console.linux = {
    enable = lib.mkEnableOption "base Linux user-session setup (gpg-agent SSH, XDG user dirs, sd-switch)";

    gpgAgentSshSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether gpg-agent exposes the SSH agent socket";
    };

    screenshotsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Pictures/Screenshots";
      description = "XDG screenshots directory";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        debootstrap # Terminal Debian installer
        lurk # Modern Unix `strace`
      ];
      defaultText = lib.literalExpression "[ debootstrap lurk ]";
      description = "Extra Linux-specific console packages";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = cfg.extraPackages;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = cfg.gpgAgentSshSupport;
      pinentryFlavor = "curses";
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = lib.mkDefault true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = cfg.screenshotsDir;
        };
      };
    };
  };
}
