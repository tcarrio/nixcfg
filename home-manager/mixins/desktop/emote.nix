{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
lib.mkIf (system == "linux") {
  # https://github.com/tom-james-watson/emote
  home.packages = with pkgs; [
    emote
  ];

  systemd.user.services = {
    emote = {
      Unit = {
        Description = "Emote";
      };
      Service = {
        ExecStart = "${pkgs.emote}/bin/emote";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
