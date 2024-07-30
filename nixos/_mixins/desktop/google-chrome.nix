{ lib, config, pkgs, ... }: {
  options.oxc.desktop.chrome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Chrome web browser";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.google-chrome;
      description = "The package to use for the Chrome web browser";
    }
  };

  config = lib.mkIf config.oxc.desktop.chrome.enable {
    environment.systemPackages = [config.oxc.desktop.chrome.package];
  };
}
