{ config, lib, pkgs, ...}:
# RClone for easier Google Drive syncing. But first, some context!
# You are going to need to work with rclone directly a bit
# to fully set this module up. Best practice dictates you
# create your own Google OAuth client ID (see
# https://rclone.org/drive/#making-your-own-client-id).
#
# From there, an initial user approval will be necessary to 
# reference after some API calls to 
let
  cfg = config.oxc.services.rclone-gdrive;
in
{
  options.oxc.services.rclone-gdrive = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for nextdns";
    };

    config = {
      path = lib.mkOption {
        type = lib.types.str;
        default = "/etc/rclone-gdrive/mount.conf";
        description = "The location on the filesystem to save the config file";
      };
    };

    service = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "The user to run the systemd service as. Must have access to the underlying secrets file.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = cfg.service.user;
        description = "The group to run the systemd service as. Must have access to the underlying secrets file.";
      };
    };

    sync = {
      source = {
        directory = lib.mkOption {
          type = lib.types.str;
          description = "The source system directory path to sync with Google Drive";
        };
      };

      remote = {
        directory = lib.mkOption {
          type = lib.types.str;
          description = "The remote Google Drive path to sync with the local system";
        };
      };
    };

    secret = {
      clientId = {
        value = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The access token to access Google Drive.";
        };
        path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The path to the secrets file containing the access token";
        };
      };
      clientSecret = {
        value = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The access token to access Google Drive.";
        };
        path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The path to the secrets file containing the access token";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.my-config-template = {
      description = "Generate configuration file from agenix secret";
      
      after = [ "agenix.service" ];
      requires = [ "agenix.service" ];
      
      wantedBy = [ "multi-user.target" ];
      
      restartTriggers = [
        cfg.token.path
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = cfg.service.user;
        Group = cfg.service.group;
        
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /path/to/config/dir";
        
        # The main script that generates the config
        ExecStart = let
          script = pkgs.writeShellScript "generate-config" ''
            CLIENT_ID=$(cat ${cfg.secret.clientId.path})
            CLIENT_SECRET=$(cat ${cfg.secret.clientSecret.path})
            TOKEN=$(cat ${cfg.secret.token.path})

            cat > "${cfg.config.path}" << EOF
            [gdrive]
            type = drive
            client_id = $CLIENT_ID
            client_secret = $CLIENT_SECRET
            scope = drive
            token = $TOKEN
            team_drive = ${cfg.}
            root_folder_id = 
            EOF
            
            # Set appropriate permissions
            chmod 600 "${cfg.config.path}"
          '';
        in "${script}";
      };
    };

    
  }; # END: config = lib.mkIf
}
