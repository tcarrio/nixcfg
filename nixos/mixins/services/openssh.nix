{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    sshguard = {
      enable = true;
      whitelist = [
        "192.168.40.0/24"
        "10.0.0.0/8"
        "100.0.0.0/8"
      ];
    };
  };
  programs.ssh.startAgent = lib.mkOverride 999 true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
