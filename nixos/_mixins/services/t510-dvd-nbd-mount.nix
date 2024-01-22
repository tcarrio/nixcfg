{ pkgs, ... }:
{
  boot.kernelModules = [ "nbd" ];

  environment.systemPackages = with pkgs; [ nbd ];

  systemd.services.t510-dvd-nbd-mount = {
    description = "Automatic network mounting via NBD of T510 DVD drive";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nbd}/bin/nbd-client -N dvd-drive t510 10809 /dev/nbd0";
      ExecStop = "${pkgs.nbd}/bin/nbd-client -d /dev/sr0";
      RemainAfterExit = "yes";
    };
  };
}
