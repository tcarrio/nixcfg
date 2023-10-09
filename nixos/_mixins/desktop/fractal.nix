{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.unstable.fractal
  ];
}