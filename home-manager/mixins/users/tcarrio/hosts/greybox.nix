# greybox: Ubuntu workstation managed exclusively through home-manager.
# There is no NixOS/darwin system layer for this host — everything Nix
# provides lives here. One-time system setup (apt repos, groups, shells,
# udev) is documented in docs/non-nixos-linux.md.

{
  pkgs,
  ...
}:
{
  imports = [
    # VS Code settings.json — the deb-installed `code` reads the same path
    ../../../desktop/vscode.nix
  ];

  # Deb-managed packages, applied via `deb-sync` / `task deb:sync`.
  # The Microsoft apt repo for `code` is a one-time setup step in the docs.
  oxc.deb.packages = [ "code" ];

  programs = {
    gpg = {
      enable = true;
    };

    ssh = {
      # Agent forwarding etc. are left to the user's ~/.ssh/config entries;
      # this only pins the agent gpg-agent exposes for SSH authentication.
      matchBlocks = { };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # GNOME desktop: graphical pinentry over the curses/tty fallbacks
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;
  };

  home = {
    # gpg-agent's SSH socket — replaces NixOS's programs.ssh.startAgent on
    # hosts with a system layer.
    sessionVariables = {
      SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh";
    };

    packages =
      (with pkgs; [
        # Container CLIs (daemons themselves are apt-managed, see docs)
        dive
        lazydocker

        # Nix-managed fonts for the GNOME session
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono

        # Rebuild NixOS servers remotely from this host
        nixos-rebuild-ng
      ])
      ++ (with pkgs.unstable; [ typescript-go ]);
  };

  programs.fish = {
    # Home-manager-only life: no system configuration to rebuild
    shellAliases = {
      rebuild-home = "home-manager switch -b backup --flake $HOME/0xc/nixcfg#thomascarrio@greybox";
      rebuild-all = "nix-gc && rebuild-home";
      nix-gc = "nix-collect-garbage --delete-older-than 28d";
      rebuild-host = "echo 'No system layer on this host — see docs/non-nixos-linux.md' && return 1";
    };
  };
}
