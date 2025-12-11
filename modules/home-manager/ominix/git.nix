{ config, lib, ... }: let
  cfg = config.ominix;
  idCfg = cfg.identification;
in {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "decorations";
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "GitHub";
    };
  };
  programs.git = {
    enable = true;
    settings = {
      aliases = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
      };
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
