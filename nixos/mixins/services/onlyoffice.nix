# Reference: https://carjorvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/

{ config, ... }:
let
  fqdn = "onlyoffice.${config.domainName}";
in
{
  services = {
    nginx.virtualHosts."${fqdn}" = {
      forceSSL = true;
      enableACME = true;
    };

    onlyoffice = {
      enable = true;
      hostname = fqdn;
    };
  };
}
