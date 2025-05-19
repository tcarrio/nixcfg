{ pkgs, ... }: {
  services = {
    kmscon = {
      enable = true;
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
