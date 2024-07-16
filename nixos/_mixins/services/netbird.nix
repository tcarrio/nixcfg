{ pkgs, lib, desktop, ... }: {
  environment.systemPackages = lib.optionals (desktop != null) [
    pkgs.netbird-ui
  ];

  services.netbird.enable = true;

  networking = {
    firewall = {
      # trustedInterfaces = [ "tailscale0" ];
    };
  };
}
