{
  lib,
  ...
}:
{
  # Host metadata as module options (not specialArgs) so external
  # consumers can build hosts from this flake's modules without
  # adopting its host-factory helpers. Host trees set these; the
  # host-base module (modules/nixos/host-base) reads them.
  options.oxc.host = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname; may be an FQDN (host.domain) — domain is derived.";
    };

    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Primary user; selects the nixos/mixins/users/<name> profile when non-null.";
    };

    systemType = lib.mkOption {
      type = lib.types.enum [
        "server"
        "workstation"
        "iso"
      ];
      description = "Host class; informational for consumers, drives nothing internal.";
    };

    desktop = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Desktop environment name; enables the desktop mixin tree when non-null.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "24.05";
      description = "NixOS system.stateVersion.";
    };
  };
}
