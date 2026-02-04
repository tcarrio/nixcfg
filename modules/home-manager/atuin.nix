{ config, pkgs, lib, ... }: {
  options.oxc.console.atuin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Atuin terminal history";
    };
    sync = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Atuin terminal history syncing";
    };
  };

  config = lib.mkIf config.oxc.console.atuin.enable {
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      package = pkgs.atuin;
      settings = {
        auto_sync = config.oxc.console.atuin.sync;
        dialect = "us";
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };
  };
}
