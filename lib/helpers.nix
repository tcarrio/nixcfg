{ self, inputs, outputs, stateVersion, ... }:
let
   inherit (inputs.nixpkgs) lib;

  sshMatrix = import ./ssh-matrix.nix { };
  tailnetMatrix = import ./tailnet-matrix.nix { };
in
{
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? "x86_64-linux" }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${platform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion sshMatrix tailnetMatrix;
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
  mkHost = { hostname, username, systemType, desktop ? null, installer ? null, determinate ? true }: lib.nixosSystem rec {
    specialArgs = {
      inherit self inputs outputs desktop hostname username stateVersion systemType sshMatrix tailnetMatrix;
      adminGroup = "@wheel";
    };
    modules = [
      ../nixos
      (import ./cache-settings.nix (specialArgs // { isDeterminateNix = determinate; }))
      inputs.agenix.nixosModules.default
      inputs.chaotic.nixosModules.default
    ]
    ++ (lib.optionals (installer != null) [ installer ])
    ++ (lib.optionals determinate [ inputs.determinate.nixosModules.default ]);
  };

  mkDarwin = { hostname, username, stateVersion ? 4, platform ? "aarch64-darwin", determinate ? true }: inputs.nix-darwin.lib.darwinSystem rec {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix tailnetMatrix;
      adminGroup = "@admin";
    };
    modules = [
      ../darwin
      (import ./cache-settings.nix (specialArgs // { isDeterminateNix = determinate; }))
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ] ++ (if determinate then [
      inputs.determinate.darwinModules.default
    ] else []);
  };

  mkSdImage = { hostname, username, platform ? "armv7l-linux" }: inputs.nixos-generators.nixosGenerate {
    specialArgs = {
      inherit self inputs outputs hostname username platform stateVersion sshMatrix tailnetMatrix;
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

  mkGeneratorImage = { hostname, username, systemType, desktop ? null, platform ? "x86_64-linux", format ? "raw-efi", extraModules ? { chaotic = false; }, ... }@extraSpecialArgs: inputs.nixos-generators.nixosGenerate {
    specialArgs = {
      inherit self inputs outputs desktop hostname username stateVersion systemType sshMatrix tailnetMatrix;
    } // extraSpecialArgs;

    system = platform;
    inherit format;
    # pkgs = inputs.nixpkgs.legacyPackages."${platform}";
    # lib = inputs.nixpkgs.legacyPackages."${platform}".lib;

    modules = [
      (_: { nix.registry.nixpkgs.flake = inputs.nixpkgs; })
      ../nixos
      inputs.agenix.nixosModules.default
      {
        boot.kernelParams = [ "console=tty0" ]; # enable physical display tty, not serial port
      }
    ]
    ++ (lib.optional extraModules."chaotic" inputs.chaotic.nixosModules.default);
  };

  forAllLinux = lib.genAttrs [
    ## So long and thanks for all the fish
    # "armv7l-linux" # 32-bit ARM Linux
    # "i686-linux" # 32-bit x86 Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-linux" # 64-bit x86 Linux
  ];

  forAllDarwin = lib.genAttrs [
    "aarch64-darwin" # 64-bit ARM Darwin
    "x86_64-darwin" # 64-bit x86 Darwin
  ];

  forAllSystems = lib.genAttrs [
    ## So long and thanks for all the fish
    # "armv7l-linux" # 32-bit ARM Linux
    # "i686-linux" # 32-bit x86 Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-linux" # 64-bit x86 Linux
    "aarch64-darwin" # 64-bit ARM Darwin
    "x86_64-darwin" # 64-bit x86 Darwin
  ];
}
