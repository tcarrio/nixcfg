### Extracted from t510 config
# services.nbd.server = {
#   enable = false;
#   listenAddress = "0.0.0.0";
#   listenPort = 10809;
# 
#   extraOptions = {
#     allowlist = true;
#   };
# 
#   exports = {
#     dvd-drive = {
#       path = "/dev/sr0";
#       allowAddresses = [ "192.168.40.0/24" "100.0.0.0/8" ];
#     };
#   };
# };
# networking.firewall.allowedTCPPorts = [ 10809 ];

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