_:
{
  users.users.root = {
    hashedPassword = null;
    openssh.authorizedKeys.keys = sshMatrix.groups.privileged_users;
  };
}
