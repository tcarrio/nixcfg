{ pkgs, ... }:
{
  imports = [
    ../../../desktop/zed.nix
  ];

  ai.serena.enable = true;
  ai.serena.languages = {
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

  cursor.voicePlugin.enable = false;
  cursor.voicePlugin.ffmpeg.enable = false;
  cursor.voicePlugin.ffmpeg.package = pkgs.ffmpeg-headless;
  cursor.voicePlugin.pocketTts.package = pkgs.unstable.pocket-tts;

  sk.enable = true;

  oxc.ai.cursor.enable = true;
  oxc.ai.cursor.riper-5.enable = false;
  oxc.ai.cursor.serena.enable = false;
  oxc.ai.cursor.sk.enable = true;

  oxc.ai.mcps = {
    enable = true;
    targets.cursor.enable = true;
    servers.github.enable = true;
  };

  oxc.console.atuin.enable = true;
  oxc.console.aws.enable = true;

  oxc.github.dash.presets = [
    "skillshare"
    "personal"
  ];
}
