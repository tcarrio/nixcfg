{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    direnv
  ];
}
