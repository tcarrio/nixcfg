{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.tailscale;
  certCfg = cfg.certOutput or [];

  # Determine which service to depend on
  useAutoconnect = cfg ? authKeyFile;
  tailscaleService = if useAutoconnect then "tailscaled-autoconnect.service" else "tailscale.service";

  # User to run as - defaults to tailscale
  certUser = cfg.certUser or "tailscale";

  # ExecStartPre commands
  preCommands = 
    (if useAutoconnect then [ ] else [
      "/usr/bin/sh -c 'until ${pkgs.tailscale}/bin/tailscale status >/dev/null 2>&1; do sleep 1; done'"
    ]) ++ [
      "${pkgs.coreutils}/bin/mkdir -p ${lib.concatStringsSep " " (map (c: "${lib.dirname c.path}") certCfg)}"
    ];

  allCertsService = {
    description = "Tailscale certificate generation";
    wantedBy = [ "multi-user.target" ];
    after = [ tailscaleService ];
    requires = [ tailscaleService ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = certUser;
      Group = certUser;

      ExecStartPre = lib.concatStringsSep "\n" preCommands;

      ExecStart = lib.concatStringsSep "\n" (map (
        c: ''
          ${pkgs.tailscale}/bin/tailscale cert ${c.machineName}.${c.tailnetName} > ${c.path}
          ${pkgs.coreutils}/bin/chmod ${c.permissions.mode} ${c.path}
          ${pkgs.coreutils}/bin/chown ${c.permissions.owner}:${c.permissions.group} ${c.path}
        ''
      ) certCfg);
    };
  };

  renewService = {
    description = "Renew Tailscale certificates";
    serviceConfig = {
      Type = "oneshot";
      User = certUser;
      Group = certUser;
      ExecStart = lib.concatStringsSep "\n" (map (
        c: ''
          ${pkgs.tailscale}/bin/tailscale cert ${c.machineName}.${c.tailnetName} > ${c.path}
          ${pkgs.coreutils}/bin/chmod ${c.permissions.mode} ${c.path}
          ${pkgs.coreutils}/bin/chown ${c.permissions.owner}:${c.permissions.group} ${c.path}
        ''
      ) certCfg);
    };
  };

in
{
  options.services.tailscale = {
    certUser = lib.mkOption {
      type = lib.types.str;
      default = "tailscale";
      description = "User to run the certificate generation service as";
    };

    certOutput = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.path;
            description = "Path where the certificate will be written";
          };
          machineName = lib.mkOption {
            type = lib.types.str;
            description = "Machine name in Tailscale";
          };
          tailnetName = lib.mkOption {
            type = lib.types.str;
            description = "Tailnet name (e.g., ts.net)";
          };
          permissions = lib.mkOption {
            type = lib.types.submodule {
              options = {
                mode = lib.mkOption {
                  type = lib.types.str;
                  default = "600";
                  description = "File permissions";
                };
                owner = lib.mkOption {
                  type = lib.types.str;
                  default = "tailscale";
                  description = "File owner";
                };
                group = lib.mkOption {
                  type = lib.types.str;
                  default = "tailscale";
                  description = "File group";
                };
              };
            };
            default = { mode = "600"; owner = "tailscale"; group = "tailscale"; };
            description = "Permissions for the certificate file";
          };
        };
      });
      default = [];
      description = "List of Tailscale certificates to generate and their output configurations";
    };
  };

  config = lib.mkIf (cfg ? certOutput) && certCfg != [] {
    environment.systemPackages = [ pkgs.tailscale ];
    services.tailscale.enable = true;
    services.tailscale.permitCertUid = certUser;

    systemd.services.tailscale-certs = allCertsService;

    systemd.timers.tailscale-certs-renew = {
      description = "Renew Tailscale certificates weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    systemd.services.tailscale-certs-renew = renewService;
  };
}
