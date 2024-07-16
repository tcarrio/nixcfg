{ pkgs, ... }: {
  # more info in https://nixos.wiki/wiki/NFS

  services.rpcbind.enable = true; # needed for NFS

  boot.kernelModules = [ "nfsd" ];

  environment.systemPackages = with pkgs; [ nfs-utils ];

  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
    what = "nas-ds418-00:/";
    where = "/mnt/nas-ds418-00";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    wants = [ "nfs-client.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/mnt/nas-ds418-00";
  }];
}
