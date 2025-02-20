{ lib, hostname, inputs, platform, pkgs, ... }:
let
  systemInfo = lib.splitString "-" platform;
  systemType = builtins.elemAt systemInfo 1;
in
{
  imports =
    [
      ../../console/charm-freeze.nix
      ../../console/zeit.nix
      ../../desktop/discord.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}/default.nix")) ./hosts/${hostname}/default.nix
    ++ lib.optional (builtins.pathExists (./. + "/systems/${systemType}.nix")) ./systems/${systemType}.nix;

  home = {
    file."0xc/devshells".source = inputs.devshells;
    file.".ssh/config".text = "
Host github.com
  HostName github.com
  User git

Host glass
  Hostname glass
  User tcarrio
    ";
    sessionVariables = {
      # ...
    };
    file.".config/nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
      }
    '';

    packages = with pkgs; [
      act
      git-absorb
      thefuck
      cmatrix
      bun-baseline
    ];
  };

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
        set -U fish_color_param brblue
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

        function pdf-compress
          ${pkgs.ghostscript}/bin/gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$argv[2]" "$argv[1]"
        end
      '';

      shellAliases =
        let
          #                         determines directory path of symbol link
          dev = target: "nix develop $(readlink -f ~/0xc/devshells)#${target} --command \$SHELL";
          git = "git";
        in
        {
          g = git;
          gti = git;

          lg = "lazygit";

          "dev:php80" = dev "php80";
          "dev:php81" = dev "php81";
          "dev:php82" = dev "php82";
          "dev:node" = dev "node";
          "dev:node16" = dev "node16";
          "dev:node18" = dev "node18";
          "dev:node20" = dev "node20";
          "dev:python" = dev "python";
        };
    };

    git = {
      userEmail = lib.mkDefault "tom@carrio.dev";
      userName = lib.mkDefault "Tom Carrio";
      extraConfig = {
        absorb = {
          maxStack = 50;
        };
      };
    };
  };
}
