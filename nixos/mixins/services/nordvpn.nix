_: {
  chaotic.nordvpn.enable = false;

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 1194 ];
  };
}
