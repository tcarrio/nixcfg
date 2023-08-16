{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
    package = pkgs.unstable.firefox;
  };
}
