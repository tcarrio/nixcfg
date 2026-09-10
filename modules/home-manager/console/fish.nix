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

    # Standalone-HM hosts cannot rely on the session environment carrying
    # the nix profile PATH (environment.d is only read at user-manager
    # start, which survives logout on Ubuntu/GNOME). Fish bootstraps its
    # own PATH so profile binaries (atuin, zoxide, ...) resolve in every
    # fish regardless of how the session was launched. No-op when PATH is
    # already correct (contains-guard prevents duplication).
    xdg.configFile."fish/conf.d/00-nix-profile-path.fish".text =
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        if test -d "$HOME/.nix-profile/bin"; and not contains -- "$HOME/.nix-profile/bin" $PATH
            set -gx PATH "$HOME/.nix-profile/bin" $PATH
        end
      '';
  };
}
