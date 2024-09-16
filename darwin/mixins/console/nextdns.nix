{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nextdns
  ];

  services.nextdns = {
    enable = true;
    arguments = ["-profile" "ecefa7" "-report-client-info" "-auto-activate"];
  };
}
