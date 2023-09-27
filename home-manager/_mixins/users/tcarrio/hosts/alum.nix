{ lib, config, ... }:
{
  imports = [
    # TODO: Implement Doom Emacs
    # ../../../desktop/doom-emacs.nix
  ];

  home = {
    sessionPath = [
      "$HOME/Developer/workstation/bin"
      "/opt/homebrew/bin"
    ];
    sessionVariables = {
      SSH_AUTH_SOCK = "/Users/tcarrio/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./alum-direnv.toml;
    };
  };

  programs.fish.shellAliases = rec {
    sk = "~/Developer/workstation/bin/skillshare-workstation";
    sw = sk;
    gti = "git";

    shell = "nix develop ~/Developer/skix";
    "shell:sk" = "${shell}#sk --command zsh";
    "shell:web" = "${shell}#web --command zsh";
    "shell:php74" = "${shell}#php74 --command zsh";
    "shell:php80" = "${shell}#php80 --command zsh";
    "shell:php81" = "${shell}#php81 --command zsh";
    "shell:php82" = "${shell}#php82 --command zsh";
    "shell:node" = "${shell}#node --command zsh";
    "shell:node16" = "${shell}#node16 --command zsh";
    "shell:node18" = "${shell}#node18 --command zsh";
    "shell:node20" = "${shell}#node20 --command zsh";
    "shell:python" = "${shell}#python --command zsh";
  };

  programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
}