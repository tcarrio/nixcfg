{ pkgs, hostname, username, platform, stateVersion, outputs, lib, ... /* lib, config */ }:
let
  nixSettings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes";

    # Allows users/groups to utilize flake-specific settings
    trusted-users = [
      "root"
      "@admin"        # All users in admin group (macOS equivalent of wheel)
      username
    ];

    # Configure and verify binary cache stores
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in {
  imports = [
    ./mixins/users/${username}
    ./modules
  ] ++ lib.optionals (builtins.pathExists (./workstation/${hostname})) [
    ./workstation/${hostname}
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    direnv
    home-manager
  ];

  fonts = {
    packages = with pkgs; [
      font-awesome
      powerline-fonts
      powerline-symbols
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
  };

  nix = {
    # allow either Determinate or upstream Nix
    enable = false;
    # package = pkgs.nix;

    settings = nixSettings;
  };

  # Custom settings written to /etc/nix/nix.custom.conf
  determinate-nix.customSettings = nixSettings;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.trunk-packages
    ];
  };

  # Disable the default zsh behavior on macOS
  programs.zsh.enable = false;

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting ""
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
      shellAliases = {
        nix-gc = "sudo nix-collect-garbage --delete-older-than 14d";
        rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nixcfg#$(whoami)@$(hostname)";
        rebuild-host = "sudo darwin-rebuild switch --flake $HOME/0xc/nixcfg#$(hostname)";
        rebuild-all = "nix-gc && rebuild-host && rebuild-home";
        rebuild-lock = "pushd $HOME/0xc/nixcfg && nix flake lock --recreate-lock-file && popd";

        mooncycle = "curl -s wttr.in/Moon";
        nano = "vim";
        pubip = "curl -s ifconfig.me/ip";
        #pubip = "curl -s https://api.ipify.org";
        wttr = "curl -s wttr.in && curl -s v2.wttr.in";
        wttr-bas = "curl -s wttr.in/detroit && curl -s v2.wttr.in/detroit";

        orbit = "docker compose -f ~/Developer/docker-compose.orbit.yaml";
      };
    };
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null; # TODO: Not compatible after moving to unstable

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = stateVersion;

  # Starting with 25.05, nix-darwin build user GID was changed
  ids.gids.nixbld = 350;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = platform;
}
