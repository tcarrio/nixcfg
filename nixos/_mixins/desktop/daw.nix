{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    ardour
    hydrogen
    tenacity
  ];
}