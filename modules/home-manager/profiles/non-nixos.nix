# Non-NixOS workstation profile. Provides reasonable defaults with assumptions around
# the non-existence of system rebuild commands like nixos-rebuild or nix-darwin.
{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.profiles.non-nixos;
in
{
  options.oxc.profiles.non-nixos = {
    enable = lib.mkEnableOption "the oxc non-nixos profile (assumes standalone-HM Linux without conflicting with system-manager defaults)";

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/0xc/nixcfg";
      description = "Flake path used by the rebuild-home alias";
    };

    flakeTarget = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Flake target (<user>@<host>) for the rebuild-home alias; typically
        the consuming homeConfigurations entry name. The rebuild aliases
        are only generated when this is set.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    oxc.profiles.console.enable = lib.mkDefault true;

    # Session-wide nix profile visibility
    oxc.session.nix-profile.enable = lib.mkDefault true;

    # Home-manager-only life: no system configuration to rebuild. The
    # rebuild-home alias is generated only with an explicit flakeTarget.
    programs.fish.shellAliases = lib.mkIf (cfg.flakeTarget != null) {
      rebuild-home = "home-manager switch -b backup --flake ${cfg.flakePath}#${cfg.flakeTarget}";
      rebuild-all = "nix-gc && rebuild-home";
      nix-gc = "nix-collect-garbage --delete-older-than 28d";
      # rebuild-host not set: No system layer on this host — see docs/non-nixos-linux.md
    };
  };
}
