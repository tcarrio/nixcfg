# greybox: Ubuntu workstation managed exclusively through home-manager.
# There is no NixOS/darwin system layer for this host — everything Nix
# provides lives here. One-time system setup (apt repos, groups, shells,
# udev) is documented in docs/non-nixos-linux.md.

{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  # VS Code settings.json — the deb-installed `code` reads the same path
  oxc.desktop.vscode.enable = true;

  # Lean footprint: no niche extras, no recording/tracking utilities
  oxc.console.modern-unix.extras = false;
  oxc.console.tools.eza = false;
  oxc.console.asciinema.enable = false;
  oxc.console.zeit.enable = false;

  # Deb-managed packages: converged on every `home-manager switch`
  # (after profile install; sudo prompt only when something's missing)
  # and also available manually via `deb-sync` / `task deb:sync`.
  # VS Code is not in Ubuntu's stock repositories — the stable-redirect
  # download URLs (arch-mapped) install it without the Microsoft apt repo.
  oxc.apt.onActivation.enable = true;
  oxc.apt.sources.code.url = {
    x86_64-linux = "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64";
    aarch64-linux = "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64";
  };

  # Ghostty: graphical nix packages need nixGL wrapping on non-NixOS —
  # deferred; the binary comes from the community .deb instead (official
  # Ubuntu repos carry ghostty only from 26.04). The module stays enabled
  # with an empty package so HM still writes the ghostty config + theme;
  # only the binary install is deb-managed. Pinned release; refresh the
  # tag/asset version here when updating. The apt-repo alternative
  # (ppa:mkasberg/ghostty-ubuntu) becomes preferred once oxc.apt gains
  # repository mappings.
  oxc.desktop.ghostty.linuxPackage = pkgs.empty;
  oxc.apt.sources.ghostty.url = {
    x86_64-linux = "https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.3.1-0-ppa2/ghostty_1.3.1-0.ppa2_amd64_\${ubuntu_version}.deb";
    aarch64-linux = "https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.3.1-0-ppa2/ghostty_1.3.1-0.ppa2_arm64_\${ubuntu_version}.deb";
  };

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
