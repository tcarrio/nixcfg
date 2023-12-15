{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    sketchybar
    sketchybar-app-font
  ];
}
