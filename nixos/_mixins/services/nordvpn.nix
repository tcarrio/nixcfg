{ config, ... }: {
  chaotic.nordvpn.enable = true;

  networking.firewall.allowedTCPPorts = if config.networking.firewall.enable then [ 443 ]  else [];
  networking.firewall.allowedUDPPorts = if config.networking.firewall.enable then [ 1194 ] else [];
}