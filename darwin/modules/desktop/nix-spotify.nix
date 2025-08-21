{ config, pkgs, lib, ... }:
let
  cfg = config.oxc.spotify;
in {
  options.oxc.spotify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Spotify application";
    };
    source = lib.mkOption {
      type = lib.types.enum ["nix" "homebrew"];
      default = "homebrew";
      description = "The source of the application: Nix or Homebrew";
    };
  };

  config = lib.mkIf cfg.enable (
    {}
    // lib.mkIf (cfg.source == "nix") {
      environment.systemPackages = [ pkgs.spotify ];

      nixpkgs.config.allowUnfree = lib.mkForce true;
    }
    // lib.mkIf (cfg.source == "homebrew") {
      homebrew.casks = ["spotify"];
    }
  );
}
