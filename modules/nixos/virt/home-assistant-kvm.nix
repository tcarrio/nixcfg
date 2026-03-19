## Example: Home Assistant configuration
# <network ipv6='yes'>
#   <name>homeasst0</name>
#   <uuid>34f02bda-b9e6-4ce5-89f2-1dac61671136</uuid>
#   <forward mode='nat'>
#     <nat>
#       <port start='1024' end='65535'/>
#     </nat>
#   </forward>
#   <bridge name='virbr2' stp='on' delay='0'/>
#   <mac address='52:54:00:90:f5:98'/>
#   <ip address='192.168.129.1' netmask='255.255.255.0'>
#     <dhcp>
#       <range start='192.168.129.1' end='192.168.129.254'/>
#     </dhcp>
#   </ip>
# </network>
#
## Example: virt-install command arguments
# --name haos
# --description "Home Assistant OS"
# --os-variant=generic
# --ram=4096
# --vcpus=2
# --disk <PATH TO QCOW2 FILE>,bus=scsi
# --controller type=scsi,model=virtio-scsi
# --import
# --graphics none --boot uefi

{ config, inputs, lib, pkgs, ... }:
let
  inherit (inputs.NixVirt.lib.domain) templates writeXML;

  cfg = config.oxc.vms.haos;

  fileName = "haos_ova-${cfg.version}.qcow2";
  filePath = "${cfg.imageDir}/${fileName}";
  haosVmFileUpstreamUrl = "https://github.com/home-assistant/operating-system/releases/download/${cfg.version}/${fileName}.xz";

  ensureHaosVmFileAvailabilityScript = pkgs.writeShellScript "ensure-haos-vm-file-availability.sh" ''
    if [ ! -d "${cfg.imageDir}" ]; then
      echo 'Missing image directory: ${cfg.imageDir}' > &2
      exit 1;
    fi

    if [ -f "${cfg.imageDir}/${fileName}"]; then
      exit 0
    fi

    ${pkgs.curl}/bin/curl "${haosVmFileUpstreamUrl}" > "${filePath}.xz";
    ${pkgs.xz}/bin/unxz "${filePath}.xz"
    rm "${filePath}.xz"

    if [ ! -f "${filePath}" ]; then
      echo "File ${filePath} is missing after download and extraction!" > &2
      exit 1
    fi
  '';

  haosConfig = {
    systemd.services.ensureHaosVmFileAvailability = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      description = "Ensure availability of the Home Assisant OS VM file for KVM";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${ensureHaosVmFileAvailabilityScript}";
      };
    };

    virtualisation.libvirt = {
      enable = true;
      connections."qemu:///system".networks =
        [
          {
            definition = writeXML (templates.bridge
              {
                uuid = "70b08691-28dc-4b47-90a1-45bbeac9ab5a";
                subnet_byte = 71;
              });
            active = true;
          }
        ];
      connections."qemu:///session".domains =
        [
          {
            definition = writeXML (templates.linux
              {
                name = "haos";
                uuid = "975bda2d-8644-43b3-a389-8fed5038f19f";
                vcpu = { count = 2; };
                memory = { count = 4; unit = "GiB"; };
                storage_vol = { pool = "HaosVM"; volume = "${cfg.imageDir}/${fileName}"; };
                ## TODO: Some storage volume work
                # backing_vol = /home/ashley/VM-Storage/Base.qcow2;
              });
          }
        ];
    };
  };
in {
  options.oxc.vms.haos = {
    enable = lib.mkEnableOption "Enable the KVM-backed Home Assistant OS service";
    version = lib.mkOption {
      type = lib.types.str;
      default = "17.1";
      description = "The Home Assistant OS version. Dictates the upstream URL to download the qcow2 image";
    };
    imageDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/libvirt/images/";
    };
  };

  config = lib.mkIf cfg.enable haosConfig;
}
