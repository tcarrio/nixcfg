{ pkgs, ... }: {
  imports = [
    ../../nixos/console/auth0.nix
    ../../nixos/console/direnv.nix
    ../../nixos/console/kubectl.nix
  ];

  environment.systemPackages = with pkgs; [
    # various dev tooling
    bazelisk
    direnv
    jdk11
    kitty
    lazygit
    mariadb
    neovim
    tailscale

    # containers containers containers
    dive
    lazydocker

    # utilities
    neofetch
    tmux
    slumber
    tokei
    tree
  ];
}
