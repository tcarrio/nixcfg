{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "wt";
  text = lib.readFile ./wt.sh;
  runtimeInputs = with pkgs; [
    git
  ];
}
