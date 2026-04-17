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
    # (happy-coder.overrideAttrs (final: prev: {
    #   version = "0.14.0-0 ";
    #   src = fetchFromGitHub {
    #     owner = "slopus";
    #     repo = "happy-cli";
    #     rev = "d7e9957c25bac4c9cfefa8e221a32346eab7d6ee";
    #     hash = "sha256-kEYgo+n1qv+jJ9GvqiwJtf6JSA2xSkLMEbvuY/b7Gdk=";
    #   };
    #   # passthru = prev.passthru // {
    #   #     sources = prev.passthru.sources // {
    #   #         "aarch64-darwin" = fetchurl {
    #   #             url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
    #   #             # hash = "";
    #   #         };
    #   #     };
    #   # };
    # }))
  ];
}
