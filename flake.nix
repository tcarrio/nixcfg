{
  description = "tcarrio's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-trunk.url = "github:nixos/nixpkgs/master";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    devshells.url = "github:tcarrio/devshells";
    devshells.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Android support with nix-on-droid
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-23.05";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin support with nix-darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Homebrew support
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs-unstable";

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    # IDE starter config for Neovim
    neovim-kickstart.url = "github:tcarrio/kickstart.nvim";
    neovim-kickstart.flake = false;
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , vscode-server
    , devshells
    , nix-on-droid
    , neovim-kickstart
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib { inherit self inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/0xc/nix-config
      # nix build .#homeConfigurations."tcarrio@ripper".activationPackage
      homeConfigurations = {
        # .iso images
        "nuc@iso-nuc" = libx.mkHome { hostname = "iso-nuc"; username = "nixos"; };
        "tk1@iso-tk1" = libx.mkHome { hostname = "iso-tk1"; username = "nixos"; };

        # Workstations
        "tcarrio@sktc0" = libx.mkHome { hostname = "sktc0"; username = "tcarrio"; platform = "aarch64-darwin"; };
        "tcarrio@glass" = libx.mkHome { hostname = "glass"; username = "tcarrio"; desktop = "i3"; };
        "tcarrio@kuroi" = libx.mkHome { hostname = "kuroi"; username = "tcarrio"; desktop = "gnome"; };
        "tcarrio@t510" = libx.mkHome { hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@vm" = libx.mkHome { hostname = "vm"; username = "tcarrio"; desktop = "gnome"; };

        # Servers
        "tcarrio@brix" = libx.mkHome { hostname = "brix"; username = "tcarrio"; };
        "tcarrio@skull" = libx.mkHome { hostname = "skull"; username = "tcarrio"; };
        "tcarrio@vm-mini" = libx.mkHome { hostname = "vm-mini"; username = "tcarrio"; };
      };

      # Support for nix-darwin workstations
      # - darwin-rebuild build --flake .#sktc0
      darwinConfigurations = {
        "sktc0" = libx.mkDarwin { username = "tcarrio"; hostname = "sktc0"; stateVersion = 4; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."sktc0".pkgs;

      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-nuc = libx.mkHost { systemType = "iso"; hostname = "iso-nuc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-tk1 = libx.mkHost { systemType = "iso"; hostname = "iso-tk1"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-console = libx.mkHost { systemType = "iso"; hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { systemType = "iso"; hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };

        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/0xc/nix-config
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        glass = libx.mkHost { systemType = "workstation"; hostname = "glass"; username = "tcarrio"; desktop = "i3"; };
        kuroi = libx.mkHost { systemType = "workstation"; hostname = "kuroi"; username = "tcarrio"; desktop = "gnome"; };
        t510 = libx.mkHost { systemType = "workstation"; hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };

        # Servers
        # Can be executed locally:
        #  - sudo nixos-rebuild switch --flake $HOME/0xc/nix-config
        #
        # Or remotely:
        #  - nixos-rebuild switch --fast --flake .#${HOST} \
        #      --target-host ${USERNAME}@${HOST}.${TAILNET} \
        #      --build-host  ${USERNAME}@${HOST}.${TAILNET}
        nuc0 = libx.mkHost { systemType = "server"; hostname = "nuc0"; username = "tcarrio"; };
        nuc1 = libx.mkHost { systemType = "server"; hostname = "nuc1"; username = "tcarrio"; };
        nuc2 = libx.mkHost { systemType = "server"; hostname = "nuc2"; username = "tcarrio"; };
        nuc3 = libx.mkHost { systemType = "server"; hostname = "nuc3"; username = "tcarrio"; };
        nuc4 = libx.mkHost { systemType = "server"; hostname = "nuc4"; username = "tcarrio"; };
        nuc5 = libx.mkHost { systemType = "server"; hostname = "nuc5"; username = "tcarrio"; };
        nuc6 = libx.mkHost { systemType = "server"; hostname = "nuc6"; username = "tcarrio"; };
        nuc7 = libx.mkHost { systemType = "server"; hostname = "nuc7"; username = "tcarrio"; };
        nuc8 = libx.mkHost { systemType = "server"; hostname = "nuc8"; username = "tcarrio"; };
        nuc9 = libx.mkHost { systemType = "server"; hostname = "nuc9"; username = "tcarrio"; };
      };

      nixOnDroidConfigurations = {
        pixel6a-legacy = nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [ ./android/pixel6a/config.nix ];
        };
        pixel6a = libx.mkDroid { hostname = "pixel6a"; username = "tcarrio"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      inherit (devshells) devShells; # libx.forAllSystems (system:
      # let pkgs = nixpkgs.legacyPackages.${system};
      # in import ./shell.nix { inherit pkgs; }
      # );

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
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
