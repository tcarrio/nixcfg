{
  description = "Nix shell for GPU tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          clinfo # Terminal OpenCL info
          libva-utils # Terminal VAAPI info
          python310Packages.gpustat # Terminal GPU info
          vdpauinfo # Terminal VDPAU info
        ];
      };
    });
}
