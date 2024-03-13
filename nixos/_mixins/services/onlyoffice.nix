# Reference: https://carjorvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/

{ self, config, lib, pkgs, ... }: let
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