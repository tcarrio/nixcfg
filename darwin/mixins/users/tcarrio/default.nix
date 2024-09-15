{ pkgs, ... }: {
  imports = [
    ../../desktop/spotify.nix
    ../../nixos/console/auth0.nix
    ../../nixos/console/direnv.nix
    ../../nixos/console/kubectl.nix
  ];

  environment.systemPackages = with pkgs; [
    bazelisk
    direnv
    dive
    fish
    fishPlugins.foreign-env
    jdk11
    kitty
    lazydocker
    lazygit
    mysql
    neofetch
    neovim
    tailscale
    tmux
    tokei
    tree
  ];
}
