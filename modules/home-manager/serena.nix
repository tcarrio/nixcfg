{ lib, pkgs, config, ... }:
let
  mkSerenaEnableOption = desc: lib.mkEnableOption "Enable ${desc} support for Serena";

  mkSkProjectPath = name: "${config.sk.srcDir}/${name}";

  managedSerenaConfigFile = pkgs.writeText
    "serena_config.yml"
    (lib.generators.toYAML {} {
      projects = [
        (mkSkProjectPath "skillshare")
        (mkSkProjectPath "skillshare-web")
      ];
      ls_specific_settings = (lib.attrsToList cfg.languages)
        |> (builtins.filter (kv: kv.value.enable))
        |> (builtins.map ({ name, value }: {
          inherit name;
          value.ls_path = "${value.package}${value.path}"; }))
        |> builtins.listToAttrs;
    });

  # Merging config script
  # This provides support for a read/write serena_config.yml that the Serena MCP server can modify.
  # This supports deep-merging the intended values with the existing ones.
  mergeSerenaConfigScript = pkgs.writeShellScript "merge-serena-config" ''
    set -eou pipefail
    SERENA_HOME="$HOME/.serena"
    mkdir -p "$SERENA_HOME"
    SERENA_CONFIG_PATH="$SERENA_HOME/serena_config.yml"

    if [ ! -f "$SERENA_CONFIG_PATH" ]; then
      cat "${managedSerenaConfigFile}" > "$SERENA_CONFIG_PATH"
    else
      # Recursively merge the managed config into the existing one, safely overwrite only after success
      TMP_CONFIG_PATH="$(mktemp)"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$SERENA_CONFIG_PATH" "${managedSerenaConfigFile}" > "$TMP_CONFIG_PATH"
      mv "$TMP_CONFIG_PATH" "$SERENA_CONFIG_PATH"
    fi
  '';

  cfg = config.ai.serena;
in
{
  options.ai.serena = {
    enable = lib.mkEnableOption "Enable the Serena MCP server";
    languages = {
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

      # Merge Nix-managed Serena config into ~/.serena/serena_config.yml using the merge script
      home.activation.mergeSerenaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${mergeSerenaConfigScript}
      '';
    };
}
