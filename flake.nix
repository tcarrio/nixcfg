{
  description = "tcarrio's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-trunk.url = "github:nixos/nixpkgs/master";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
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
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-generators for sdcard and raw disk install generation
    nixos-generators.url = "github:tcarrio/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Zen Browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # IaC (WIP)
    # inputs.terranix.url = "github:terranix/terranix";
    # inputs.terranix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , devshells
    , nix-darwin
    , ...
    } @ inputs:
    let
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.05";

      inherit (self) outputs;
      libx = import ./lib { inherit self inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/0xc/nixcfg
      # nix build .#homeConfigurations."tcarrio@ripper".activationPackage
      homeConfigurations = {
        # .iso images
        "nuc@iso-nuc" = libx.mkHome { hostname = "iso-nuc"; username = "nixos"; };
        
        # TODO: Nvidia TK1 updates and installer
        # "tk1@iso-tk1" = libx.mkHome { hostname = "iso-tk1"; username = "nixos"; };

        # Workstations
        "tcarrio@sktc0" = libx.mkHome { hostname = "sktc0"; username = "tcarrio"; platform = "aarch64-darwin"; };
        "tcarrio@glass" = libx.mkHome { hostname = "glass"; username = "tcarrio"; desktop = "kde6"; };
        # TODO: Update/reuse for new laptop or remove entirely
        # "tcarrio@kuroi" = libx.mkHome { hostname = "kuroi"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@t510" = libx.mkHome { hostname = "t510"; username = "tcarrio"; desktop = "i3"; };
        "tcarrio@vm" = libx.mkHome { hostname = "vm"; username = "tcarrio"; desktop = "gnome"; };
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
        # TODO: Nvidia TK1 updates and installer
        # iso-tk1 = libx.mkHost { systemType = "iso"; hostname = "iso-tk1"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "gnome"; };
        iso-console = libx.mkHost { systemType = "iso"; hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { systemType = "iso"; hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "gnome"; };

        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/0xc/nixcfg
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        glass = libx.mkHost { systemType = "workstation"; hostname = "glass"; username = "tcarrio"; desktop = "kde6"; };
        # TODO: Update/reuse for new laptop or remove entirely
        # kuroi = libx.mkHost { systemType = "workstation"; hostname = "kuroi"; username = "tcarrio"; desktop = "pantheon"; };
        t510 = libx.mkHost { systemType = "workstation"; hostname = "t510"; username = "tcarrio"; desktop = "i3"; };
        t510-headless = libx.mkHost { systemType = "workstation"; hostname = "t510-headless"; username = "tcarrio"; };

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

        shiroi = libx.mkHost { systemType = "server"; hostname = "shiroi"; username = "archon"; };

        "dotest.carrio.dev" = libx.mkHost { systemType = "server"; hostname = "dotest.carrio.dev"; username = "archon"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = (libx.forAllDarwin (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            darwinNixPkgs = nix-darwin.packages.${system};
          in
          {
            default = pkgs.mkShell {
              NIX_CONFIG = "experimental-features = nix-command flakes";
              packages = with pkgs; [ home-manager darwinNixPkgs.darwin-rebuild git ];
            };
          } // devshells.devShells.${system}
        )) //
        (libx.forAllLinux (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.mkShell {
              NIX_CONFIG = "experimental-features = nix-command flakes";
              packages = with pkgs; [ nix home-manager git ];
            };
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
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages =
        let
          mkNuc = user: name: libx.mkGeneratorImage { systemType = "server"; hostname = name; username = user; };
        in
        (libx.forAllSystems
          (system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            (import ./pkgs { inherit pkgs; })
            //
            {
              # nuc-init = mkNuc "nixos"  "nuc-init";
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
            }
          )) // {
          x86_64-linux = {
            # TODO: image is still too large: reduction with `qemu-img resize --shrink ./nixos.img 5.5G` didn't error out but image will not boot
            # linode-base-image = libx.mkGeneratorImage { systemType = "server"; hostname = "generic-base-image"; username = "archon"; format = "linode"; diskSize = 5120; };

            digital-ocean-base-image = libx.mkGeneratorImage { systemType = "server"; hostname = "generic-base-image"; username = "archon"; format = "do"; };
          };
        };
      # And custom nixos-generators definitions
      # TODO: forAllSystems
      #   tk1 = libx.mkSdImage { hostname = "tk1"; username = "root"; systemType = "server"; };
    };
}
