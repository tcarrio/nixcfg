{ username, ... }: {
  hyprvibe = {
    desktop = {
      enable = true;
      fonts.enable = true;
    };

    hyprland = {
      enable = true;
      waybar.enable = true;
    };

    packages = {
      enable = true;
      base.enable = true;
      desktop.enable = true;
      dev.enable = true;
      gaming.enable = true;
    };

    services = {
      enable = true;
      openssh.enable = false;
      tailscale.enable = false;
      virt.enable = false;
      docker.enable = false;
    };

    shell.enable = false;

    waybar.enable = true;

    user = {
      inherit username;
    };
  };
}