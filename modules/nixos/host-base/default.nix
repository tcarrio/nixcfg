# Base system module for host trees that consume nixcfg as a module
# library (external flakes, or internal consumers like hosts/orca).
#
# This is the specialArgs-free counterpart to nixos/default.nix: host
# metadata arrives via the oxc.host options (modules/shared/host.nix)
# instead of the mkHost specialArgs, and the host tree itself is NOT
# imported here — the consumer composes [ host-base, <host tree> ].
#
# The host tree imports its own user mixin (nixos/mixins/users/<name>)
# and, for desktop hosts, the desktop mixin tree: import paths cannot
# be selected from config here without infinite recursion.
#
# Flake-input-dependent pieces (disko, vscode-server, NixVirt, handy)
# are intentionally NOT in this file; the flake composes them into
# nixosModules.host-base so external consumers need only that one
# module. See flake.nix.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  inherit (config.oxc.host) hostname username;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    # Nix settings. username defaults to "root" here (imports must not
    # reference config); the host's primary user is appended to
    # trusted-users below. isDeterminateNix matches the fleet default
    # (mkHost determinate: true); non-determinate consumers override
    # nix.settings after this.
    (import ../../../lib/cache-settings.nix {
      username = "root";
      isDeterminateNix = true;
    })

    ../../../nixos/mixins/services/fwupd.nix
    ../../../nixos/mixins/services/kmscon.nix
    ../../../nixos/mixins/services/openssh.nix
    ../../../nixos/mixins/services/smartmon.nix
    ../../../nixos/mixins/users/root
  ];

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  console = {
    # font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = "us";
    # packages = with pkgs; [ tamzen ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  services.xserver.xkb.layout = "us";
  time.timeZone = "America/Detroit";

  # Only install the docs I use
  documentation.enable = lib.mkDefault true;
  documentation.nixos.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault true;
  documentation.info.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;

  environment = {
    # Eject nano and perl from the system
    defaultPackages =
      with pkgs;
      lib.mkForce [
        gitMinimal
        home-manager
        rsync
        vim
      ];
    systemPackages = with pkgs; [
      agenix
      pciutils
      psmisc
      unixtools.netstat
      unzip
      usbutils
    ];
    variables = {
      EDITOR = lib.mkOverride 999 "vim";
      SYSTEMD_EDITOR = lib.mkOverride 999 "vim";
      VISUAL = lib.mkOverride 999 "vim";
    };
  };

  # Use the host metadata to configure basic networking. hostname may be
  # an FQDN; split it the same way nixos/default.nix did.
  networking = {
    hostName =
      if (builtins.length (lib.strings.splitString "." hostname) > 1) then
        builtins.head (lib.strings.splitString "." hostname)
      else
        hostname;
    domain =
      if (builtins.length (lib.strings.splitString "." hostname) > 1) then
        builtins.concatStringsSep "." (builtins.tail (lib.strings.splitString "." hostname))
      else
        null;
    useDHCP = lib.mkDefault true;
    firewall.enable = lib.mkDefault true;
  };

  nixpkgs = {
    # Allow unfree packages
    config.allowUnfree = true;
  };

  nix = {
    gc = {
      automatic = lib.mkDefault config.nix.enable;
      options = "--delete-older-than 10d";
    };

    # Primary user can invoke nix directly (cache-settings trusted
    # "root"; the host user is appended here).
    settings.trusted-users = lib.mkAfter (lib.optional (username != null) username);

    optimise.automatic = lib.mkDefault config.nix.enable;
  };

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold '--underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = {
        # mkDefault: consumers owning their own agenix secrets override
        # with their repo path.
        modify-secret = lib.mkDefault "pushd $HOME/0xc/nixcfg && agenix -i ~/.ssh/id_rsa -e && popd"; # the path relative to /secrets must be passed without `./`
      };
      shellAliases = {
        nix-gc = "sudo nix-collect-garbage --delete-older-than 28d";
        nix-repair = "sudo nix-store --repair --verify --check-contents";
        restart-nix-daemon = "sudo systemctl restart nix-daemon";

        mooncycle = "curl -s wttr.in/Moon";
        nano = "vim";
        open = "xdg-open";
        pubip = "curl -s ifconfig.me/ip";
        #pubip = "curl -s https://api.ipify.org";
        wttr = "curl -s wttr.in && curl -s v2.wttr.in";
        wttr-bas = "curl -s wttr.in/detroit && curl -s v2.wttr.in/detroit";

        tmp = "pushd \"$(mktemp -d)\"";
      };
    };
  };

  # Do not allow users to be modified by anything other than NixOS
  users.mutableUsers = false;

  systemd.tmpfiles.rules = lib.optionals (username != null) [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ]
  # pam_lastlog2 (util-linux >= 2.42, in the PAM stack for login(1))
  # opens /var/lib/lastlog/lastlog2.db and FAILS the login session when
  # the directory is missing — this bit Tailscale SSH pty logins on orca
  # (2026-10-26). Long-lived systems never had the dir; create it.
  ++ [
    "d /var/lib/lastlog 0755 root root -"
  ];

  system.stateVersion = config.oxc.host.stateVersion;
}
