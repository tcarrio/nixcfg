{ config, ... }: {
  oxc.vms.haos.enable = true;
  systemd.tmpfiles.rules = [
    "d ${config.oxc.vms.haos.imageDir} 0755 root root"
  ];
}
