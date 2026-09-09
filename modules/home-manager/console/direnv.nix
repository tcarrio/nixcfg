{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.console.direnv;
in
{
  options.oxc.console.direnv = {
    enable = lib.mkEnableOption "direnv with nix-direnv and managed direnv.toml";

    whitelistPrefixes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Directory prefixes whitelisted for .env loading ([whitelist] prefix
        in direnv.toml). This module is the single owner of direnv.toml.
      '';
    };

    loadDotenv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether direnv may load .env files";
    };

    strictEnv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use strict_env mode";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    xdg.configFile."direnv/direnv.toml".text =
      let
        whitelist =
          if cfg.whitelistPrefixes != [ ] then
            "\n[whitelist]\nprefix = ${builtins.toJSON cfg.whitelistPrefixes}\n"
          else
            "";
      in
      ''
        [global]
        load_dotenv = ${lib.boolToString cfg.loadDotenv}
        strict_env = ${lib.boolToString cfg.strictEnv}
      '' + whitelist;
  };
}
