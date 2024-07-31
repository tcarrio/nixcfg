# NOTE: Example for nix-darwin / home-manager here:
# https://github.com/ryantm/agenix/issues/50#issuecomment-1634714797

{ config, pkgs, ... }: {
  home.packages = [
    pkgs.jira-cli-go
  ];

  age.secrets.jira-cli.file = ../../../secrets/services/jira-cli/token.age;

  programs.fish.shellAliases.jira = "JIRA_API_TOKEN=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.jira-cli.path}) ${pkgs.jira-cli-go}/bin/jira";
}
