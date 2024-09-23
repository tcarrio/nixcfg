{ self, pkgs, hostname, username, platform, stateVersion, outputs, lib, ... /* lib, config */ }: {
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
    glances
    home-manager
  ];

  fonts = {
    packages = with pkgs; [
      font-awesome
      powerline-fonts
      powerline-symbols
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Iosevka"
          "IosevkaTerm"
          "IosevkaTermSlab"
          "JetBrainsMono"
          "NerdFontsSymbolsOnly"
        ];
      })
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.trunk-packages
    ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = false; # default shell on catalina

  programs = {
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
      shellAliases = {
        nix-gc = "sudo nix-collect-garbage --delete-older-than 14d";
        rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nixcfg";
        rebuild-host = "darwin-rebuild switch --flake $HOME/0xc/nixcfg";
        rebuild-all = "nix-gc && rebuild-host && rebuild-home";
        rebuild-lock = "pushd $HOME/0xc/nixcfg && nix flake lock --recreate-lock-file && popd";

        mooncycle = "curl -s wttr.in/Moon";
        nano = "vim";
        pubip = "curl -s ifconfig.me/ip";
        #pubip = "curl -s https://api.ipify.org";
        wttr = "curl -s wttr.in && curl -s v2.wttr.in";
        wttr-bas = "curl -s wttr.in/detroit && curl -s v2.wttr.in/detroit";
      };
    };
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null; # TODO: Not compatible after moving to unstable

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = stateVersion;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = platform;
}
