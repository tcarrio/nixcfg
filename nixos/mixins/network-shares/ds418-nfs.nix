{ pkgs, lib, config, ... }:
let
  intranetHost = "192.168.40.186";
  nfsHostname = "nas-ds418-00";

  tailscaleEnabled = config.services.tailscale.enable;
  # host = intranetHost;
  host = if tailscaleEnabled then nfsHostname else intranetHost;

  mountLocation = "/mnt/${nfsHostname}";
  remoteLocation = "/volumes/home1";
in
{
  # more info in https://nixos.wiki/wiki/NFS

  services.rpcbind.enable = true; # needed for NFS

  boot.kernelModules = [ "nfsd" ];

  environment.systemPackages = with pkgs; [ nfs-utils ];

  ## TODO: Remove old config
  fileSystems."/mnt/${nfsHostname}" = {
    device = "${intranetHost}:/volume1/homes";
    fsType = "nfs";
    options = ["nfsvers=3"];
  };

  ## TODO: Improve with lazy mounting and tailscale networking
  # systemd.mounts = [{
  #   type = "nfs";
  #   mountConfig = {
  #     Options = "noatime,_netdev,nfsvers=3";
  #     # Options = "nfsvers=3";
  #   };
  #   what = "${host}:${remoteLocation}";
  #   where = mountLocation;
  #   startLimitIntervalSec = 0;
  # }];
  # systemd.automounts = [{
  #   wantedBy = [ "multi-user.target" ];
  #   wants = [ "nfs-client.target" ] ++ (lib.optional tailscaleEnabled "tailscale.target");
  #   where = mountLocation;
  #   startLimitIntervalSec = 0;
  # }];
}
