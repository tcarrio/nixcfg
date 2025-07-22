_: {
  imports = [../console/podman.nix];

  # Configuration file for podman-desktop
  # ~/.local/share/containers/podman-desktop/configuration/settings.json

  homebrew.casks = ["podman-desktop"];
}

