{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    neovide
  ];
}

