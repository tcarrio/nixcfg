{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.services.tailscale;
in
{
  options.oxc.services.tailscale = {
    autoconnect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic connection to the Tailscale network with secure tokens";
    };
  };

  config = lib.mkIf cfg.autoconnect {
    # Mounts the secrets file
    age.secrets.tailscale-token = {
      file = ../../../secrets/services/tailscale/token.age;
      owner = "root";
      group = "root";
      mode = "600";
    };

    services.tailscale.authKeyFile = config.age.secrets.tailscale-token.path;
  };
}
