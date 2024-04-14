{ pkgs, username, ... }:
let 
  hidrawAccessGroup = "plugdev";
in {
  environment.systemPackages = with pkgs; [
    roccat-tools
  ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="${hidrawAccessGroup}"
  '';

  users.groups.plugdev = {};

  users.users.${username}.extraGroups = [ hidrawAccessGroup ];
}