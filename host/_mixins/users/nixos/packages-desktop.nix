{ pkgs, ... }: {

  programs = {
    firefox.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome.dconf-editor
  ];
}