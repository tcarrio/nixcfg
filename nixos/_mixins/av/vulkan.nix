{ pkgs, ... }:
{
  # enable video support and vulkan drivers
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;
  environment.systemPackages = [ pkgs.vulkan-tools ];
}