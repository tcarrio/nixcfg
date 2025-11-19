{ pkgs, ... }: {
  imports = [
    ../../nixos/console/auth0.nix
    ../../nixos/console/direnv.nix
    ../../nixos/console/kubectl.nix
  ];

  environment.systemPackages = (with pkgs.unstable; [
    # various dev tooling
    bazelisk
    jdk11
    kitty
    lazygit
    mariadb
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

    # ai tooling
    claude-code
    cursor-cli
  ]) ++ (with pkgs; [
    # Neovim overlays onto base pkgs
    neovim
  ]);
}
