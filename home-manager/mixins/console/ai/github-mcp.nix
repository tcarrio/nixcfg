# NOTE: Example for nix-darwin / home-manager here:
# https://github.com/ryantm/agenix/issues/50#issuecomment-1634714797

{ pkgs, ... }:
let
  githubMcpServer = pkgs.writeShellScriptBin "github-mcp-server" ''
    GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)"
    if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
      echo "Error: github-cli is not authenticated!" >&2
      exit 1
    fi

    export GITHUB_PERSONAL_ACCESS_TOKEN

    ${pkgs.github-mcp-server}/bin/github-mcp-server \
      --dynamic-toolsets \
      --read-only \
      "$@"
  '';
in
{
  home.packages = [githubMcpServer];
}
