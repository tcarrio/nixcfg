{ pkgs, ... }: {
  imports = [
    ../../../desktop/zed.nix
  ];

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

  cursor.voicePlugin.enable = true;
  cursor.voicePlugin.ffmpeg.enable = false;
  cursor.voicePlugin.ffmpeg.package = pkgs.ffmpeg-headless;
  cursor.voicePlugin.pocketTts.package = pkgs.unstable.pocket-tts;

  sk.enable = true;
  oxc.console.atuin.enable = false;
}
