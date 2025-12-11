{ lib, config, username ? null, ... }:
let
  cfg = config.oxc.services.xcode;
  primaryUsername = if username == null then  config.system.primaryUser else username;
in
{
  options.oxc.services.xcode = {
    acceptLicense = lib.mkOption {
      default = true;
      description = "Whether to accept the XCode license in Darwin";
    };
  };

  # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
  config = lib.mkIf cfg.acceptLicense {
    system.activationScripts.AcceptXCodeLicense.text = ''
      sudo --user=${primaryUsername} xcodebuild -license accept
    '';
  };
}
