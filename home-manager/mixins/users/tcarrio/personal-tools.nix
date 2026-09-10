{
  lib,
  config,
  pkgs,
  ...
}:
{
  # Personal custom CLIs from the flake's pkgs set — opt-in per host.
  options.oxc.profile.personal-tools = {
    enable = lib.mkEnableOption "personal custom CLI tools (gh-composer-auth, urlencode, qq-cli)";
  };

  config = lib.mkIf config.oxc.profile.personal-tools.enable {
    home.packages =
      (with pkgs; [
        gh-composer-auth
        urlencode
        qq-cli
      ]);
  };
}
