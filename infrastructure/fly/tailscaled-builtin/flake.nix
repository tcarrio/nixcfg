{
  description = "A Nix generated Docker image for Fly.io with Tailscale networking enabled.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, ... }: let
    pname = "tailscaled-builtin";
    owner = "tcarrio";
    version = "0.1.0";
  in
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages =
          let
            selfPackages = self.outputs.packages.${system};
            entrypoint = pkgs.writeScript "docker-entrypoint.sh" ''
              #!${pkgs.stdenv.shell}

              if [ -z "$TAILSCALE_AUTHKEY" ]; then
                echo 'Missing Tailscale authkey for automatic connection! Exiting...
                exit 1
              fi

              ${pkgs.tailscale}/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
              ${pkgs.tailscale}/tailscale up --auth-key=$TAILSCALE_AUTHKEY --hostname=fly-app

              exec ${selfPackages.default}/bin/hello
            '';
            imageArch =
              if pkgs.lib.strings.hasPrefix "x86_64" system
              then "amd64"
              else "arm64";
          in {
            default = pkgs.hello;

            docker = pkgs.dockerTools.streamLayeredImage {
              name = "docker.io/tcarrio/tailscaled-builtin";
              tag = "latest";
              # Use commit date to ensure image creation date is reproducible.
              created = builtins.substring 0 8 self.lastModifiedDate;
              architecture = imageArch;
              config = {
                Entrypoint = [ entrypoint ];
                Env = [
                  "TAILSCALE_AUTHKEY="
                ];
              };
            };
          };

        # Development shell
        # nix develop
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
            ];
            packages = [
              hello
            ];
          };
        };
      }
  );
}