{ pkgs, lib, ... }:
let
  webRootHostDir = "/etc/web-server/";
  fqdn = "dotest.carrio.dev";
in
{
  imports = [
    ../../mixins/disks/digital-ocean.nix
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "tom@carrio.dev";
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      "foo.carrio.dev" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        serverAliases = [ "bar.carrio.dev" ];
        locations."/" = {
          root = "/etc/web-server";
        };
      };
    };
  };

  # Configure hosted web content directory
  environment.etc.web-server.source = ./webroot;

  # Now we need to open port 80 for the ACME challenge and port 443 for TLS itself
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
