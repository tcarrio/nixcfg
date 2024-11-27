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
    modules = [
      ../home-manager
      inputs.agenix.homeManagerModules.default
    ];
  };

  # Helper function for generating host configs
  # - installer: can be one of the following:
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  mkHost = { hostname, username, systemType, desktop ? null, installer ? null }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs desktop hostname username stateVersion systemType sshMatrix;
    };
    modules = [
      ../nixos
      inputs.agenix.nixosModules.default
      inputs.chaotic.nixosModules.default
    ] ++ (inputs.nixpkgs.lib.optionals (installer != null) [ installer ])
    ++ (inputs.nixpkgs.lib.optionals (desktop == "cosmic") [
      {
        nix.settings = {
          substituters = [ "https://cosmic.cachix.org/" ];
          trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
        };
      }
      inputs.nixos-cosmic.nixosModules.default
    ]);
  };

  mkDarwin = { hostname, username, stateVersion ? 4, platform ? "aarch64-darwin" }: inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix;
    };
    modules = [
      ../darwin
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  mkSdImage = { hostname, username, platform ? "armv7l-linux" }: inputs.nixos-generators.nixosGenerate {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix;
    };

    system = platform;
    format =
      if platform == "armv7l-linux"
      then "sd-armv7l-installer"
      else "sd-aarch64-installer";

    # pkgs = inputs.nixpkgs.legacyPackages."${platform}";
    # lib = inputs.nixpkgs.legacyPackages."${platform}".lib;

    modules = [
      ../nixos
      inputs.agenix.nixosModules.default
    ];
  };

  mkGeneratorImage = { hostname, username, systemType, desktop ? null, platform ? "x86_64-linux", format ? "raw-efi", ... }@extraSpecialArgs: inputs.nixos-generators.nixosGenerate {
    specialArgs = {
      inherit self inputs outputs desktop hostname username stateVersion systemType sshMatrix;
    } // extraSpecialArgs;

    system = platform;
    inherit format;
    # pkgs = inputs.nixpkgs.legacyPackages."${platform}";
    # lib = inputs.nixpkgs.legacyPackages."${platform}".lib;

    modules = [
      (_: { nix.registry.nixpkgs.flake = inputs.nixpkgs; })
      ../nixos
      inputs.agenix.nixosModules.default
      # inputs.chaotic.nixosModules.default
      # {
      #   boot.kernelParams = [ "console=tty0" ]; # enable physical display tty, not serial port
      # }
    ];
  };

  forAllLinux = inputs.nixpkgs.lib.genAttrs [
    ## So long and thanks for all the fish
    # "armv7l-linux" # 32-bit ARM Linux
    # "i686-linux" # 32-bit x86 Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-linux" # 64-bit x86 Linux
  ];

  forAllDarwin = inputs.nixpkgs.lib.genAttrs [
    "aarch64-darwin" # 64-bit ARM Darwin
    "x86_64-darwin" # 64-bit x86 Darwin
  ];

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    ## So long and thanks for all the fish
    # "armv7l-linux" # 32-bit ARM Linux
    # "i686-linux" # 32-bit x86 Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-linux" # 64-bit x86 Linux
    "aarch64-darwin" # 64-bit ARM Darwin
    "x86_64-darwin" # 64-bit x86 Darwin
  ];
}
