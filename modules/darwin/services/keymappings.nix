{ lib, config, ... }:
let
  cfg = config.oxc.services.keymappings;
in
{
  options.oxc.services.keymappings.enable = lib.mkEnableOption "Enables the service which applies nix-darwin configured keymappings at boot";

  config = lib.mkIf cfg.enable {
    # Launchd service based on https://github.com/antoineco/dotfiles/blob/901a5ae6f4cb6f6f810b9657596708f614c4de96/flake.nix#L376-L393
    # This maps the configuration provided for system.keyboard.userKeyMapping and defines a service to apply it on boot
    launchd.user.agents.UserKeyMapping.serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--match"
        "{&quot;ProductID&quot;:0x0,&quot;VendorID&quot;:0x0,&quot;Product&quot;:&quot;Apple Internal Keyboard / Trackpad&quot;}"
        "--set"
        (
          let
            jsonSerializedMappings = builtins.toJSON config.system.keyboard.userKeyMapping;
            escapedQuotesMappings = builtins.replaceStrings [ ''\"'' ] [ "&quot;" ] jsonSerializedMappings;
          in
          escapedQuotesMappings
        )
      ];
      RunAtLoad = true;
    };
  };
}
