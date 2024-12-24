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

{ lib, ... }:
let
  listenAddress = "0.0.0.0";
  listenPort = 10809;

  homeNetworkCidrRange = "192.168.40.0/24";
  tailnetCidrRange = "100.64.0.0/10";
in
{
  networking.firewall.allowedTCPPorts = [ listenPort ];

  services.nbd.server = {
    inherit listenAddress listenPort;
    enable = lib.mkDefault true;
    extraOptions = {
      group = "cdrom";
    };
    exports = {
      dvd-drive = {
        path = "/dev/sr0";
        allowAddresses = [ homeNetworkCidrRange tailnetCidrRange ];
        extraOptions = {
          readonly = "true";
        };
      };
      # vault-pub = {
      #   path = "/vault-pub.disk";
      # };
      # vault-priv = {
      #   path = "/dev/loop0";
      #   allowAddresses = [ "127.0.0.1" "::1" ];
      # };
    };
  };
}