{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    rustdesk
  ];

  oxc.desktop.zen-browser.enable = true;
}