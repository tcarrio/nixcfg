{ lib, config, inputs, platform, ... }:
{
  imports = [
    ../../../../console/asdf.nix
    ../../../../console/jira.nix
    ../../../../desktop/skhd.nix
  ];

  home = {
    sessionPath = [ "/opt/homebrew/bin" ];
    sessionVariables = {
      AWS_REGION = "us-east-1";
      AWS_PROFILE = "skillshare-utility-developer";
      SKILLSHARE_WORKSTATION_WARP = "true";
      SKILLSHARE_SRC_DIRECTORY = "$HOME/Developer";
      SSH_AUTH_SOCK = "/Users/tcarrio/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./direnv.toml;
    };
    packages = [
      inputs.agenix.packages.${platform}.default
    ];
  };

  oxc.console.atuin.enable = false;

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
      thefuck --alias | source
      source $HOME/.nix-profile/share/asdf-vm/asdf.fish

      fenv source $HOME/Developer/workstation/workstation.sh
    '';
    shellAliases =
      let
        sk = target: "nix develop ~/0xc/sksh#${target} --command \$SHELL";
        git = "git";
        skillshareWorkstation = "~/Developer/workstation/bin/skillshare-workstation";
      in
      {
        sk = skillshareWorkstation;
        sw = skillshareWorkstation;

        g = git;
        gti = git;

        asso = "aws sso login";

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

        ip = lib.mkForce "ifconfig";
        show_open_ports = "lsof -nP -iTCP -sTCP:LISTEN";

        rebuild-host = lib.mkForce "darwin-rebuild switch --flake $HOME/0xc/nixcfg";

        js = "jira sprint list";
        jsc = "js --current";
      };
    functions = {
      # TODO: Support secrets management on macOS
      modify-secret = "pushd $HOME/0xc/nixcfg && agenix -i ~/.config/age/key.txt -e $argv && popd"; # the path relative to /secrets must be passed without `./`
    };
  };

  programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";

  age.identityPaths = [ "/Users/tcarrio/.config/age/key.txt" ];
}
