{ lib, ... }:
{
  imports = [
    ../../../desktop/doom-emacs.nix
  ];

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
          rebuild-all = "nix-gc && rebuild-host && rebuild-home";
          rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nix-config";
          rebuild-host = "darwin-rebuild switch --flake $HOME/0xc/nix-config";
          rebuild-lock = "pushd $HOME/0xc/nix-config && nix flake lock --recreate-lock-file && popd";

          moon = "curl -s wttr.in/Moon";
          nano = "vim";
          pubip = "curl -s ifconfig.me/ip";
          wttr = "curl -s wttr.in && curl -s v2.wttr.in";
          wttr-bas = "curl -s wttr.in/detroit && curl -s v2.wttr.in/detroit";
        };
    };

    git = lib.mkForce {
        userEmail = "thomas.carrio@skillshare.com";
        userName = "Tom Carrio";
    };
  };
}