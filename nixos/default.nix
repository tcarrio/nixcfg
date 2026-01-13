{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, systemType, username, ... }:
let
  parts = lib.strings.splitString "." hostname;
  hostName = if (builtins.length parts > 1) then builtins.head parts else hostname;
  domain = if (builtins.length parts > 1) then builtins.concatStringsSep "." (builtins.tail parts) else null;
in
{
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.nixosModules.default

    # Or modules exported from other flakes (such as nix-colors):
    inputs.disko.nixosModules.disko

    # Or reuse nixpkgs modules via `modulesPath`
    (modulesPath + "/installer/scan/not-detected.nix")

    # You can also split up your configuration and import pieces of it here:
    ../modules/nixos
    ./${systemType}/${hostname}
    ./mixins/services/fwupd.nix
    ./mixins/services/kmscon.nix
    ./mixins/services/openssh.nix
    ./mixins/services/smartmon.nix
    ./mixins/users/root
  ]
  # Only import desktop configuration if the host is desktop enabled
  ++ lib.optional (builtins.isString desktop) ./mixins/desktop
  # Only import user specific configuration if they have bespoke settings
  ++ lib.optional (builtins.isString username) ./mixins/users/${username};

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
    defaultPackages = with pkgs; lib.mkForce [
      gitMinimal
      home-manager
      rsync
      vim
    ];
    systemPackages = with pkgs; [
      agenix
      pciutils
      psmisc
      unzip
      usbutils
    ];
    variables = {
      EDITOR = lib.mkOverride 999 "vim";
      SYSTEMD_EDITOR = lib.mkOverride 999 "vim";
      VISUAL = lib.mkOverride 999 "vim";
    };
  };

  # Use passed hostname to configure basic networking
  networking = {
    inherit hostName domain;
    useDHCP = lib.mkDefault true;
    firewall.enable = lib.mkDefault true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.trunk-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.agenix.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Allow unfree packages
    config.allowUnfree = true;
  };

  nix = {
    gc = {
      automatic = lib.mkDefault config.nix.enable;
      options = "--delete-older-than 10d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = lib.mkDefault config.nix.enable;
  };

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
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
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = {
        modify-secret = "pushd $HOME/0xc/nixcfg && agenix -i ~/.ssh/id_rsa -e && popd"; # the path relative to /secrets must be passed without `./`

        rebuild-iso-console = "sudo true && pushd $HOME/0xc/nixcfg && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-console/nixos.iso && popd";
        test-iso-console = "pushd ~/Quickemu/ && quickemu --vm nixos-console.conf --ssh-port 54321 && popd";

        rebuild-iso-desktop = "sudo true && pushd $HOME/0xc/nixcfg && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-desktop/nixos.iso && popd";
        test-iso-desktop = "pushd ~/Quickemu/ && quickemu --vm nixos-desktop.conf --ssh-port 54321 && popd";

        rebuild-iso-nuc = "sudo true && pushd $HOME/0xc/nixcfg && nix build .#nixosConfigurations.iso-nuc.config.system.build.isoImage     && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-nuc/nixos.iso     && popd";
        test-iso-nuc = "pushd ~/Quickemu/ && quickemu --vm nixos-nuc.conf     --ssh-port 54321 && popd";
      };
      shellAliases = {
        nix-gc = "sudo nix-collect-garbage --delete-older-than 28d";
        nix-repair = "sudo nix-store --repair --verify --check-contents";
        rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nixcfg";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg";
        rebuild-all = "nix-gc && rebuild-host && rebuild-home";
        rebuild-lock = "pushd $HOME/0xc/nixcfg && nix flake lock --recreate-lock-file && popd";
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

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];

  # system.activationScripts.diff = {
  #   supportsDryActivation = true;
  #   text = ''
  #     ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
  #   '';
  # };
  system.stateVersion = stateVersion;
}
