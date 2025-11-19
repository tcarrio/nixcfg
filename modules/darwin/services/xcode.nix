{ lib, config, username, ... }: {
  options.oxc.services.xcode = {
    acceptLicense = lib.mkOption {
      default = true;
      description = "Whether to accept the XCode license in Darwin";
    };
  };

  # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
  config = lib.mkIf config.oxc.services.xcode.acceptLicense {
    system.activationScripts.AcceptXCodeLicense.text = ''
      sudo --user=${username} xcodebuild -license accept
    '';
  };
}
