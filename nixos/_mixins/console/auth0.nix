{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    auth0
  ];
}
