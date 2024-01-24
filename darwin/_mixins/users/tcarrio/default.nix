{ pkgs, ... }: {
  imports = [
    ../../nixos/console/auth0.nix
    ../../nixos/console/direnv.nix
    ../../nixos/console/kubectl.nix
    ../../nixos/desktop/spotify.nix
  ];

  environment.systemPackages = with pkgs; [
    awscli2
    bazelisk
    direnv
    dive
    fish
    guile
    jdk11
    lazydocker
    lazygit
    mysql
    neofetch
    neovim
    tmux
    tokei
    tree
  ];
}
