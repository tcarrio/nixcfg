{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 10809 ];

  services.nbd.server = {
    enable = true;
    exports = {
      dvd-drive = {
        path = "/dev/sr0";
      };
      # vault-pub = {
      #   path = "/vault-pub.disk";
      # };
      # vault-priv = {
      #   path = "/dev/loop0";
      #   allowAddresses = [ "127.0.0.1" "::1" ];
      # };
    };
    listenAddress = "0.0.0.0";
    listenPort = 10809;
  };
}