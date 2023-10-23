{ config, pkgs, ... }:
{
  imports = [./tailscale.nix];

  # Mounts the secrets file
  age.secrets.tailscale-token = {
    file = ../../../secrets/services/tailscale/token.age;
    owner = "root";
    group = "root";
    mode = "600";
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" "run-agenix.d.mount" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey "$(cat "${config.age.secrets.tailscale-token.path}")"
    '';
  };
}