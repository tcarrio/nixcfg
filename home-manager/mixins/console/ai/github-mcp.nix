# NOTE: Example for nix-darwin / home-manager here:
# https://github.com/ryantm/agenix/issues/50#issuecomment-1634714797

{ config, pkgs, ... }:
let
  githubMcpServer = pkgs.writeShellScriptBin "github-mcp-server" ''
    GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github-mcp.path})" \
      ${pkgs.github-mcp-server}/bin/github-mcp-server \
      --dynamic-toolsets \
      --read-only \
      "$@"
  '';
in
{
  home.packages = [
    githubMcpServer
  ];

  age.secrets.github-mcp.file = ../../../secrets/services/github-mcp/token.age;
}
