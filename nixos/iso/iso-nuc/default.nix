{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  users.users.root = {
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
  };

}
