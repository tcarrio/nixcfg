{ pkgs, config, ... }:
{
### START SECTION: HOME ASSISTANT ###
  # Prefer to use nixpkgs-unstable's module definition
  nixpkgs.overlays = [(self: super: {
    inherit (pkgs.unstable) home-assistant;
  })];
  # additional import from nixpkgs-unstable above replaces the following
  # disabledModules = ["services/home-automation/home-assistant.nix"];
  
  # NixOS Home Assistant service
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      logger.default = "debug";
      # Connect to local PostgreSQL service
      # recorder.db_url = "postgresql://@/hass";

      # Declarative automations
      "automation manual" = [
        ### EXAMPLES
        # {
        #   alias = "living room plug off";
        #   trigger = {
        #     platform = "time";
        #     at = "22:00";
        #   };
        #   action = {
        #     type = "turn_off";
        #     device_id = "someID"; #Inspect yaml of automation created in UI
        #     entity_id = "switch.living_room_plug";
        #     domain = "switch";
        #   };
        # }
      ];
      # Automations configured in the UI
      "automation ui" = "!include automations.yaml";
    };
    # Ensure support for PostgreSQL driver
    # package = (pkgs.home-assistant.override {
    #   extraPackages = py: with py; [ psycopg2 ];
    # }).overrideAttrs (oldAttrs: {
    #   doInstallCheck = false;
    # });
  };
  # Ensure existence of automations.yaml file
  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
  ];
  # Enable and set up Home Assistant on PostgreSQL
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "hass" ];
  #   ensureUsers = [{
  #     name = "hass";
  #     ensureDBOwnership = true;
  #   }];
  # };
  # Add-ons that depend on SSL 1.x may require the following insecure package be permitted
  # nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];
  # Enable Caddy reverse proxy, listening for Tailnet host requests
  services.home-assistant.config.http = {
    server_host = "127.0.0.1";
    trusted_proxies = [ "127.0.0.1" ];
    use_x_forwarded_for = true;
  };
  services.caddy = {
    enable = false;
    virtualHosts."orca.griffin-cobra.ts.net".extraConfig = ''
      reverse_proxy 127.0.0.1:8123
    '';
  };
  networking.firewall.allowedTCPPorts = [ 443 ];
  # Allow Caddy to generate certificates
  services.tailscale.permitCertUid = "caddy";
  # Ensure the Caddy server starts after Tailscale authentication
  systemd.services.caddy.after = ["tailscaled-autoconnect.service"];
  ### END SECTION: HOME ASSISTANT ###
}