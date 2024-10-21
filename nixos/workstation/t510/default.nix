# Device:      Lenovo ThinkPad T510
# CPU:         Intel i5 M 520
# RAM:         8GB DDR2
# SATA:        120GB SSD

{ inputs, lib, pkgs, ... }: {
  imports = [
    ../t510-headless
  ];

  environment.systemPackages = with pkgs; [
    alacritty
  ];

  oxc = {
    desktop = {
      bitwarden.enable = true;
      # zed.enable = true;

      vscode.support = {
        deno = true;
      };

      # override default browser
      zen-browser.enable = true;
      google-chrome.enable = lib.mkForce false;
      chromium.enable = lib.mkForce false;
      firefox.enable = lib.mkForce false;
    };
  };
}
