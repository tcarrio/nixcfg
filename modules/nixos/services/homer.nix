# Homer dashboard (https://github.com/bastienwirtz/homer): static web
# assets + a YAML config, served on loopback for a Caddy/tunnel frontend.
# The dashboard content (groups, links, theme) is declared via
# `services.homer.config` as a plain attrset — generated to YAML at build
# time, so the dashboard is fully declarative per host.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.homer;

  yamlFormat = pkgs.formats.yaml { };

  # Upstream release assets with our config (and optional custom CSS)
  # overlaid into assets/.
  root = pkgs.symlinkJoin {
    name = "homer-with-config";
    paths =
      [ cfg.package ]
      ++ lib.optional (cfg.customCss != null) (
        pkgs.writeTextDir "assets/custom.css" cfg.customCss
      )
      ++ lib.optional (cfg.extraAssets != null) cfg.extraAssets;
    postBuild = ''
      mkdir -p $out/assets
      ln -sfn ${yamlFormat.generate "config.yml" cfg.config} $out/assets/config.yml
    '';
  };
in
{
  options.services.homer = {
    enable = lib.mkEnableOption "Homer dashboard served on loopback";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.homer;
      description = "Homer web assets package";
    };

    port = lib.mkOption {
      type = lib.types.port;
      description = "Loopback port for the static server (claim it in oxc.ports)";
    };

    config = lib.mkOption {
      type = yamlFormat.type;
      description = ''
        Dashboard configuration, attrset-shaped exactly like Homer's
        config.yml (title, subtitle, theme, colors, services, links...).
        See https://github.com/bastienwirtz/homer for the schema.
      '';
    };

    customCss = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      description = "Optional stylesheet served at assets/custom.css (referenced via config.stylesheet)";
    };

    extraAssets = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Optional store tree overlaid onto the assets/ directory — e.g.
        fonts referenced by customCss (assets/fonts/*).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Static file server on loopback only; Caddy fronts it with real TLS.
    systemd.services.homer = {
      description = "Homer dashboard (static)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        Restart = "on-failure";
        # darkhttpd serves the store tree read-only; nothing stateful.
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
      };
      script = ''
        exec ${pkgs.darkhttpd}/bin/darkhttpd ${root}/ --port ${toString cfg.port} --addr 127.0.0.1
      '';
    };
  };
}
