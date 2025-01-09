# RAID Array configuration manually provided here since disko is broken
_: {
  boot.swraid.enable = true;
  fileSystems."/storage/beorn" =
    {
      device = "/dev/md127p1";
      fsType = "ext4";
    };
}