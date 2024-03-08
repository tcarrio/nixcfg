{ config, pkgs, ... }:
{
  imports = [ ./netbird.nix ];

  # Mounts the secrets file
  age.secrets.netbird-token = {
    file = ../../../secrets/services/netbird/token.age;
    owner = "root";
    group = "root";
    mode = "600";
  };

  systemd.services.netbird-autoconnect = {
    description = "Automatic connection to Netbird";

    # make sure netbird is running before trying to connect to netbird
    after = [ "network-pre.target" "netbird.service" ];
    wants = [ "network-pre.target" "netbird.service" "run-agenix.d.mount" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for netbird to settle
      sleep 2

      # check if we are already authenticated to netbird
      set +e
      ${netbird}/bin/netbird status | grep -e LoginFailed
      if [ $? -gt 0 ]; then # if so, then do nothing
        exit 0
      fi
      set -e

      # otherwise authenticate with netbird
      ${netbird}/bin/netbird up -k "$(cat "${config.age.secrets.netbird-token.path}")"
    '';
  };
}
