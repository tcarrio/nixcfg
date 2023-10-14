{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    element-desktop
  ];
}
