{ lib, config, pkgs, ... }: {
  options.oxc.desktop.bitwarden = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Bitwarden password manager";
    };
    # TODO: Support for browser integrations?
  };

  config = lib.mkIf config.oxc.desktop.bitwarden.enable {
    environment.systemPackages = with pkgs; [
      bitwarden
    ];
  };
}
