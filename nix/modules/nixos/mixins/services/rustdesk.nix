{ pkgs, ... }: {
  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.rustdesk-server;

    relay.enable = true;

    signal.enable = true;
    signal.relayHosts = [ "127.0.0.1" ];
  };
}
