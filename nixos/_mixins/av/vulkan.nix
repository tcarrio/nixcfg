{ pkgs, lib, ... }:
{
  # enable video support and vulkan drivers
  hardware.opengl.enable = lib.mkDefault true;
  hardware.opengl.driSupport = lib.mkDefault true;
  hardware.opengl.driSupport32Bit = lib.mkDefault true;

  hardware.pulseaudio.support32Bit = lib.mkDefault true;
  environment.systemPackages = [ pkgs.vulkan-tools ];
}