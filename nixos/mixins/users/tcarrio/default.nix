{ config, desktop, lib, pkgs, sshMatrix, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = with pkgs; [
    yadm # Terminal dot file manager
    neovim
  ];

  users.users.tcarrio = {
    description = "Tom Carrio";
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
      "nordvpn"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$uLtXsdZpgBd/iVao$L3Lk9vmQMOfZrARIyl6Sq6ZbU91d53dWQteZADxkgLJ8FZUet.L4E73LnmVccJUGdAUcMQ1cuISS9j0XygM2Q1";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
