{ desktop, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    maestral
  ] ++ lib.optionals (desktop != null) [
    maestral-gui
  ];
}
