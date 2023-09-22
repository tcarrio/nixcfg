{ nix-homebrew, homebrew-core, homebrew-cask, username, platform, ... }: {
  imports = [
    nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = false;
    
    # enables the prefix under the given user instead of globally
    # user = "${username}";

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = true;

    # automatically incorporate any existing Homebrew installations
    autoMigrate = true;

    enableRosetta = platform == "aarch64-darwin";
  };
}