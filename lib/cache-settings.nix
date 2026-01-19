{ username, isDarwin ? false, isDeterminateNix ? false, adminGroup ? null, desktop ? null, ... }:
let
  isLinuxGaming = !isDarwin && desktop != null;

  lib = {
    optional = predicate: value: if predicate then [ value ] else [ ];
    optionals = predicate: list: if predicate then list else [ ];
  };

  nixSettings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes pipe-operators";

    # Allows users/groups to utilize flake-specific settings
    trusted-users = [
      "root"
      username
    ] ++ (lib.optional (adminGroup != null) adminGroup);

    # Configure and verify binary cache stores
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ]
    ++ (lib.optionals isDarwin [
      "https://nix-darwin.cachix.org"
    ])
    ++ (lib.optionals isDeterminateNix [
      "https://install.determinate.systems"
      "https://cache.flakehub.com"
    ])
    ++ (lib.optionals isLinuxGaming [
      "https://nix-citizen.cachix.org"
      "https://nix-gaming.cachix.org"
    ]);

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ]
    ++ (lib.optionals isDarwin [
      "nix-darwin.cachix.org-1:G6r3FhSkSwRCZz2d8VdAibhqhqxQYBQsY3mW6qLo5pA="
    ])
    ++ (lib.optionals isDeterminateNix [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "install.determinate.systems-1:EtHx9fW5pgsIvdN9RNeSwgiOc1ZESu8rfNOWhEuMhBI="
    ])
    ++ (lib.optionals isLinuxGaming [
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ]);

    extra-trusted-substituters = [
      "https://cache.nixos.org"
    ];
  };

  determinateNixBaseSettings = {
    # NOTE: For Determinate Nix systems, the custom Nix settings will be
    # written to /etc/nix/nix.custom.conf
    nix.enable = false;
  };

  baseNixSettings = {
    # Standard Nix configuration in module
    nix = {
      enable = true;
      # TODO: Re-enable pkgs as parameter to module
      # package = pkgs.nix;
      settings = nixSettings;
    };
  };

  baseSettings =
    if isDeterminateNix
    then determinateNixBaseSettings
    else baseNixSettings;

  darwinDeterminateNixSettings = baseSettings // {
    # On Darwin, the nix.settings MUST NOT be set when nix.enable is false,
    # or nix-darwin will be UNABLE to build 💥
    # You instead set the settings you want for Nix here, in the same structure:
    determinate-nix.customSettings = nixSettings;
  };
  nixosDeterminateNixSettings = baseSettings // {
    # HOWEVER on NixOS, the nix.settings MUST be set when nix.enable is false
    # because the system access `environment.etc."nix/nix.conf".source` is
    # accessed and without being set caused the build to fail 🥵
    nix.settings = nixSettings;
  };

  determinateSettings =
    if isDarwin
    then darwinDeterminateNixSettings
    else nixosDeterminateNixSettings;

  finalSettings =
    if isDeterminateNix
    then determinateSettings
    else baseSettings;
in
finalSettings
