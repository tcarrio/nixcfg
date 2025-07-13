{ pkgs, username, ... }: {
  ominix.enable = true;
  ominix.user = username;
  ominix.theme = "everforest";

  # TODO: Remove?
  # services.displayManager.defaultSession = "none+hyprland";
}

