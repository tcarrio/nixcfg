{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "vid2gif";
  text = lib.readFile ./vid2gif.sh;
  # GIF encoding needs only native encoders/filters (gif, palettegen,
  # paletteuse, fps, scale); headless drops the GUI/device deps of ffmpeg-full.
  runtimeInputs = [ pkgs.ffmpeg-headless ];
}
