{ inputs, username, platform, ... }: {
  nix-homebrew = {
    enable = true;

    # enables the prefix under the given user instead of globally
    user = username;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # other tooling interacts via Brew CLI so this is required
    mutableTaps = true;

    # automatically incorporate any existing Homebrew installations
    autoMigrate = true;

    enableRosetta = platform == "aarch64-darwin";
  };
}
