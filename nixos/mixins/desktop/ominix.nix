{ pkgs, username, ... }: {
  ominix.enable = true;
  ominix.user = "tcarrio";

  # TODO: Remove?
  # services.displayManager.defaultSession = "none+hyprland";
}

