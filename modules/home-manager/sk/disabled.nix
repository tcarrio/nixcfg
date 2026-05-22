{ config, lib, pkgs, ... }: {
  # Configurations that only apply when a non-SK device is utilized
  config = lib.mkIf (!config.sk.enable) {
    home.packages = with pkgs.unstable; [
      mistral-vibe
    ];
  };
}
