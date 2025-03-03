{ config, desktop, lib, pkgs, sshMatrix, username, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  install-system = pkgs.writeScriptBin "install-system" (builtins.readFile ../../../../scripts/install.sh);
in
{
  # Only include desktop components if one is supplied.
  imports = lib.optional (builtins.isString desktop) ./desktop.nix;

  # TODO: Determine cause of error in
  # nix.registry.nixpkgs.to.path

  config.users.users.nixos = {
    description = "NixOS";
    extraGroups = [
      "audio"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    group = "nixos";
    isNormalUser = true;
    homeMode = "0755";

    hashedPassword = "$6$FGMdV6JzcaHdCnQt$yOu9i9B2NOxsb6MPg1yxgNOifyMC/QveHsADtTuTvxpahf0yb610y.fCkQolYgdAp4Ih1zHsRQS9U71yh5.iS1";
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;

    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
  config.users.groups.nixos = { };

  config.system.stateVersion = lib.mkForce lib.trivial.release;
  config.environment.systemPackages = [ install-system ];
  config.services.kmscon.autologinUser = "${username}";
}
