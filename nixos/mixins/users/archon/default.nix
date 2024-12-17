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
    hashedPassword = "$6$5WbXGt2QSz4kW6.C$qSXi2dOP.axtrDV6h4Ljh5Upls5fLRGNAdshQ0jJdvMiVRjQPV718ST9pSMaW0boIjHyETxq9yF9ZgJw797gU/";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };

  security.sudo.extraRules = [
    { users = [ "archon" ];
      options = [ "NOPASSWD" ];
    }
  ];
}
