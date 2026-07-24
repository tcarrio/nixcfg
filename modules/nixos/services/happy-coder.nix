{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.oxc.services.happy-coder;

  # Happy stores auth credentials and session state per-user underneath the
  # owner's home directory, so run the daemon as that user and point HOME at it.
  userEntry = config.users.users.${cfg.user};

  # Happy spawns the `claude` CLI (and re-execs itself) from PATH. The happy
  # package wrapper already prefixes node/ripgrep/difftastic; this runner
  # additionally prefixes the chosen claude-code build so exactly that `claude`
  # is what the daemon invokes, while leaving the service's default PATH intact.
  runner = pkgs.writeShellApplication {
    name = "happy-daemon";
    runtimeInputs = [
      cfg.package
      cfg.claudePackage
    ];
    text = ''
      exec ${lib.getExe cfg.package} daemon start-sync "$@"
    '';
  };
in
{
  options.oxc.services.happy-coder = {
    enable = lib.mkEnableOption (
      lib.mdDoc ''
        the Happy daemon — a long-running background service that lets you spawn
        and remotely control Claude Code sessions from the Happy mobile/web client.

        The module runs `happy daemon start-sync` under systemd so the process is
        supervised, restarted on failure, and shut down cleanly. Run `happy auth
        login` as {option}`user` beforehand so the daemon has credentials to use.
      ''
    );

    package = lib.mkPackageOption pkgs "happy-coder" { };

    claudePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.claude-code;
      defaultText = lib.literalExpression "pkgs.claude-code";
      description = ''
        The claude-code package exposed on the Happy daemon's PATH. Happy spawns
        the `claude` CLI to run sessions, so this package must provide a `claude`
        executable — this option guarantees that is the build Happy invokes.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = ''
        User account under which the Happy daemon runs. Happy reads its
        authentication and writes session state from this user's home directory,
        so set it to the account that has run `happy auth login`.
      '';
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Extra command-line flags appended to `happy daemon start-sync`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.happy-coder = {
      description = "Happy daemon — remote control for Claude Code";
      documentation = [ "https://github.com/slopus/happy" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # systemd already injects a default PATH (coreutils, findutils, ...) for
      # every service; setting `environment.PATH` here would clash with it, so
      # the runner wrapper below prepends happy + claude-code instead, leaving
      # the default intact. HOME must be set explicitly because systemd does not
      # export it for the unit.
      environment.HOME = userEntry.home;

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = userEntry.group;
        WorkingDirectory = userEntry.home;
        ExecStart = lib.escapeShellArgs ([ "${runner}/bin/happy-daemon" ] ++ cfg.extraFlags);
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
