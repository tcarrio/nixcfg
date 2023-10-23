{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ tailscale ];

  services.tailscale.enable = true;

  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ config.services.tailscale.port ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
