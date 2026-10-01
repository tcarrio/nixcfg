{ pkgs, lib, ... }: 
pkgs.writeShellApplication {
  name = "worktree-cli";
  text = (lib.readFile ./wt.sh);
  runtimeInputs = with pkgs; [
    git
  ];
}
