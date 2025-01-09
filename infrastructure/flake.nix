{
  description = "tcarrio/nixcfg/infrastructure";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nixcfg.url = "git+file:../";

  outputs = { self, nixpkgs, flake-utils, nixcfg }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
                git
                nodejs_22
                nodePackages.wrangler
                yarn
                biome

                # infrastructure and automation
                opentofu
                go-task

                # secrets management
                sops
                gnupg
                age
            ];

            env = with pkgs; {
              PROJECT_NAME = "tcarrio/nixcfg/infrastructure";
            };

            shellHook = ''
                echo $ Started devshell for $PROJECT_NAME
                echo
            '';
          };
        };
      }
    );
}