{ pkgs, inputs, ... }:
let
  happyNixpkgs = import inputs.happy-nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
  happy-coder = happyNixpkgs.happy-coder;
in
{
  ai.serena.enable = true;
  ai.serena.languages = {
    bash.enable = true;
    elm.enable = true;
    go.enable = true;
    kotlin.enable = true;
    lua.enable = true;
    markdown.enable = true;
    nix.enable = true;
    rego.enable = true;
    rust.enable = true;
    terraform.enable = true;
    typescript.enable = true;
    vue.enable = true;
    yaml.enable = true;
  };

  sk.enable = false;

  oxc.console.atuin.enable = true;

  oxc.github.dash.presets = [ "personal" ];

  home.packages = [
    happy-coder
    pkgs.unstable.nodejs
    pkgs.unstable.mistral-vibe
  ];
}
