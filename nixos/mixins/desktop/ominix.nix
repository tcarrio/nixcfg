{ pkgs, username, ... }: {
  ominix.enable = true;
  ominix.user = username;

  # TODO: Remove?
  # services.displayManager.defaultSession = "none+hyprland";
}

