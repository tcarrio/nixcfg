# Home network (carrionet) reserved host IP mappings.
# Manually maintained LAN equivalent of tailnet-matrix.nix.
# One entry per host; first IP is the primary.
#
# Reserved MAC addresses (from router DHCP table):
#   orca:             00:25:90:76:56:70 (enp2s0; eno1 00:25:90:76:56:71, no carrier)
#   eufy-homebase-2:  8C:85:80:A3:39:8A  (Eufy-T8010)
#   glass/obsidian:   70:85:C2:FE:75:7D  (same device, both names)
#   hpea4c0f:         F4:30:B9:EA:4C:0F
#   nuc0-nuc9:        f4:4d:30:61:9b:19 .. see nixos/server/NUC.md
#
# Not managed by this flake:
#   nas-ds418-00: Synology DS418, two reserved IPv4 addresses
#   eufy-homebase-2, glass/obsidian, hpea4c0f: appliances/other systems
#
# NOTE: NUC configs (nixos/server/nuc*/default.nix, NUC.md) still pin the
# old 192.168.40.0/24 subnet; MACs match the new 192.168.1.2xx reservations
# below. Update those configs when the NUCs are reprovisioned.
{
  "eufy-homebase-2" = [ "192.168.1.23" ];
  "glass" = [ "192.168.1.120" ];
  "hpea4c0f" = [ "192.168.1.140" ];
  "nas-ds418-00" = [
    "192.168.1.47"
    "192.168.1.48"
  ];
  "nuc0" = [ "192.168.1.200" ];
  "nuc1" = [ "192.168.1.201" ];
  "nuc2" = [ "192.168.1.202" ];
  "nuc3" = [ "192.168.1.203" ];
  "nuc4" = [ "192.168.1.204" ];
  "nuc5" = [ "192.168.1.205" ];
  "nuc6" = [ "192.168.1.206" ];
  "nuc7" = [ "192.168.1.207" ];
  "nuc8" = [ "192.168.1.208" ];
  "nuc9" = [ "192.168.1.209" ];
  "obsidian" = [ "192.168.1.120" ];
  "orca" = [ "192.168.1.83" ];
}
