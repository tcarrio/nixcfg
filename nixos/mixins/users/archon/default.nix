{ config, pkgs, sshMatrix, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  environment.systemPackages = with pkgs; [ ];

  users.users.archon = {
    description = "Archon";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$LDl7IafzpHZXcpKL$ZSQA9vHW/V50TxV9ugzukuJ0HWnQzGiD/3qMf9d1JRtJwfUa2LqYiMUrKqA8Qx6aorbOHW6peYoKYdFF0ue6D.";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };

  security.sudo.extraRules = [
    {
      users = [ "archon" ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
