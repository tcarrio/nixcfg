{ lib, config, ... }:
{
  imports = [
    ../../../desktop/doom-emacs.nix
  ];

  home = {
    sessionPath = [ "/opt/homebrew/bin" ];
    sessionVariables = {
      SSH_AUTH_SOCK = "/Users/tcarrio/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
    };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./alum-direnv.toml;
    };
  };

  programs.fish.shellAliases.rebuild-host = lib.mkForce "darwin-rebuild switch --flake $HOME/0xc/nix-config";

  programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
}