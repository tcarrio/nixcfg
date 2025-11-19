{ config, lib, ... }: let
  cfg = config.ominix;
  idCfg = cfg.identification;
in {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        features = "decorations";
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "GitHub";
      };
    };
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
    };
    extraConfig = {
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
    ignores = [
      ".DS_Store"
      "result"
    ];
    # TODO: Fix git user configurations
    # user = lib.mkIf idCfg.enable {
    #   inherit (idCfg) name email;
    # };
  };
}
