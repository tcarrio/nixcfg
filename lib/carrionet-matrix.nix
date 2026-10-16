# Home network (carrionet) reserved host IP mappings.
# Manually maintained LAN equivalent of tailnet-matrix.nix.
# One entry per host; first IP is the primary.
#
# Known MAC addresses:
#   orca: enp2s0 00:25:90:76:56:70 (active), eno1 00:25:90:76:56:71 (no carrier)
#
# Not managed by this flake:
#   nas-ds418-00: Synology DS418, two reserved IPv4 addresses
{
  "orca" = [ "192.168.1.83" ];
  "nas-ds418-00" = [
    "192.168.1.47"
    "192.168.1.48"
  ];
}
