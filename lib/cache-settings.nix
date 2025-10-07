{ username, isDeterminateNix ? false, adminGroup ? null, ... }:
  let
    lib = {
      optional = predicate: value: if predicate then [value] else [];
      optionals = predicate: list: if predicate then list else [];
    };
    nixSettings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";

      # Allows users/groups to utilize flake-specific settings
      trusted-users = [
        "root"
        username
      ] ++ (lib.optional (adminGroup != null) adminGroup);

      # Configure and verify binary cache stores
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nix-darwin.cachix.org"
        "https://cache.garnix.io"
      ] ++ lib.optionals isDeterminateNix [
        "https://install.determinate.systems"
        "https://cache.flakehub.com"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-darwin.cachix.org-1:G6r3FhSkSwRCZz2d8VdAibhqhqxQYBQsY3mW6qLo5pA="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ] ++ lib.optionals isDeterminateNix [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "install.determinate.systems-1:EtHx9fW5pgsIvdN9RNeSwgiOc1ZESu8rfNOWhEuMhBI="
      ];

      extra-trusted-substituters = [
        "https://cache.nixos.org"
      ];
    };
  in if isDeterminateNix then {
    # Custom settings written to /etc/nix/nix.custom.conf
    nix.enable = false;
    determinate-nix.customSettings = nixSettings;
  } else {
    # Standard Nix configuration in module
    nix = {
      enable = true;
      # TODO: Re-enable pkgs as parameter to module
      # package = pkgs.nix;
      settings = nixSettings;
    };
  }
