_: {
  chaotic.nordvpn.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 1194 ];
  };
}
