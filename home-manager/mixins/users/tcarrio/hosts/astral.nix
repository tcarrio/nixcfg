{ pkgs, ... }:
{
  oxc.ai.serena.enable = true;
  oxc.ai.serena.languages = {
    bash.enable = true;
    elm.enable = false;
    go.enable = false;
    kotlin.enable = false;
    lua.enable = false;
    markdown.enable = true;
    nix.enable = true;
    rego.enable = false;
    rust.enable = false;
    terraform.enable = false;
    typescript.enable = true;
    vue.enable = true;
    yaml.enable = true;
  };

  oxc.ai.mcps = {
    enable = true;
    targets.cursor.enable = true;
    servers.github.enable = true;
  };

  oxc.console.atuin.enable = true;
  oxc.console.aws.enable = true;

  oxc.github.dash.presets = [ "personal" ];
}
