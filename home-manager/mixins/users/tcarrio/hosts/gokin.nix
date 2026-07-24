{
  pkgs,
  ...
}:
{
  # home.sessionPath = ["${homeDir}/.bun/bin"];
  programs.fish.shellAliases = {
    happy-vibe = "bunx happy acp -- vibe-acp";
    happy-opencode = "bunx happy acp -- opencode acp";
  };

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
    pkgs.unstable.claude-code
  ];

  oxc.ai.glm.enable = true;
}
