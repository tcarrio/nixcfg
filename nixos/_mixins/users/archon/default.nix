{ config, desktop, lib, pkgs, sshMatrix, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  environment.systemPackages = with pkgs; [
    neovim
  ];

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
    hashedPassword = "$6$uLtXsdZpgBd/iVao$L3Lk9vmQMOfZrARIyl6Sq6ZbU91d53dWQteZADxkgLJ8FZUet.L4E73LnmVccJUGdAUcMQ1cuISS9j0XygM2Q1";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = with sshMatrix.systems; [
      # Add any authorized keys for SSH access here
      glass.tcarrio
      sktc0.tcarrio
      pixel6a.nix-on-droid
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
