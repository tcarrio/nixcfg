{ config, pkgs, sshMatrix, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  userName = "grigori";
in
{
  users.users."${userName}" = {
    description = "Remote builder daemon user";
    extraGroups = ifExists [ "docker" "podman" ];
    hashedPassword = "!"; # password login is disabled for this user
    homeMode = "0711";
    isNormalUser = true;
    openssh.authorizedKeys.keys = sshMatrix.groups.remote_build_clients;
    packages = [];
    shell = pkgs.bash;
    group = userName;
  };
  users.groups."${userName}" = {};
  nix.settings.trusted-users = [ userName ];
}
