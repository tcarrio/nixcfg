# The base image does not define anything outside of the automatically inherited
# configurations from the nixos/default.nix module.
# After a system boots and you switch NixOS configurations, you must either
# 1. Copy the /etc/nixos/hardware-configuration.nix file
# 2. Include a disk definition for the platform
# For #2, see the mixins/disks/digital-ocean.nix for an example configuration
_: { }
