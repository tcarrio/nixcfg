{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    skhd
  ];
}
