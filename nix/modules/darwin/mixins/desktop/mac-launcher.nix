{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    mac-launcher
  ];
}

