{ ... }:
let
  automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
in
{
  # Mounts the secrets file
  age.secrets.ds418-smb-conf = {
    file = ../../../secrets/network-shares/ds418/smb.conf.age;
    owner = "root";
    group = "root";
    mode = "400";
  };

  # For mount.cifs, required since domain name resolution is needed
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/ds418" = {
    device = "//nas-ds418-00/homes/Tom";
    fsType = "cifs";
    options = ["${automount_opts},credentials=${config.age.secrets.ds418-smb-conf.path}"];

    # ensure the agenix file is mounted successfully
    depends = [config.age.secrets.ds418-smb-conf.path]
  };

  # TODO: Utilize systemd.mounts instead for better service dependency detection?
}