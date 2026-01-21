{
  description = "tcarrio's NixOS and Home Manager Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://install.determinate.systems"
      "https://cache.flakehub.com"
      "https://nix-community.cachix.org"
      "https://nix-darwin.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-darwin.cachix.org-1:G6r3FhSkSwRCZz2d8VdAibhqhqxQYBQsY3mW6qLo5pA="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    extra-trusted-substituters = [
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    # Primary source from FlakeHub follows the current release cycle, e.g. 25.11.
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";

    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-trunk.url = "github:nixos/nixpkgs/master";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Chaotic's Nyx provides many additional packages like NordVPN
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    devshells.url = "github:tcarrio/devshells";
    devshells.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin support with nix-darwin
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-generators for sdcard and raw disk install generation
    nixos-generators.url = "github:tcarrio/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Extended Flatpak configuration
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    # Bun packaging
    bun2nix.url = "github:baileyluTCD/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";

    # Python uv packaging (uv2nix)
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    pyproject-nix.inputs.nixpkgs.follows = "nixpkgs";

    uv2nix.url = "github:pyproject-nix/uv2nix";
    uv2nix.inputs.pyproject-nix.follows = "pyproject-nix";
    uv2nix.inputs.nixpkgs.follows = "nixpkgs";

    pyproject-build-systems.url = "github:pyproject-nix/build-system-pkgs";
    pyproject-build-systems.inputs.pyproject-nix.follows = "pyproject-nix";
    pyproject-build-systems.inputs.uv2nix.follows = "uv2nix";
    pyproject-build-systems.inputs.nixpkgs.follows = "nixpkgs";

    # Nixvim for neovim configuration
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Determinate Nix modules
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Hyprvibe (Hyprland) setup
    hyprvibe.url = "github:tcarrio/hyprvibe";

    # Gaming flakes for Star Citizen, Rocket League, etc.
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";

    # Ghostty theming
    ghostty-catppuccin.url = "github:catppuccin/ghostty";
    ghostty-catppuccin.flake = false;
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , devshells
    , nix-darwin
    , bun2nix
    , nixvim
    , uv2nix
    , pyproject-nix
    , pyproject-build-systems
    , ...
    } @ inputs:
    let
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.05";

      inherit (self) outputs;
      inherit (nixpkgs) lib;
      libx = import ./lib { inherit self inputs outputs stateVersion; };
      overlays = import ./overlays { inherit inputs; };

      mkPkgsForSystemFromInput = system: input: import input {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = builtins.attrValues overlays;
      };

      mkSystemFlakeShell = system:
        let
          mkPkgsFromInput = mkPkgsForSystemFromInput system;
          pkgs = mkPkgsFromInput nixpkgs;
          darwinNixPkgs = if pkgs.stdenv.isDarwin then nix-darwin.packages.${system} else { };
          bun2NixPkg = bun2nix.packages.${system}.default;
        in
        shellOptionsFactory: pkgs.mkShell ((shellOptionsFactory { inherit pkgs darwinNixPkgs bun2NixPkg; }) // { NIX_CONFIG = "experimental-features = nix-command flakes pipe-operators"; });

      devShellFactory = { pkgs, bun2NixPkg, ... }: {
        packages = (
          with pkgs; [
            home-manager
            git
            cargo
            gcc
            go-task
            wakeonlan
            yarn2nix
          ]
        ) ++ (
          with pkgs.unstable; [
            bun
            bun2NixPkg
            flyctl
          ]
        );
      };
    in
    {
      apps = libx.forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkShellApp = { name ? "script.sh", runtimeInputs ? [ ], ... } @ opts:
            pkgs.writeShellApplication (opts // { inherit name runtimeInputs; });

          mkShellAppPath = opts: let app = mkShellApp opts; in "${app}/bin/${app.name}";
        in
        {
          build-rolling = {
            type = "app";
            program = mkShellAppPath {
              text = builtins.readFile ./scripts/shell/build-rolling.sh;
            };
          };
        }
      );

      # home-manager switch -b backup --flake $HOME/0xc/nixcfg
      # nix build .#homeConfigurations."tcarrio@ripper".activationPackage
      homeConfigurations = {
        # .iso images
        "nixos@iso-nuc" = libx.mkHome { hostname = "iso-nuc"; username = "nixos"; };

        # Workstations
        "tcarrio@sktc0" = libx.mkHome { hostname = "sktc0"; username = "tcarrio"; platform = "aarch64-darwin"; };
        "tcarrio@sktc1" = libx.mkHome { hostname = "sktc1"; username = "tcarrio"; platform = "aarch64-darwin"; };
        "tcarrio@sktc2" = libx.mkHome { hostname = "sktc2"; username = "tcarrio"; platform = "aarch64-darwin"; };
        "tcarrio@glass" = libx.mkHome { hostname = "glass"; username = "tcarrio"; desktop = "kde6"; };
        "tcarrio@obsidian" = libx.mkHome { hostname = "obsidian"; username = "tcarrio"; desktop = "gnome"; };
        "tcarrio@void" = libx.mkHome { hostname = "void"; username = "tcarrio"; desktop = "cosmic"; };
        "tcarrio@t510" = libx.mkHome { hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@vm" = libx.mkHome { hostname = "vm"; username = "tcarrio"; desktop = "gnome"; };
        "tcarrio@chasm" = libx.mkHome { hostname = "chasm"; username = "tcarrio"; desktop = "i3"; };
      };

      # Support for nix-darwin workstations
      # - darwin-rebuild build --flake .#sktc0
      darwinConfigurations = {
        "sktc0" = libx.mkDarwin { username = "tcarrio"; hostname = "sktc0"; stateVersion = 4; determinate = true; };
        "sktc2" = libx.mkDarwin { username = "tcarrio"; hostname = "sktc2"; stateVersion = 4; determinate = true; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."sktc2".pkgs;

      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-nuc = libx.mkHost { systemType = "iso"; hostname = "iso-nuc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; determinate = false; };
        iso-console = libx.mkHost { systemType = "iso"; hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; determinate = false; };
        iso-desktop = libx.mkHost { systemType = "iso"; hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "gnome"; determinate = false; };
        iso-recovery-console = libx.mkHost { systemType = "iso"; hostname = "iso-recovery"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; determinate = false; };
        iso-recovery-desktop = libx.mkHost { systemType = "iso"; hostname = "iso-recovery"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; desktop = "cinnamon"; determinate = false; };
        netboot-console = libx.mkHost { systemType = "iso"; hostname = "netboot-iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/netboot/netboot-minimal.nix"; determinate = false; };

        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        glass = libx.mkHost { systemType = "workstation"; hostname = "glass"; username = "tcarrio"; desktop = "kde6"; };
        obsidian = libx.mkHost { systemType = "workstation"; hostname = "obsidian"; username = "tcarrio"; desktop = "gnome"; };
        void = libx.mkHost { systemType = "workstation"; hostname = "void"; username = "tcarrio"; desktop = "cosmic"; };
        t510 = libx.mkHost { systemType = "workstation"; hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };
        t510-headless = libx.mkHost { systemType = "workstation"; hostname = "t510-headless"; username = "tcarrio"; };
        chasm = libx.mkHost { systemType = "workstation"; hostname = "chasm"; username = "tcarrio"; desktop = "i3"; };

        # Servers
        # Can be executed locally:
        #  - sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg
        #
        # Or remotely:
        #  - nixos-rebuild switch --fast --flake .#${HOST} \
        #      --target-host ${USERNAME}@${HOST}.${TAILNET} \
        #      --build-host  ${USERNAME}@${HOST}.${TAILNET}
        nuc-init = libx.mkHost { systemType = "server"; hostname = "nuc-init"; username = "nixos"; };
        nuc0 = libx.mkHost { systemType = "server"; hostname = "nuc0"; username = "archon"; };
        nuc1 = libx.mkHost { systemType = "server"; hostname = "nuc1"; username = "archon"; };
        nuc2 = libx.mkHost { systemType = "server"; hostname = "nuc2"; username = "archon"; };
        nuc3 = libx.mkHost { systemType = "server"; hostname = "nuc3"; username = "archon"; };
        nuc4 = libx.mkHost { systemType = "server"; hostname = "nuc4"; username = "archon"; };
        nuc5 = libx.mkHost { systemType = "server"; hostname = "nuc5"; username = "archon"; };
        nuc6 = libx.mkHost { systemType = "server"; hostname = "nuc6"; username = "archon"; };
        nuc7 = libx.mkHost { systemType = "server"; hostname = "nuc7"; username = "archon"; };
        nuc8 = libx.mkHost { systemType = "server"; hostname = "nuc8"; username = "archon"; };
        nuc9 = libx.mkHost { systemType = "server"; hostname = "nuc9"; username = "archon"; };

        orca = libx.mkHost { systemType = "server"; hostname = "orca"; username = "archon"; };
        shiroi = libx.mkHost { systemType = "server"; hostname = "shiroi"; username = "archon"; };

        "nix-proxy-droplet" = libx.mkHost { systemType = "server"; hostname = "nix-proxy-droplet"; username = "archon"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = (libx.forAllDarwin (system:
        let
          mkFlakeShell = mkSystemFlakeShell system;
        in
        rec {
          default = mkFlakeShell ({ pkgs, darwinNixPkgs, bun2NixPkg, ... }: {
            packages = with pkgs; [
              home-manager
              darwinNixPkgs.darwin-rebuild
              git
              unstable.bun
              unstable.nixd
              bun2NixPkg
              self.packages.${system}.gh-composer-auth
              # TODO: Fix gqurl package
              # self.packages.${system}.gqurl
              # TODO: Re-enable support for mac-launcher with system-contextual pkgs
              # self.packages.${system}.mac-launcher
              self.packages.${system}.nixvim
            ];
          });
          dev = default;
        } // devshells.devShells.${system}
      )) //
      (libx.forAllLinux (system:
        let
          mkFlakeShell = mkSystemFlakeShell system;
        in
        rec {
          installers = mkFlakeShell ({ pkgs, ... }: {
            packages = with pkgs; [
              nix
              home-manager
              git
              self.packages.${system}.gh-composer-auth
              # TODO: Fix gqurl package
              # self.packages.${system}.gqurl
              self.packages.${system}.nixvim
            ];
          });
          default = dev;
          dev = mkFlakeShell devShellFactory;
        } // devshells.devShells.${system}
      ));

      # nix fmt
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      # Custom packages and modifications, exported as overlays
      inherit overlays;

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages =
        let
          mkNuc = user: name: libx.mkGeneratorImage { systemType = "server"; hostname = name; username = user; };
        in
        libx.forAllSystems
          (system:
            let
              pkgs = mkPkgsForSystemFromInput system nixpkgs;
              mkStandardBun = libx.mkBunDerivation inputs.bun2nix.packages.${system}.default;
              uv2nixLib = {
                inherit uv2nix pyproject-nix pyproject-build-systems;
                python = pkgs.python311;
              };
              localPackages = import ./pkgs { inherit pkgs mkStandardBun nixvim uv2nixLib; };
            in
            (lib.optionalAttrs (system == "x86_64-linux") {
              # TODO: Linode image is still too large: reduction with `qemu-img resize --shrink ./nixos.img 5.5G` didn't error out but image will not boot
              # linode-base-image = libx.mkGeneratorImage { systemType = "server"; hostname = "linode-base-image"; username = "archon"; format = "linode"; diskSize = 5120; };
              digital-ocean-base-image = libx.mkGeneratorImage { systemType = "server"; hostname = "generic-base-image"; username = "archon"; format = "do"; };

              ## NUC server configurations
              system-image-nuc0 = mkNuc "archon" "nuc0";
              system-image-nuc1 = mkNuc "archon" "nuc1";
              system-image-nuc2 = mkNuc "archon" "nuc2";
              system-image-nuc3 = mkNuc "archon" "nuc3";
              system-image-nuc4 = mkNuc "archon" "nuc4";
              system-image-nuc5 = mkNuc "archon" "nuc5";
              system-image-nuc6 = mkNuc "archon" "nuc6";
              system-image-nuc7 = mkNuc "archon" "nuc7";
              system-image-nuc8 = mkNuc "archon" "nuc8";
              system-image-nuc9 = mkNuc "archon" "nuc9";

              # Installer utility
              install-system = pkgs.writeShellApplication {
                name = "install-system";
                text = builtins.readFile ./scripts/shell/install.sh;
                runtimeInputs = [
                  inputs.disko.packages.${system}.disko
                ] ++ (with pkgs; [
                  nixos-install
                  git
                  gum
                ]);
              };

              # TODO: Revise init image strategy
              # nuc-init = mkNuc "nixos"  "nuc-init";
            }) // localPackages
          );
    };
}
