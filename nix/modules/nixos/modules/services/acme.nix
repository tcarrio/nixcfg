{ lib, config, ... }: {
  options.oxc.services.acme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for ACME LetsEncrypt protocol";
    };
  };

  config = lib.mkIf config.oxc.services.acme.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = lib.mkDefault "tom@carrio.dev";
    };
  };
}
