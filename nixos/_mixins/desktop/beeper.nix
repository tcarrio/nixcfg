{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    beeper
  ];
}
