{ lib, ... }:
let
  serenaModuleOptions = { lib, pkgs, config, ... }:
    let
      mkSerenaEnableOption = desc: lib.mkEnableOption "Enable ${desc} support for Serena";
    in
    {
      enable = lib.mkEnableOption "Enable the Serena MCP server";
      languages = rec {
        bash.enable = mkSerenaEnableOption "Bash language";
        bash.package = lib.mkOption { type = lib.types.package; default = pkgs.bash-language-server; };
        bash.path = lib.mkOption { type = lib.types.string; default = "${config.bash.package}/bin/bash-language-server"; description = "The path to the bash language server command"; };
        elm.enable = mkSerenaEnableOption "Elm language";
        elm.package = lib.mkOption { type = lib.types.package; default = pkgs.elmPackages.elm-language-server; };
        elm.path = lib.mkOption { type = lib.types.string; default = "${config.elm.package}/bin/elm-language-server"; description = "The path to the elm language server command"; };
        go.enable = mkSerenaEnableOption "Go language";
        go.package = lib.mkOption { type = lib.types.package; default = pkgs.gopls; };
        go.path = lib.mkOption { type = lib.types.string; default = "${config.go.package}/bin/gopls"; description = "The path to the go language server command"; };
        kotlin.enable = mkSerenaEnableOption "Kotlin";
        kotlin.package = lib.mkOption { type = lib.types.package; default = pkgs.kotlin-language-server; };
        kotlin.path = lib.mkOption { type = lib.types.string; default = "${config.kotlin.package}/bin/kotlin-language-server"; description = "The path to the kotlin language server command"; };
        lua.enable = mkSerenaEnableOption "Lua language";
        lua.package = lib.mkOption { type = lib.types.package; default = pkgs.lua-language-server; };
        lua.path = lib.mkOption { type = lib.types.string; default = "${config.lua.package}/bin/lua-language-server"; description = "The path to the lua language server command"; };
        markdown.enable = mkSerenaEnableOption "Markdown language";
        markdown.package = lib.mkOption { type = lib.types.package; default = pkgs.marksman; };
        markdown.path = lib.mkOption { type = lib.types.string; default = "${config.markdown.package}/bin/marksman"; description = "The path to the markdown language server command"; };
        nix.enable = mkSerenaEnableOption "Nix language";
        nix.package = lib.mkOption { type = lib.types.package; default = pkgs.nixd; };
        nix.path = lib.mkOption { type = lib.types.string; default = "${config.nix.package}/bin/nixd"; description = "The path to the nix language server command"; };
        rego.enable = mkSerenaEnableOption "OPA rego language";
        rego.package = lib.mkOption { type = lib.types.package; default = pkgs.regal; };
        rego.path = lib.mkOption { type = lib.types.string; default = "${config.rego.package}/bin/regal"; description = "The path to the rego language server command"; };
        rust.enable = mkSerenaEnableOption "Rust language";
        rust.package = lib.mkOption { type = lib.types.package; default = pkgs.rust-analyzer; };
        rust.path = lib.mkOption { type = lib.types.string; default = "${config.rust.package}/bin/rust-analyzer"; description = "The path to the rust language server command"; };
        terraform.enable = mkSerenaEnableOption "Terraform language";
        terraform.package = lib.mkOption { type = lib.types.package; default = pkgs.terraform-ls; };
        terraform.path = lib.mkOption { type = lib.types.string; default = "${config.terraform.package}/bin/terraform-ls"; description = "The path to the terraform language server command"; };
        typescript.enable = mkSerenaEnableOption "TypeScript language";
        typescript.package = lib.mkOption { type = lib.types.package; default = pkgs.typescript-language-server; };
        typescript.path = lib.mkOption { type = lib.types.string; default = "${config.typescript.package}/bin/typescript-language-server"; description = "The path to the typescript language server command"; };
        vue.enable = mkSerenaEnableOption "Vue language";
        vue.package = lib.mkOption { type = lib.types.package; default = pkgs.vue-language-server; };
        vue.path = lib.mkOption { type = lib.types.string; default = "${config.vue.package}/bin/vue-language-server"; description = "The path to the vue language server command"; };
        yaml.enable = mkSerenaEnableOption "YAML format";
        yaml.package = lib.mkOption { type = lib.types.package; default = pkgs.yaml-language-server; };
        yaml.path = lib.mkOption { type = lib.types.string; default = "${config.yaml.package}/bin/yaml-language-server"; description = "The path to the yaml language server command"; };
      };
    };
in
{
  flake.modules = {
    homeModules.ai.serena = hmArgs:
      let
        lib' = hmArgs.lib;
        config' = hmArgs.config;
        inherit (hmArgs) options;
        cfg = config'.ai.serena;
      in
      {
        options.ai.serena = serenaModuleOptions {
          lib = lib';
          pkgs = hmArgs.pkgs.unstable;
          config = cfg;
        };

        config =
          if cfg.enable
          then {
            home.packages = (lib'.attrsToList cfg.languages)
              |> (builtins.filter (kv: kv.value.enable))
              |> (builtins.map (kv: kv.value.package));

            home.file.".serena/serena_config.yml" = lib'.generators.toYAML { } {
              ls_specific_settings = (lib'.attrsToList cfg.languages)
                |> (builtins.filter (kv: kv.value.enable))
                |> (builtins.map ({ name, value }: {
                  inherit name;
                  value.path = value.path; }))
                |> builtins.listToAttrs;
            };
          }
          else { };
      };
  };
}
