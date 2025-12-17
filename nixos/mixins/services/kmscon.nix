{ pkgs, config, ... }: {
  services = {
    kmscon = {
      # Handle DRM race condition between Nvidia driver and KMSCON
      enable = !config.hardware.nvidia.modesetting.enable;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      }];
      extraConfig = ''
        font-size=14
        xkb-layout=us
      '';
    };
  };
}
