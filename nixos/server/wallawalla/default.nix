# Gigabyte GB-BXCEH-2955 (Celeron 2955U: Haswell)

{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../_mixins/hardware/systemd-boot.nix
  ];

  environment.systemPackages = with pkgs; [
    wallabag
  ];

  networking.firewall.allowedTCPPorts = [  ];

  services.nginx.enable = lib.mkForce true;

  services.nginx.virtualHosts."wallawalla" = {
    addSSL = true;
    enableACME = true;

    root = "${pkgs.wallabag}/var/www/wallabag/web";

    error_log = "/var/log/nginx/wallabag_error.log";
    access_log = "/var/log/nginx/wallabag_access.log";

    locations = {
      # try to serve file directly, fallback to app.php
      "/" = {
        tryFiles = ''uri /app.php$is_args$args;'';
      };

      "~ ^/app\.php(/|$)" = {
        extraConfig = ''
          # if, for some reason, you are still using PHP 5,
          # then replace /run/php/php7.0 by /var/run/php5
          fastcgi_pass unix:/run/php/php7.0-fpm.sock;
          fastcgi_split_path_info ^(.+\.php)(/.*)$;

          include fastcgi_params;

          fastcgi_param  SCRIPT_FILENAME  $realpath_root$fastcgi_script_name;
          fastcgi_param DOCUMENT_ROOT $realpath_root;

          # When you are using symlinks to link the document root to the
          # current version of your application, you should pass the real
          # application path instead of the path to the symlink to PHP
          # FPM.
          # Otherwise, PHP's OPcache may not properly detect changes to
          # your PHP files (see https://github.com/zendtech/ZendOptimizerPlus/issues/126
          # for more information).
          # Prevents URIs that include the front controller. This will 404:
          # http://domain.tld/app.php/some-path
          # Remove the internal directive to allow URIs like this
          internal = true;
        '';
      };

      "~ \.php$" = {
        # return 404 for all other php files not matching the front controller
        # this prevents access to other php files you don't want to be accessible.
        return = "404";
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
