{ self, inputs, outputs, stateVersion, ... }: {
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? "x86_64-linux" }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${platform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion;
    };
    modules = [ ../home-manager ];
  };

  # Helper function for generating host configs
  # - installer: can be one of the following:
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  mkHost = { hostname, username, desktop ? null, installer ? null, systemType ? null }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs desktop hostname username stateVersion systemType;
    };
    modules = [
      ../nixos
      inputs.agenix.nixosModules.default
    ] ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
  };

  mkDarwin = { hostname, username, stateVersion ? 4, platform ? "aarch64-darwin" }: inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion;
    };
    modules = [../macos];
  };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "armv7l-linux"
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
