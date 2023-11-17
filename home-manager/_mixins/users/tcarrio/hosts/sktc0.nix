{ lib, config, ... }:
{
  imports = [
    # TODO: Implement Doom Emacs
    # ../../../desktop/doom-emacs.nix
    ../../../console/asdf.nix
  ];

  home = {
    sessionPath = [ "/opt/homebrew/bin" ];
    sessionVariables = {
      AWS_REGION = "us-east-1";
      AWS_PROFILE = "skillshare-utility-developer";
      SSH_AUTH_SOCK = "/Users/tcarrio/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./sktc0-direnv.toml;
    };
  };

  programs.fish = {
    interactiveShellInit = ''
      function default_set --no-scope-shadowing
        set -q $argv[1] || set $argv[1] $argv[2..-1]
      end

      function kill_by_port
        set signal $argv[2]
        default_set signal 9
        show_open_ports | grep ":$argv[1] " | awk '{ print $2 }' | xargs kill -$signal
      end

      export PATH="/opt/homebrew/bin:$PATH"
      source $HOME/.nix-profile/share/asdf-vm/asdf.fish
      export PATH="$HOME/Developer/workstation/bin:$PATH"
    '';
    shellAliases = let
      #                         determines directory path of symbol link
      sh = target: "nix develop $(readlink -f ~/0xc/devshells)#${target} --command \$SHELL";
      sk = target: "nix develop ~/0xc/sksh#${target} --command \$SHELL";
      git = "git";
      skillshareWorkstation = "~/Developer/workstation/bin/skillshare-workstation";
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

      "sh:php80" = sh "php80";
      "sh:php81" = sh "php81";
      "sh:php82" = sh "php82";
      "sh:node" = sh "node";
      "sh:node16" = sh "node16";
      "sh:node18" = sh "node18";
      "sh:node20" = sh "node20";
      "sh:python" = sh "python";

      ip = lib.mkForce "ifconfig";
      show_open_ports = "lsof -nP -iTCP -sTCP:LISTEN";

      rebuild-host = lib.mkForce "darwin-rebuild switch --flake $HOME/0xc/nix-config";
    };
  };

  programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
}