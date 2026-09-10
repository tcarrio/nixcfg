{
  self,
  inputs,
  outputs,
  stateVersion,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;

  sshMatrix = import ./ssh/matrix.nix;
  tailnetMatrix = import ./tailnet-matrix.nix;

  overlaysModule = {
    nixpkgs.overlays = builtins.attrValues self.overlays;
  };
in
{
  # Build the flake's overlays with caller-supplied parameters. Internal
  # hosts use `self.overlays` (nixcfg's locked inputs); external consumers
  # can call this to substitute their own nixvim/bun2nix inputs or python.
  mkOverlays =
    {
      nixvim ? inputs.nixvim,
      bun2nix ? inputs.bun2nix,
      python ? null,
      ...
    }@args:
    # NOTE: @args captures only caller-supplied arguments, not defaults —
    # re-bind them explicitly so internal calls get nixcfg's locked inputs.
    import ../overlays (
      args
      // {
        inherit inputs;
        nixvim = args.nixvim or inputs.nixvim;
        bun2nix = args.bun2nix or inputs.bun2nix;
      }
    );

  # Helper function for generating home-manager configs.
  #
  # Optional-module toggles (withAgenix etc.) default to the historical
  # behavior for internal hosts; external consumers disable what they
  # don't want. extraModules/extraSpecialArgs append to the internal set.
  #
  # withProfileRoot toggles the internal personal profile tree
  # (../home-manager — git identity, ssh hosts, per-host files); external
  # consumers set it false and compose oxc.profiles.* modules instead.
  mkHome =
    {
      hostname,
      username,
      desktop ? null,
      platform ? "x86_64-linux",
      extraModules ? [ ],
      extraSpecialArgs ? { },
      withAgenix ? true,
      withHandy ? true,
      withCursorVoice ? true,
      withOverlays ? true,
      withProfileRoot ? true,
    }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          platform
          username
          stateVersion
          sshMatrix
          tailnetMatrix
          ;
      } // extraSpecialArgs;
      modules =
        (lib.optionals withProfileRoot [ ../home-manager ])
        ++ (lib.optionals withAgenix [ inputs.agenix.homeManagerModules.default ])
        ++ (lib.optionals withHandy [ inputs.handy.homeManagerModules.default ])
        ++ (lib.optionals withCursorVoice [ inputs.cursor-voice-plugin.homeManagerModules.default ])
        ++ (lib.optionals withOverlays [ overlaysModule ])
        ++ extraModules;
    };

  # Helper function for generating host configs
  # - installer: can be one of the following:
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  #    - "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  mkHost =
    {
      hostname,
      username,
      systemType,
      desktop ? null,
      installer ? null,
      determinate ? true,
      includeDisks ? (systemType != "iso"),
      extraModules ? [ ],
      extraSpecialArgs ? { },
      withAgenix ? true,
      withHandy ? true,
      withOverlays ? true,
    }:
    let
      isIso = builtins.substring 0 4 hostname == "iso-";
      isWorkstation = systemType == "workstation";
      agenixOverlaysModule = {
        nixpkgs.overlays = [ inputs.agenix.overlays.default ];
      };
    in
    lib.nixosSystem rec {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          desktop
          hostname
          username
          stateVersion
          systemType
          sshMatrix
          tailnetMatrix
          includeDisks
          ;
        adminGroup = "@wheel";
      } // extraSpecialArgs;
      modules =
        [
          ../nixos
          (import ./cache-settings.nix (specialArgs // { isDeterminateNix = determinate; }))
        ]
        ++ (lib.optionals withAgenix [
          inputs.agenix.nixosModules.default
          agenixOverlaysModule
        ])
        ++ (lib.optionals withHandy [ inputs.handy.nixosModules.default ])
        ++ (lib.optionals withOverlays [ overlaysModule ])
        ++ (lib.optionals (installer != null) [ installer ])
        ++ (lib.optionals isWorkstation [ inputs.chaotic.nixosModules.default ])
        ++ (lib.optionals (desktop != null && (isWorkstation || isIso)) [
          inputs.flatpaks.nixosModules.default
        ])
        ++ (lib.optionals (desktop == "hyprvibe") [ inputs.hyprvibe.nixosModules.default ])
        ++ (lib.optional includeDisks ../nixos/${systemType}/${hostname}/disks.nix)
        ++ extraModules;
    };

  mkDarwin =
    {
      hostname,
      username,
      desktop ? null,
      stateVersion ? 4,
      platform ? "aarch64-darwin",
      determinate ? true,
      extraModules ? [ ],
      extraSpecialArgs ? { },
      withHomeManager ? true,
      withOverlays ? true,
    }:
    inputs.nix-darwin.lib.darwinSystem rec {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          hostname
          username
          platform
          desktop
          stateVersion
          sshMatrix
          tailnetMatrix
          ;
        adminGroup = "@admin";
        isDeterminateNix = determinate;
      } // extraSpecialArgs;
      modules =
        [
          ../darwin
          (import ./cache-settings.nix (
            specialArgs
            // {
              isDeterminateNix = determinate;
              isDarwin = true;
            }
          ))
        ]
        ++ (lib.optionals withHomeManager [
          inputs.home-manager.darwinModules.home-manager
          outputs.darwinModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ])
        ++ (lib.optionals withOverlays [ overlaysModule ])
        ++ (lib.optionals determinate [ inputs.determinate.darwinModules.default ])
        ++ extraModules;
    };

  mkSdImage =
    {
      hostname,
      username,
      desktop ? null,
      platform ? "armv7l-linux",
    }:
    inputs.nixos-generators.nixosGenerate {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          desktop
          hostname
          username
          platform
          stateVersion
          sshMatrix
          tailnetMatrix
          ;
      };

      system = platform;
      format = if platform == "armv7l-linux" then "sd-armv7l-installer" else "sd-aarch64-installer";

      # pkgs = inputs.nixpkgs.legacyPackages."${platform}";
      # lib = inputs.nixpkgs.legacyPackages."${platform}".lib;

      modules = [
        ../nixos
        inputs.agenix.nixosModules.default
        overlaysModule
      ];
    };

  mkGeneratorImage =
    {
      hostname,
      username,
      systemType,
      desktop ? null,
      platform ? "x86_64-linux",
      format ? "raw-efi",
      extraModules ? {
        chaotic = false;
      },
      ...
    }@extraSpecialArgs:
    inputs.nixos-generators.nixosGenerate {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          desktop
          hostname
          username
          stateVersion
          systemType
          sshMatrix
          tailnetMatrix
          ;
      }
      // extraSpecialArgs;

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
        overlaysModule
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
    # "x86_64-darwin" # 64-bit x86 Darwin
  ];

  forAllSystems = lib.genAttrs [
    ## So long and thanks for all the fish
    # "armv7l-linux" # 32-bit ARM Linux
    # "i686-linux" # 32-bit x86 Linux
    "aarch64-linux" # 64-bit ARM Linux
    "x86_64-linux" # 64-bit x86 Linux
    "aarch64-darwin" # 64-bit ARM Darwin
    # "x86_64-darwin" # 64-bit x86 Darwin
  ];
}
