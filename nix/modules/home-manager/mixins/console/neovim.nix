{ pkgs, ... }: {
  home.packages = with pkgs; [
    nixvim  # Custom nixvim package with Tokyo Night theme and full config
  ];
}
