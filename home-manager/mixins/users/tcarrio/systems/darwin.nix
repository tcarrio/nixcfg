{ inputs, platform, config, ...}:
let
  agenix = inputs.agenix.packages.${platform}.default;
  homeDir = config.home.homeDirectory;
in {
  home.packages = [
    agenix
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE="1";
    SSH_AUTH_SOCK = "${homeDir}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
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
    '';

    shellAliases = {
      ip = "ifconfig";
      show_open_ports = "lsof -nP -iTCP -sTCP:LISTEN";
      rebuild-host = "sudo darwin-rebuild switch --flake ${homeDir}/0xc/nixcfg";
    };

    functions = {
      # NOTE: the path relative to /secrets must be passed without `./`
      modify-secret = "pushd ${homeDir}/0xc/nixcfg && ${agenix}/bin/agenix -i ~/.config/age/key.txt -e $argv && popd";
    };
  };

  # Register an age key location for darwin systems secret access
  age.identityPaths = [ "${config.xdg.configHome}/.age/key.txt" ];
}
