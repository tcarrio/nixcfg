{ lib, config, ... }:
{
  imports = [
    # TODO: Implement Doom Emacs
    # ../../../desktop/doom-emacs.nix
    ../../../console/asdf.nix
  ];

  home = {
    sessionPath = [
      "$HOME/Developer/workstation/bin"
      "/opt/homebrew/bin"
    ];
    sessionVariables = {
      AWS_REGION = "us-east-1";
      AWS_PROFILE = "skillshare-utility-developer";

      SSH_AUTH_SOCK = "/Users/tcarrio/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./alum-direnv.toml;
    };
  };

  programs.fish = {
    interactiveShellInit = ''
      source $HOME/.nix-profile/share/asdf-vm/asdf.fish
    '';
    shellAliases = let
      sh = target: "nix develop ~/0xc/devshells#${target} --command \$SHELL";
      sk = target: "nix develop ~/Developer/sksh#${target} --command \$SHELL";
      git = "git";
      skillshareWorkstation = "~/Developer/workstation/bin/skillshare-workstation";
      ip = "ifconfig";
    in
    {
      sk = skillshareWorkstation;
      sw = skillshareWorkstation;

      g = git;
      gti = git;

      "sk:mono" = sk "sk";
      "sk:web" = sk "web";
      "sk:php74" = sk "php74";
      "sk:php80" = sk "php80";
      "sk:php81" = sk "php81";
      "sk:php82" = sk "php82";
      "sk:node" = sk "node";
      "sk:node16" = sk "node16";
      "sk:node18" = sk "node18";
      "sk:node20" = sk "node20";
      "sk:python" = sk "python";
    };
  };

  programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
}