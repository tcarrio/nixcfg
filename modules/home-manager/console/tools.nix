{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.console.tools;
in
{
  options.oxc.console.tools = {
    enable = lib.mkEnableOption "the oxc console tool bundle (each tool independently toggleable)";

    fzf = lib.mkEnableOption "fzf with fish integration" // {
      default = config.oxc.console.tools.enable;
    };
    eza = lib.mkEnableOption "eza with fish integration" // {
      default = config.oxc.console.tools.enable;
    };
    zoxide = lib.mkEnableOption "zoxide with fish integration" // {
      default = config.oxc.console.tools.enable;
    };
    dircolors = lib.mkEnableOption "dircolors with fish integration" // {
      default = config.oxc.console.tools.enable;
    };
    jq = lib.mkEnableOption "jq" // {
      default = config.oxc.console.tools.enable;
    };
    bottom = lib.mkEnableOption "bottom with oxc settings" // {
      default = config.oxc.console.tools.enable;
    };
    powerline-go = lib.mkEnableOption "powerline-go prompt" // {
      default = config.oxc.console.tools.enable;
    };
    gpg = lib.mkEnableOption "gpg" // {
      default = config.oxc.console.tools.enable;
    };
    info = lib.mkEnableOption "info" // {
      default = config.oxc.console.tools.enable;
    };
    home-manager = lib.mkEnableOption "the home-manager CLI" // {
      default = config.oxc.console.tools.enable;
    };
  };

  config = {
    programs.fzf = lib.mkIf cfg.fzf {
      enable = true;
      enableFishIntegration = true;
    };

    programs.eza = lib.mkIf cfg.eza {
      enable = true;
      enableFishIntegration = true;
      icons = "auto";
    };

    programs.zoxide = lib.mkIf cfg.zoxide {
      enable = true;
      enableFishIntegration = true;
    };

    programs.dircolors = lib.mkIf cfg.dircolors {
      enable = true;
      enableFishIntegration = true;
    };

    programs.jq = lib.mkIf cfg.jq { enable = true; };

    programs.bottom = lib.mkIf cfg.bottom {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };

    programs.powerline-go = lib.mkIf cfg.powerline-go {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        max-width = 60;
      };
    };

    programs.gpg = lib.mkIf cfg.gpg { enable = true; };

    programs.info = lib.mkIf cfg.info { enable = true; };

    programs.home-manager = lib.mkIf cfg.home-manager { enable = true; };
  };
}
