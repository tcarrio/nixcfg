{ pkgs ? import <nixpkgs> {} }:

let
  ghCli = "${pkgs.gh}/bin/gh";
  composerCfgCmd = "composer config --no-plugins --global";
in pkgs.writeShellScriptBin "gh-composer-auth" ''
  #!${pkgs.bash}/bin/bash
  set -e

  echo "Checking if Composer GitHub token is set..."
  if ! command -v composer &> /dev/null; then
      echo "Composer is not installed. The utility requires a contextual composer to configure."
      echo "Please ensure you have an executable `composer` binary in your PATH."
      exit 1
  fi

  if ! ${composerCfgCmd} github-oauth.github.com 1>/dev/null 2>/dev/null; then
    if ! ${ghCli} auth status 1>/dev/null 2>/dev/null; then
      echo "Authenticating with GitHub"
      ${ghCli} auth login
    fi

    if ! ${ghCli} auth status; then
      echo "Failed to authenticate with GitHub. Cannot set the COMPOSER_AUTH environment variable."
    else
      gh_token="$(${ghCli} auth token)"
      ${composerCfgCmd} github-oauth.github.com "$gh_token"
    fi
  else
    echo "Composer GitHub token is already set!"
  fi
''
