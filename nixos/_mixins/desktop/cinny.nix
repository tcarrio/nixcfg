{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    cinny-desktop
  ];
}
