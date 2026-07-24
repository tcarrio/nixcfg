{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Configurations that only apply when a non-SK device is utilized
  config = lib.mkIf (!config.sk.enable) {
    oxc.ai.glm.enable = true;
    home.packages = with pkgs.unstable; [
      mistral-vibe
    ];
  };
}
