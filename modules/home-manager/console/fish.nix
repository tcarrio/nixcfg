{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.fish;
in
{
  options.oxc.console.fish = {
    enable = lib.mkEnableOption "fish as the primary shell with oxc base configuration";

    aliases = lib.mkOption {
      # lazy so per-value priorities (mkDefault/mkForce) survive the merge
      type = lib.types.lazyAttrsOf lib.types.str;
      default = { };
      description = "shellAliases merged into programs.fish.shellAliases";
    };

    functions = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "functions merged into programs.fish.functions";
    };

    interactiveInit = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended to programs.fish.interactiveShellInit";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = with pkgs.fishPlugins; [
        {
          name = "foreign-env";
          inherit (foreign-env) src;
        }
        {
          name = "fzf";
          inherit (fzf-fish) src;
        }
      ];
      defaultText = lib.literalExpression "foreign-env + fzf-fish";
      description = "fish plugins to install";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = cfg.aliases;
      functions = cfg.functions;
      interactiveShellInit = cfg.interactiveInit;
      inherit (cfg) plugins;
    };
  };
}
