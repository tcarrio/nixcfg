{ config, pkgs, desktop ? false ... }: {
  environment.systemPackages = if desktop then [ pkgs.netbird-ui ] else [];

  services.netbird.enable = true;

  networking = {
    firewall = {
      # trustedInterfaces = [ "tailscale0" ];
    };
  };
}
