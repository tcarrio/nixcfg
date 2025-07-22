{
  description = "tcarrio's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-trunk.url = "github:nixos/nixpkgs/master";

    # Common Nix flake structure module
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
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
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-generators for sdcard and raw disk install generation
    nixos-generators.url = "github:tcarrio/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Zen Browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Bun packaging
    bun2nix.url = "github:baileyluTCD/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";

    # Omarchy repository for configs and scripts
    omarchy.url = "github:basecamp/omarchy";
    omarchy.flake = false;

    # Nixvim for neovim configuration
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = inputs:
    inputs.blueprint {
      inherit inputs;
      prefix = "nix/";
      nixpkgs.config.allowUnfree = true;
    };
}