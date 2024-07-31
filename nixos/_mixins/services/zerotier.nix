{ config, ... }: {
  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ config.services.zerotierone.port ];
      trustedInterfaces = [
      ];
    };
  };
  services.zerotierone = {
    enable = true;
    joinNetworks = [
    ];
  };
}
