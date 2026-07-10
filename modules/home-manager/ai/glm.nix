{ config, lib, ... }:
let
  cfg = config.oxc.ai.glm;
in
{
  options.oxc.ai.glm.enable = lib.mkEnableOption "Enable GLM Coding Plan";

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
      API_TIMEOUT_MS = "3000000";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "GLM-4.5-air";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "GLM-4.7";
      ANTHROPIC_DEFAULT_OPUS_MODEL = "GLM-5.2";
    };
  };
}
