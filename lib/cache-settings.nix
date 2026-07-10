{
  username,
  isDarwin ? false,
  isDeterminateNix ? false,
  adminGroup ? null,
  ...
}:
let
  lib = {
    optional = predicate: value: if predicate then [ value ] else [ ];
    optionals = predicate: list: if predicate then list else [ ];
  };

  nixSettings = {
    # Override default setting of 300 second (5 MINUTE) timeout to 5 SECOND timeout
    connect-timeout = 5;
    log-lines = 50;
    min-free = 256000000; # 256MB
    max-free = 1000000000; # 1GB

    # Allow building from source
    fallback = true;
    # Allow dirty VCS tress (Git/Mercurial)
    warn-dirty = false;
    # Replace identical files with hard links
    auto-optimise-store = true;

    # This ensures that packages needed for building other packages are kept
    # in the store. If you’re going to be building packages locally, this is
    # very useful to prevent having to redownload things a lot.
    keep-outputs = true;

    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes pipe-operators";

    # Allows users/groups to utilize flake-specific settings
    trusted-users = [
      "root"
      username
    ]
    ++ (lib.optional (adminGroup != null) adminGroup);

    # Configure and verify binary cache stores
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ]
    ++ (lib.optionals isDarwin [
      "https://nix-darwin.cachix.org"
    ])
    ++ (lib.optionals isDeterminateNix [
      "https://install.determinate.systems"
      "https://cache.flakehub.com"
    ]);

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ]
    ++ (lib.optionals isDarwin [
      "nix-darwin.cachix.org-1:G6r3FhSkSwRCZz2d8VdAibhqhqxQYBQsY3mW6qLo5pA="
    ])
    ++ (lib.optionals isDeterminateNix [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "install.determinate.systems-1:EtHx9fW5pgsIvdN9RNeSwgiOc1ZESu8rfNOWhEuMhBI="
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

  baseSettings = if isDeterminateNix then determinateNixBaseSettings else baseNixSettings;

  darwinDeterminateNixSettings = baseSettings // {
    # On Darwin, the nix.settings MUST NOT be set when nix.enable is false,
    # or nix-darwin will be UNABLE to build 💥
    # You instead set the settings you want for Nix here, in the same structure:
    determinateNix.customSettings = nixSettings // {
      # Evaluate across all cores
      eval-cores = 0;
    };
  };
  nixosDeterminateNixSettings = baseSettings // {
    # HOWEVER on NixOS, the nix.settings MUST be set when nix.enable is false
    # because the system access `environment.etc."nix/nix.conf".source` is
    # accessed and without being set caused the build to fail 🥵
    nix.settings = nixSettings;
  };

  determinateSettings =
    if isDarwin then darwinDeterminateNixSettings else nixosDeterminateNixSettings;

  finalSettings = if isDeterminateNix then determinateSettings else baseSettings;
in
finalSettings
