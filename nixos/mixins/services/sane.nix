{ pkgs, ... }: {
  oxc.desktop.simple-scan.enable = true;

  hardware = {
    sane = {
      enable = true;
      #extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
      extraBackends = with pkgs; [ sane-airscan ];
    };
  };
}
