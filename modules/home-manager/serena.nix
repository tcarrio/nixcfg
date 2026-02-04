{ lib, pkgs, config, options, ... }:
let
  mkSerenaEnableOption = desc: lib.mkEnableOption "Enable ${desc} support for Serena";

  cfg = config.ai.serena;
in
{
  options.ai.serena = {
    enable = lib.mkEnableOption "Enable the Serena MCP server";
    languages = rec {
      bash.enable = mkSerenaEnableOption "Bash language";
      bash.package = lib.mkOption { type = lib.types.package; default = pkgs.bash-language-server; };
      bash.path = lib.mkOption { type = lib.types.str; default = "/bin/bash-language-server"; description = "The path to the bash language server command from the package"; };
      elm.enable = mkSerenaEnableOption "Elm language";
      elm.package = lib.mkOption { type = lib.types.package; default = pkgs.elmPackages.elm-language-server; };
      elm.path = lib.mkOption { type = lib.types.str; default = "/bin/elm-language-server"; description = "The path to the elm language server command from the package"; };
      go.enable = mkSerenaEnableOption "Go language";
      go.package = lib.mkOption { type = lib.types.package; default = pkgs.gopls; };
      go.path = lib.mkOption { type = lib.types.str; default = "/bin/gopls"; description = "The path to the go language server command from the package"; };
      kotlin.enable = mkSerenaEnableOption "Kotlin";
      kotlin.package = lib.mkOption { type = lib.types.package; default = pkgs.kotlin-language-server; };
      kotlin.path = lib.mkOption { type = lib.types.str; default = "/bin/kotlin-language-server"; description = "The path to the kotlin language server command from the package"; };
      lua.enable = mkSerenaEnableOption "Lua language";
      lua.package = lib.mkOption { type = lib.types.package; default = pkgs.lua-language-server; };
      lua.path = lib.mkOption { type = lib.types.str; default = "/bin/lua-language-server"; description = "The path to the lua language server command from the package"; };
      markdown.enable = mkSerenaEnableOption "Markdown language";
      markdown.package = lib.mkOption { type = lib.types.package; default = pkgs.marksman; };
      markdown.path = lib.mkOption { type = lib.types.str; default = "/bin/marksman"; description = "The path to the markdown language server command from the package"; };
      nix.enable = mkSerenaEnableOption "Nix language";
      nix.package = lib.mkOption { type = lib.types.package; default = pkgs.nixd; };
      nix.path = lib.mkOption { type = lib.types.str; default = "/bin/nixd"; description = "The path to the nix language server command from the package"; };
      rego.enable = mkSerenaEnableOption "OPA rego language";
      rego.package = lib.mkOption { type = lib.types.package; default = pkgs.regal; };
      rego.path = lib.mkOption { type = lib.types.str; default = "/bin/regal"; description = "The path to the rego language server command from the package"; };
      rust.enable = mkSerenaEnableOption "Rust language";
      rust.package = lib.mkOption { type = lib.types.package; default = pkgs.rust-analyzer; };
      rust.path = lib.mkOption { type = lib.types.str; default = "/bin/rust-analyzer"; description = "The path to the rust language server command from the package"; };
      terraform.enable = mkSerenaEnableOption "Terraform language";
      terraform.package = lib.mkOption { type = lib.types.package; default = pkgs.terraform-ls; };
      terraform.path = lib.mkOption { type = lib.types.str; default = "/bin/terraform-ls"; description = "The path to the terraform language server command from the package"; };
      typescript.enable = mkSerenaEnableOption "TypeScript language";
      typescript.package = lib.mkOption { type = lib.types.package; default = pkgs.typescript-language-server; };
      typescript.path = lib.mkOption { type = lib.types.str; default = "/bin/typescript-language-server"; description = "The path to the typescript language server command from the package"; };
      vue.enable = mkSerenaEnableOption "Vue language";
      vue.package = lib.mkOption { type = lib.types.package; default = pkgs.vue-language-server; };
      vue.path = lib.mkOption { type = lib.types.str; default = "/bin/vue-language-server"; description = "The path to the vue language server command from the package"; };
      yaml.enable = mkSerenaEnableOption "YAML format";
      yaml.package = lib.mkOption { type = lib.types.package; default = pkgs.yaml-language-server; };
      yaml.path = lib.mkOption { type = lib.types.str; default = "/bin/yaml-language-server"; description = "The path to the yaml language server command from the package"; };
    };
  };

  config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [ serena ];

      home.file.".serena/serena_config.yml".text = lib.generators.toYAML { } {
        projects = [
          "/Users/tcarrio/Developer/skillshare-web"
        ];
        ls_specific_settings = (lib.attrsToList cfg.languages)
          |> (builtins.filter (kv: kv.value.enable))
          |> (builtins.map ({ name, value }: {
            inherit name;
            value.ls_path = "${value.package}/${value.path}"; }))
          |> builtins.listToAttrs;
      };
    };
}
