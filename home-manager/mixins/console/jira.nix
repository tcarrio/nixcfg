# NOTE: Example for nix-darwin / home-manager here:
# https://github.com/ryantm/agenix/issues/50#issuecomment-1634714797

{ config, pkgs, ... }:
let
  jiraWrapper = pkgs.writeShellScriptBin "jira" ''
    JIRA_API_TOKEN="$(${pkgs.coreutils}/bin/cat ${config.age.secrets.jira-cli.path})" ${pkgs.jira-cli-go}/bin/jira "$@"
  '';
in
{
  home.packages = [
    jiraWrapper
  ];

  age.secrets.jira-cli.file = ../../../secrets/services/jira-cli/token.age;

  programs.fish.shellAliases = {
    jcfg = "test -f $HOME/.config/.jira/.config.yml && eval $EDITOR $HOME/.config/.jira/.config.yml || ${jiraWrapper}/bin/j init";
    jls = "${jiraWrapper}/bin/jira sprint list --current";
    jlsa = "${jiraWrapper}/bin/jira sprint list";
  };
}
