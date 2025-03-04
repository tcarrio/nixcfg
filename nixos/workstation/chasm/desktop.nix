{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
    rustdesk
  ];

  oxc.desktop.zen-browser.enable = true;
}
