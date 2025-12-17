{
  description = "A Nix generated Docker image for Fly.io with Tailscale networking enabled.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, ... }:
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
          in
          {
            httpServer = port: htmlContent: pkgs.stdenv.mkDerivation {
              name = "simple-http-server";
              version = "0.1.0";

              # No source to build
              phases = [ "installPhase" ];

              # Install our HTML content and start script
              installPhase = ''
                mkdir -p $out/bin $out/html

                # Write the HTML content
                echo '${htmlContent}' > $out/html/index.html

                # Create a wrapper script that executes the server
                cat > $out/bin/run-server <<EOF
                #!${pkgs.bash}/bin/bash
                cd $out/html
                exec ${pkgs.python3}/bin/python -m http.server ${toString port}
                EOF

                chmod +x $out/bin/run-server
              '';

              meta = {
                description = "A simple HTTP server exposing HTML content on port ${toString port}";
                license = pkgs.lib.licenses.mit;
              };
            };

            # Create a specific instance of our server with defined content
            exampleServer = httpServer 8080 ''
              <!DOCTYPE html>
              <html>
                <head>
                  <title>My Nix-Served Website</title>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                </head>
                <body>
                  <h1>Hello from Nix!</h1>
                  <p>This content is being served from a simple HTTP server packaged with Nix.</p>
                </body>
              </html>
            '';


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
