{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.worktree-cli;
in
{
  options.oxc.console.worktree-cli = {
    enable = lib.mkEnableOption "the wt git-worktree helper CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.worktree-cli
    ];
  };
}
