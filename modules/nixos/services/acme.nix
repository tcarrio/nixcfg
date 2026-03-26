{ lib, config, ... }:
let
  cfg = config.oxc.services.acme;

  codeMap = {
    "200" = "OK";
    "404" = "Not Found";
    "500" = "Internal Server Error";
  };

  nginxCerts = (lib.optionals cfg.enable cfg.nginx.hosts)
    |> builtins.map (host: {
      name = host;
      value = {
        domain = host;
        group = "nginx";
        dnsProvider = cfg.provider;
        # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
        environmentFile = config.age.secrets.cloudflare-dns-verification.path;
      };
    })
    |> builtins.listToAttrs;

  nginxVirtualHosts = (lib.optionals cfg.enable cfg.nginx.hosts)
    |> builtins.map (host: {
      name = host;
      value = {
        forceSSL = true;
        sslCertificate = "/var/lib/acme/${host}/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/${host}/key.pem";
      };
    })
    |> builtins.listToAttrs;

  nginxDefaultHost = (
    if cfg.nginx.default != null
    then {
      # Add support for 404s on unregistered hosts
      "_" = {
        default = true;
        locations."/".return = "${cfg.nginx.default} '${codeMap.${cfg.nginx.default} or "???"}'";
      };
    }
    else {}
  );
in
{
  options.oxc.services.acme = {
    enable = lib.mkEnableOption "Enable support for ACME LetsEncrypt protocol";

    provider = lib.mkOption {
      type = lib.types.enum ["cloudflare"];
      default = "cloudflare";
      description = "The provider to use for ACME verification";
    };

    nginx = {
      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Nginx hostnames to generate certificates for";
      };
      default = lib.mkOption {
        type = lib.types.either lib.types.int lib.types.null;
        default = null;
        description = "Register a default status code for unknown host requests. Not registered when null.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Securely mount Age secret for Cloudflare DNS verification config
    age.secrets.cloudflare-dns-verification = lib.mkIf (cfg.provider == "cloudflare") {
      file = ../../../secrets/services/acme/cloudflare.age;
      owner = "root";
      group = "root";
      mode = "400";
    };

    # ACME NixOS Docs: https://wiki.nixos.org/wiki/ACME
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "tom@carrio.dev";
        renewInterval = lib.mkDefault "weekly";
        reloadServices = lib.mkDefault [ "nginx" ];
      };
      certs = nginxCerts; # TODO: Extend `certs` if support other "groups"
    };

    services.nginx.virtualHosts = nginxVirtualHosts // nginxDefaultHost;
  };
}
