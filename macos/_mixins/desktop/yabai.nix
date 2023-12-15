{ inputs, ... }: {
  imports = [
    ../console/homebrew.nix
  ];

  nix-homebrew.enable = true;
  nix-homebrew.taps."homebrew/homebrew-koekeishiya" = inputs.homebrew-koekeishiya;
}
