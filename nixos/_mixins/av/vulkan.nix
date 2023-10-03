{ pkgs, ... }:
{
  # enable video support and vulkan drivers
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.support32Bit = true;
  environment.systemPackages = [ pkgs.vulkan-tools ];
}