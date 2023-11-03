{ sshMatrix, ... }:
{
  users.users.root = {
    # mkpasswd -m sha-512
    hashedPassword = "$6$72XmnQnco5HkNtFh$AG9emNqa1Ig/ZHGOIVM07cInlf/FIfo5PvtsADFOfiEv8VQNWJTOtwDILG6GbmJ/APGubRWoilpio9FlWw5d30";
    openssh.authorizedKeys.keys = [
      sshMatrix.systems.glass.tcarrio
    ];
  };
}
