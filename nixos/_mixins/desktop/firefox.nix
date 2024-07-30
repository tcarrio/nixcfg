{ lib, config, pkgs, ... }: {
  options.oxc.desktop.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Firefox web browser";
    };
    languages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "en-US" ];
      description = "List of languages to install";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.firefox;
      description = "Firefox package to install";
    };
  };

  config = lib.mkIf config.oxc.desktop.firefox.enable {
    programs.firefox = {
      enable = true;
      languagePacks = config.oxc.desktop.firefox.languages;
      package = config.oxc.desktop.firefox.package;
    };
  };
}
