{ self, inputs, outputs, stateVersion, ... }:
let
  sshMatrix = import ./ssh-matrix.nix { };
in
{
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? "x86_64-linux" }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${platform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion sshMatrix;
    };
    modules = [ ../home-manager ];
  };

  # Helper function for generating host configs
  # - installer: can be one of the following:
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  mkHost = { hostname, username, desktop ? null, installer ? null, systemType ? null }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs desktop hostname username stateVersion systemType sshMatrix;
    };
    modules = [
      ../nixos
      inputs.agenix.nixosModules.default
    ] ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ]);
  };

  mkDarwin = { hostname, username, stateVersion ? 4, platform ? "aarch64-darwin" }: inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix;
    };
    modules = [
      ../macos
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  mkDroid = { hostname, username, stateVersion ? 4, platform ? "aarch64-linux" }: inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix;
    };
    modules = [
      ../android
    ];
  };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "armv7l-linux"   # 32-bit ARM Linux
    "aarch64-linux"  # 64-bit ARM Linux
    "i686-linux"     # 32-bit x86 Linux
    "x86_64-linux"   # 64-bit x86 Linux
    "aarch64-darwin" # 64-bit ARM Darwin
    "x86_64-darwin"  # 64-bit x86 Darwin
  ];
}
