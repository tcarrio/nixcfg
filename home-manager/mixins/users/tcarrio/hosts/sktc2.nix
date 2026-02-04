{ pkgs, ... }: {
  imports = [
    ../../../desktop/zed.nix
  ];

  ai.serena.enable = true;
  ai.serena.languages = {
    bash.enable = false;
    elm.enable = false;
    go.enable = false;
    kotlin.enable = false;
    lua.enable = false;
    markdown.enable = false;
    nix.enable = false;
    rego.enable = false;
    rust.enable = false;
    terraform.enable = false;
    typescript.enable = true;
    vue.enable = false;
    yaml.enable = false;
  };

  cursor.voicePlugin.enable = true;
  cursor.voicePlugin.ffmpeg.enable = false;
  cursor.voicePlugin.ffmpeg.package = pkgs.ffmpeg-headless;
  cursor.voicePlugin.pocketTts.package = pkgs.unstable.pocket-tts;

  sk.enable = true;
  oxc.console.atuin.enable = false;
}
