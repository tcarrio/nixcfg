{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, systemType, username, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    ./modules
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${systemType}/${hostname}
    ./mixins/services/firewall.nix
    ./mixins/services/fwupd.nix
    ./mixins/services/kmscon.nix
    ./mixins/services/openssh.nix
    ./mixins/services/smartmon.nix
    ./mixins/users/root
  ]
  ++ lib.optional (builtins.isString username) ./mixins/users/${username}
  ++ lib.optional (builtins.isString desktop) ./mixins/desktop;

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
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.utf8";
      LC_IDENTIFICATION = "en_US.utf8";
      LC_MEASUREMENT = "en_US.utf8";
      LC_MONETARY = "en_US.utf8";
      LC_NAME = "en_US.utf8";
      LC_NUMERIC = "en_US.utf8";
      LC_PAPER = "en_US.utf8";
      LC_TELEPHONE = "en_US.utf8";
      LC_TIME = "en_US.utf8";
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
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      # (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
      # fira
      # fira-go
      # ipafont # Japanese characters
      # kochi-substitute # Japanese characters
      # joypixels # Emojis
      # liberation_ttf
      # noto-fonts-emoji # Emojis
      # source-serif
      # ubuntu_font_family
      # work-sans
    ];

    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultPackages = false;

    # fontconfig = {
    #   antialias = true;
    #   defaultFonts = {
    #     serif = [ "Source Serif" "IPAPMincho" ];
    #     sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" "IPAGothic" ];
    #     monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" "IPAGothic" ];
    #     emoji = [ "Joypixels" "Noto Color Emoji" ];
    #   };
    #   enable = true;
    #   hinting = {
    #     autohint = false;
    #     enable = true;
    #     style = "slight";
    #   };
    #   subpixel = {
    #     rgba = "rgb";
    #     lcdfilter = "light";
    #   };
    # };
  };

  # Use passed hostname to configure basic networking
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
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
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      trusted-users = [ username ];

      warn-dirty = false;
    };
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
        rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nixcfg";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg";
        rebuild-all = "nix-gc && rebuild-host && rebuild-home";
        rebuild-lock = "pushd $HOME/0xc/nixcfg && nix flake lock --recreate-lock-file && popd";

        mooncycle = "curl -s wttr.in/Moon";
        nano = "vim";
        open = "xdg-open";
        pubip = "curl -s ifconfig.me/ip";
        #pubip = "curl -s https://api.ipify.org";
        wttr = "curl -s wttr.in && curl -s v2.wttr.in";
        wttr-bas = "curl -s wttr.in/detroit && curl -s v2.wttr.in/detroit";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    "d /mnt/snapshot/${username} 0755 ${username} users"
  ];

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  };
  system.stateVersion = stateVersion;
}
