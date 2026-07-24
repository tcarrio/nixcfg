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
  # package wrapper already prefixes node/ripgrep/difftastic. This runner:
  #   * when `claude.enable` is true, additionally prefixes the pinned
  #     claude-code build so exactly that `claude` is invoked;
  #   * when `claude.enable` is false, injects nothing and instead surfaces the
  #     system profile so `claude` resolves from whatever the system provides
  #     (e.g. a build added to environment.systemPackages). NixOS does not put
  #     /run/current-system/sw/bin on a service's default PATH, so we add it.
  runner = pkgs.writeShellApplication {
    name = "happy-daemon";
    runtimeInputs = [ cfg.package ] ++ lib.optional cfg.claude.enable cfg.claude.package;
    text = ''
      ${lib.optionalString (!cfg.claude.enable) ''
        export PATH="/run/current-system/sw/bin:$PATH"
      ''}
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

    claude = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to pin a claude-code package onto the daemon's PATH.

          When enabled (the default), Happy resolves `claude` to
          {option}`claude.package`. When disabled, no claude is injected and the
          daemon instead discovers `claude` from the system profile — for example
          a build added to `environment.systemPackages` elsewhere.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.claude-code;
        defaultText = lib.literalExpression "pkgs.claude-code";
        description = ''
          The claude-code package to expose on the daemon's PATH. Only used when
          {option}`claude.enable` is true; the package must provide a `claude`
          executable.
        '';
      };
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

      # systemd does not export HOME for a unit, so set it explicitly. PATH is
      # left to the runner wrapper (see `runner` above) to avoid clashing with
      # the per-service default PATH NixOS injects.
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
