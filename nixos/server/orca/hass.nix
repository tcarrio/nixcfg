{ pkgs, config, ... }:
let
  localhost = "127.0.0.1";

  Z2M_PORT = config.services.zigbee2mqtt.settings.frontend.port;
  Z2M_PORT_STR = toString Z2M_PORT;
  HASS_PORT = config.services.home-assistant.port;
  HASS_PORT_STR = toString HASS_PORT;
in
{
  ### START SECTION: HOME ASSISTANT ###
  # Prefer to use nixpkgs-unstable's module definition
  nixpkgs.overlays = [
    (_self: _super: {
      inherit (pkgs.unstable) home-assistant;
    })
  ];
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

      # Preferred components
      "cast"
      "hue"
      "tuya"
      "govee_light_local" # https://app-h5.govee.com/user-manual/wlan-guide
      "shelly"
      "litterrobot"
      "generic" # camera support


      # HomeKit support
      "homekit_controller"

      # Voice assistance
      "piper"
      "whisper"
      "wyoming"
      # "llama_cpp" # NOT FOUND?

      # Cloud integrations
      "google"

      # The ZBT-2 Zigbee radio is driven by Zigbee2MQTT (see below), not ZHA;
      # HA consumes it over MQTT via the `mqtt` config below. No serial-using
      # component is listed here, so the home-assistant service does not need
      # (and does not get) the `dialout` group.


    ];
    config = {
      homeassistant = {
        # https://www.home-assistant.io/docs/configuration/basic/
        name = "Home";
        latitude = 42.016035;
        longitude = -83.9236092;
        unit_system = "us_customary";
        temperature_unit = "F";
        time_zone = "America/Detroit";
      };

      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };

      # Zigbee2MQTT's MQTT discovery (paired Zigbee devices show up on their own)
      # occurs automatically, but the MQTT integration does need to be manually
      # configured via the UI to work. Managing the MQTT broker through the
      # configuration.yaml is no longer supported.

      customComponents = with pkgs.home-assistant-custom-components; [
        nest_protect
        sensi
      ];

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


  # Matter support
  # services.home-assistant-matter-hub = {
  #   enable = true;
  #   settings.homeAssistantUrl = "http://127.0.0.1:8123";
  # };

  # Home Assistant Connect ZBT-2 (USB 303a:4001): expose the Zigbee/Thread radio
  # as a stable, dialout-owned device node. The radio is driven by Zigbee2MQTT
  # below; the zigbee2mqtt NixOS module adds that service to the `dialout` group,
  # so it can open /dev/serial/by-id/usb-Nabu_Casa_ZBT-2_A4CB8FD163BC-if00
  # (also reachable as the /dev/zbt2 symlink this rule creates).
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="4001", GROUP="dialout", MODE="0660", SYMLINK+="zbt2"
  '';

  # --- Zigbee via Zigbee2MQTT (owns the ZBT-2 radio) ---
  # Mosquitto broker: anonymous and localhost-only. Both Home Assistant and
  # Zigbee2MQTT run on this host, so nothing needs to reach the broker remotely.
  services.mosquitto = {
    enable = true;
    listeners = [{
      address = localhost;
      acl = [ "pattern readwrite #" ];
      settings.allow_anonymous = true;
    }];
  };
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      # The module already defaults `homeassistant = services.home-assistant.enable`,
      # so MQTT discovery is on and paired Zigbee devices appear automatically.
      # Keep joining off by default; toggle "Permit join" from the Z2M frontend.
      permit_join = false;
      mqtt.server = "mqtt://${localhost}:1883";
      serial = {
        port = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_A4CB8FD163BC-if00";
        adapter = "ember"; # EmberZNet EZSP adapter for the Silicon Labs EFR32MG24
        baudrate = 460800; # the ZBT-2 runs 4x the ZBT-1/SkyConnect rate
        rtscts = true; # hardware flow control
      };
      advanced = {
        channel = 25;
      };
      # Web UI on localhost; reach it via `ssh -L ${localPort}:127.0.0.1:8080 orca`.
      frontend = {
        host = localhost;
        port = 9807;
      };
    };
  };
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
    server_host = localhost;
    trusted_proxies = [ localhost ];
    use_x_forwarded_for = true;
  };
  services.caddy = {
    enable = true;
    virtualHosts."orca.griffin-cobra.ts.net".extraConfig = ''
      reverse_proxy ${localhost}:${HASS_PORT_STR}
    '';
    virtualHosts."hass.griffin-cobra.ts.net".extraConfig = ''
      reverse_proxy ${localhost}:${HASS_PORT_STR}
    '';
    virtualHosts."z2m.griffin-cobra.ts.net".extraConfig = ''
      reverse_proxy ${localhost}:${Z2M_PORT_STR}
    '';
  };
  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #   virtualHosts."${tailnet_domain}" = {
  #     extraConfig = ''
  #       proxy_buffering off;
  #     '';
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:8123";
  #       proxyWebsockets = true;
  #     };
  #     sslCertificate = "/var/lib/acme/${tailnet_domain}/cert.pem";
  #     sslCertificateKey = "/var/lib/acme/${tailnet_domain}/key.pem";
  #   };
  # };
  networking.firewall.allowedTCPPorts = [ 443 ];
  services.tailscale = {
    # Allow Caddy to generate certificates
    permitCertUid = "caddy";

    serve.enable = true;
    serve.services = {
      z2m = {
        endpoints = {
          "tcp:443" = "http://localhost:${Z2M_PORT_STR}";
        };
        advertised = true;
      };
      hass = {
        endpoints = {
          "tcp:443" = "http://localhost:${HASS_PORT_STR}";
        };
        advertised = true;
      };
    };
  };
  # Ensure the Caddy server starts after Tailscale authentication
  systemd.services.caddy.after = [ "tailscaled-autoconnect.service" ];

  # Support for mDNS, hopefully
  services.avahi = {
    nssmdns = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Wyoming discoverable services like TTS and STT
  services.wyoming.faster-whisper.servers.hass = {
    enable = true;
    device = "cpu";
    initialPrompt = ''
      You are a home assistant helping with the following request. Be short but polite
      in your response. When there are many details available, prioritize details related
      to the initial request and keep to a summary of details.
    '';
    model = "turbo";
    uri = "tcp://${localhost}:10300";
    sttLibrary = "faster-whisper";
    language = "en";
  };
  services.wyoming.piper.servers.hass = {
    enable = true;
    # https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/hfc_female/medium/en_US-hfc_female-medium.onnx?download=true
    voice = "en_US-hfc_female-medium";
    uri = "tcp://${localhost}:10200";
  };
  ### END SECTION: HOME ASSISTANT ###

  # Common issue with systemd-networkd wait-online target
  oxc.services.wait-online.enable = false;
}
