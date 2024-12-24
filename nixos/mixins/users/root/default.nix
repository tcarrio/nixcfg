{ lib, ... }:
{
  users.users.root = {
    # mkpasswd -m sha-512
    hashedPassword = "$6$FGMdV6JzcaHdCnQt$yOu9i9B2NOxsb6MPg1yxgNOifyMC/QveHsADtTuTvxpahf0yb610y.fCkQolYgdAp4Ih1zHsRQS9U71yh5.iS1";
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
  };

  services.openssh.settings.PermitRootLogin = lib.mkDefault "no";
}
