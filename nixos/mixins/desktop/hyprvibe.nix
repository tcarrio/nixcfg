{ username, ... }: {
  hyprvibe = {
    enable = true;
    fonts.enable = true;

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
      openssh.enable = true;
      tailscale.enable = true;
      virt.enable = true;
      docker.enable = true;
    };

    shell.enable = false;

    waybar.enable = true;

    inherit username;
  };
}