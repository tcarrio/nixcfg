_: {
  # more info in https://nixos.wiki/wiki/NFS
  fileSystems."/mnt/nas-ds418-00" = {
    device = "nas-ds418-00:/";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
    ];
  };
}