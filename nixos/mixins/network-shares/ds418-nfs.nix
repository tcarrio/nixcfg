{ pkgs, ... }: {
  # more info in https://nixos.wiki/wiki/NFS

  services.rpcbind.enable = true; # needed for NFS

  boot.kernelModules = [ "nfsd" ];

  environment.systemPackages = with pkgs; [ nfs-utils ];

  fileSystems."/mnt/nas-ds418-00" = {
    device = "192.168.40.186:/volume1/homes";
    fsType = "nfs";
    options = ["nfsvers=3"];
  };

  ## TODO: Improve with lazy mounting and tailscale networking
  # systemd.mounts = [{
  #   type = "nfs";
  #   mountConfig = {
  #     Options = "noatime,_netdev,nfsvers=3";
  #   };
  #   what = "nas-ds418-00:/volumes/home1";
  #   where = "/mnt/nas-ds418-00";
  # }];

  # systemd.automounts = [{
  #   wantedBy = [ "multi-user.target" ];
  #   wants = [ "nfs-client.target" ];
  #   automountConfig = {
  #     TimeoutIdleSec = "600";
  #   };
  #   where = "/mnt/nas-ds418-00";
  # }];
}
