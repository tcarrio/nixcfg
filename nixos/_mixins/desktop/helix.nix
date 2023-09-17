{ pkgs, inputs, ... }: {
  environment.systemPackages = with inputs.helix.packages.${pkgs.system}; [
    helix
  ];
}
