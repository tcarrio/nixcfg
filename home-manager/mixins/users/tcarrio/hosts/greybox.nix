# greybox: Ubuntu workstation managed exclusively through home-manager.
# There is no NixOS/darwin system layer for this host — everything Nix
# provides lives here. One-time system setup (apt repos, groups, shells,
# udev) is documented in docs/non-nixos-linux.md.

{
  lib,
  pkgs,
  ...
}:
let
  # Anthropic release signing key, shared by the claude-code and
  # claude-desktop apt repositories. Defined inline — deterministic
  # definition, dearmored at build time.
  # Verified fingerprint (https://code.claude.com/docs/en/setup):
  #   31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE

  anthropicKeyInfo = {
    text = ''
      -----BEGIN PGP PUBLIC KEY BLOCK-----

      mQINBGnK73ABEACnbytJXkjweYrwIr0aLEFRlH+C0nF44KxFc7gQmJ6PjSPMGZAD
      dxZcaixU7zZl8WxEpVO0wLmIH8cf2zGOdyuZg1Yaugk1vHb2b8WBhAGCQJdPgB8W
      XquedepEYtk56uP/gCoTjJDUZluEGBHnlnuujSJ4orxEdhSykEoAUfJZGEILPpMd
      bphFt/Sn+Eb/TxM5jpKPdwnv8AShNF/1mZU1fWTQq9tRKJUakZj04gdaDFElQXak
      CtTij+GT6yoYCARSHwGO+PC/Pr6q4tc+D7LRjxSBvUWDoFSmlqb/PJ1hj9D/7I2O
      e4XXniAPWMR56KvxHlzOzrNQdJujbJdSkCwh1ZijkSd3y8ayW5WYUTGdRab99NUw
      agzlabe/VVF6kzJ0Scn5q3PihB2Y9Bwo0CKnkYk7a7KT77EWv0Kkq+VHmOtqX3a2
      hhX+b6a6ve9rzJ1qZYGj+obv/C3Sx1LzUjAfqVy7RJDf2uAoP5t2g8u/TkSpUxhM
      VEjZBkSxYZhMyzQM6t8IgkUfnSrIPTHixbDWARZ4beMOBjxyPZK1nP7OOrNR3TkK
      JtwLMQAabURCDnL0PjS0iwBTU4jtumBD1XSULyWuoTvMljrpQr1nV1oDyOt0OLqa
      KA2McWtd9PdXhC8y2EIg7TmrTlJLfHYbdmkiCYj4J49Q8HWkN/6WE+RTUwARAQAB
      tD5BbnRocm9waWMgQ2xhdWRlIENvZGUgUmVsZWFzZSBTaWduaW5nIDxzZWN1cml0
      eUBhbnRocm9waWMuY29tPokCUQQTAQoAOxYhBDHd3iTd+rZ59C170rqpKf8afsrO
      BQJpyu9wAhsPBQsJCAcCAiICBhUKCQgLAgQWAgMBAh4HAheAAAoJELqpKf8afsrO
      l5IP/2I8X1dFy5xYczWB/coIxGjuzS/V6ByZGZZEJsbr04pmuHiFUykJqPGWGQ6q
      U0YF5iEwvEkaagS5m7DzhSEf3FM3Cgafax/6d70tar9Vr1D+w6uPfxetu7u/WYJp
      aolIsdh5fTrBh9zSM1Njl8FM8wG8CwZQjS33Oa7d8cwRkgdUWbt6LXgz+cTQNuBn
      BgW6Ks7oZFI25dfu0ojDR+aDFJg4+4wZoyDLPvJz1SIrJ5WFGs67zsx9SfS3yZnf
      XKmBe+f0dUy+GJ2nFZrXFf99+c0dPEHYO8DCeAHZizjkFrdYtUHdDU0YDYEGkLJa
      bE+pgcpkHf5EvsZzHsyDbl95W/eh7pcXMbwkN+W4CBYUE9X4uHhqzWaC5yAVRWUA
      1BJ9V4LjZfHPLEJt0I3TxzXiEg9/BVeaTYq9RjaxIFo9Nfk158HqJY6SA5jslBlx
      Gv/No8u+xVcze2UJyGVfEIUfm92+0UAIkny3+5cuVV0ICzJxXlXj0CnLM9Lt50wE
      p3suVwuBEviCbZ08eAH1Ht8gbBdSsiOkIU8CX3v/scwHHx5q0+NBL6xLrQObg13a
      tRXBlKObfElkPN3lTUbUnJOW4U8uSjH8VRP+AujKWMDFe7x0zCs+iYY1mTOvbrTS
      9n3CmZUmbynZ+E/QWNENpW/pDNZdWFy43PASmML5FHu4m9Sn
      =oqMI
      -----END PGP PUBLIC KEY BLOCK-----
      '';
    fingerprint = "31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE";
  };

  claudeAptRepositoryInfo = {
    suites = [ "stable" ];
    components = [ "main" ];
    key = anthropicKeyInfo;
  };
in
{
  imports = [ ];

  # VS Code settings.json — the deb-installed `code` reads the same path
  oxc.desktop.vscode.enable = true;

  # Lean footprint: no niche extras, no recording/tracking utilities
  oxc.console.modern-unix.extras = false;
  oxc.console.tools.eza = false;
  oxc.console.asciinema.enable = false;
  oxc.console.zeit.enable = false;

  # Apt-managed state: converged on every `home-manager switch` (sudo
  # prompt only when something's missing or a repository changed) and also
  # available manually via `apt-sync` / `task apt:sync`.
  oxc.apt.onActivation.enable = true;

  # Anthropic signed apt repositories (preferred over .deb downloads):
  # keyring -> /etc/apt/keyrings/, sources -> /etc/apt/sources.list.d/,
  # then apt update + plain-name installs.
  oxc.apt.repositories = {
    claude-code = claudeAptRepositoryInfo // {
      url = "https://downloads.claude.ai/claude-code/apt/stable";
    };
    claude-desktop = claudeAptRepositoryInfo // {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable";
    };
  };
  oxc.apt.packages = [ "claude-code" "claude-desktop" ];

  # VS Code is not in Ubuntu's stock repositories — the stable-redirect
  # download URLs (arch-mapped) install it without the Microsoft apt repo.
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
