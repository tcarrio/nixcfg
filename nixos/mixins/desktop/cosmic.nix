# NOTE: For COSMIC, the local build can consume a very large
# amount of memory. From the COSMIC flake docs:
#
# > Generally you will need roughly 16 GiB of RAM and 40 GiB of disk space,
# > but it can be built with less RAM by reducing build parallelism, either
# > via --cores 1 or -j 1 or both, on nix build, nix-build, and
# > nixos-rebuild commands.

_: {
  # Setup login screen and desktop manager to be COSMIC
  services.desktopManager.cosmic.enable = true;
  services.displayManager.gdm.enable = true;

  # Use the Gnome Keyring SSH agent setup over OpenSSH
  services.gnome.gcr-ssh-agent.enable = true;
  programs.ssh.startAgent = false;

  # Support for Clipboard Manager
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
}
