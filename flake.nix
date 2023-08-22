{
  description = "Wimpy's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , vscode-server
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix build .#homeConfigurations."tom@ripper".activationPackage
      homeConfigurations = {
        # .iso images
        "nuc@iso-nuc" = libx.mkHome { hostname = "iso-nuc"; username = "nixos"; };
        "tk1@iso-tk1" = libx.mkHome { hostname = "iso-tk1"; username = "nixos"; };

        # Workstations
        "tom@designare" = libx.mkHome { hostname = "designare"; username = "tom"; desktop = "pantheon"; };
        "tom@glass" = libx.mkHome { hostname = "glass"; username = "tom"; desktop = "pantheon"; };
        "tom@micropc" = libx.mkHome { hostname = "micropc"; username = "tom"; desktop = "pantheon"; };
        "tom@p1" = libx.mkHome { hostname = "p1"; username = "tom"; desktop = "pantheon"; };
        "tom@p2-max" = libx.mkHome { hostname = "p2-max"; username = "tom"; desktop = "pantheon"; };
        "tom@ripper" = libx.mkHome { hostname = "ripper"; username = "tom"; desktop = "pantheon"; };
        "tom@t510" = libx.mkHome { hostname = "t510"; username = "tom"; desktop = "pantheon"; };
        "tom@trooper" = libx.mkHome { hostname = "trooper"; username = "tom"; desktop = "pantheon"; };
        "tom@vm" = libx.mkHome { hostname = "vm"; username = "tom"; desktop = "pantheon"; };
        "tom@win2" = libx.mkHome { hostname = "win2"; username = "tom"; desktop = "pantheon"; };
        "tom@win-max" = libx.mkHome { hostname = "win-max"; username = "tom"; desktop = "pantheon"; };
        "tom@zed" = libx.mkHome { hostname = "zed"; username = "tom"; desktop = "pantheon"; };

        # Servers
        "tom@brix" = libx.mkHome { hostname = "brix"; username = "tom"; };
        "tom@skull" = libx.mkHome { hostname = "skull"; username = "tom"; };
        "tom@vm-mini" = libx.mkHome { hostname = "vm-mini"; username = "tom"; };
      };

      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-nuc = libx.mkHost { type = "iso"; hostname = "iso-nuc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-tk1 = libx.mkHost { type = "iso"; hostname = "iso-tk1"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-console = libx.mkHost { type = "iso"; hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { type = "iso"; hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-micropc = libx.mkHost { type = "iso"; hostname = "micropc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-win2 = libx.mkHost { type = "iso"; hostname = "win2"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-win-max = libx.mkHost { type = "iso"; hostname = "iso-win-max"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        designare = libx.mkHost { type = "workstation"; hostname = "designare"; username = "tom"; desktop = "pantheon"; };
        glass = libx.mkHost { type = "workstation"; hostname = "glass"; username = "tom"; desktop = "sway"; };
        p1 = libx.mkHost { type = "workstation"; hostname = "p1"; username = "tom"; desktop = "pantheon"; };
        p2-max = libx.mkHost { type = "workstation"; hostname = "p2-max"; username = "tom"; desktop = "pantheon"; };
        micropc = libx.mkHost { type = "workstation"; hostname = "micropc"; username = "tom"; desktop = "pantheon"; };
        ripper = libx.mkHost { type = "workstation"; hostname = "ripper"; username = "tom"; desktop = "pantheon"; };
        t510 = libx.mkHost { type = "workstation"; hostname = "t510"; username = "tom"; desktop = "pantheon"; };
        trooper = libx.mkHost { type = "workstation"; hostname = "trooper"; username = "tom"; desktop = "pantheon"; };
        vm = libx.mkHost { type = "workstation"; hostname = "vm"; username = "tom"; desktop = "pantheon"; };
        win2 = libx.mkHost { type = "workstation"; hostname = "win2"; username = "tom"; desktop = "pantheon"; };
        win-max = libx.mkHost { type = "workstation"; hostname = "win-max"; username = "tom"; desktop = "pantheon"; };
        zed = libx.mkHost { type = "workstation"; hostname = "zed"; username = "tom"; desktop = "pantheon"; };

        # Servers
        # Can be executed locally:
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #
        # Or remotely:
        #  - nixos-rebuild switch --fast --flake .#${HOST} \
        #      --target-host ${USERNAME}@${HOST}.${TAILNET} \
        #      --build-host ${USERNAME}@${HOST}.${TAILNET}
        brix = libx.mkHost { type = "server"; hostname = "brix"; username = "tom"; };
        skull = libx.mkHost { type = "server"; hostname = "skull"; username = "tom"; };
        vm-mini = libx.mkHost { type = "server"; hostname = "vm-mini"; username = "tom"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

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
