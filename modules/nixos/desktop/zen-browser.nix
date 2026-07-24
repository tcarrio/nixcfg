{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.oxc.desktop.zen-browser;

  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    # Check these out at about:config
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
    # NVidia improvements
    "media.ffmpeg.vaapi.enabled" = true;
    "gfx.x11-egl.force-enabled" = true;
    "widget.dmabuf.force-enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
  };

  extensions = [
    # To add additional extensions, find it on addons.mozilla.org, find
    # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
    # Then go to https://addons.mozilla.org/api/v5/addons/addon/!SHORT_ID!/ to get the guid
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    # ...
  ];

  extraPrefs = lib.concatLines (
    lib.mapAttrsToList (
      name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
    ) prefs
  );

  zenPkg = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped;
  wrappedZen = zenPkg.overrideAttrs {
    # NVidia improvements
    LIBVA_DRIVER_NAME = "nvidia";   # tell libva to use the nvidia backend
    NVD_BACKEND = "direct";         # required by recent nvidia-vaapi-driver on X11
    MOZ_DISABLE_RDD_SANDBOX = "1";  # the decoder sandbox otherwise blocks GPU access
  };

  pkg = (pkgs.wrapFirefox
    wrappedZen
    {
      inherit extraPrefs;

      extraPolicies = {
        DisableTelemetry = false;
        ExtensionSettings = builtins.listToAttrs extensions;

        SearchEngines = {
          Default = "ddg";
          Add = [
            {
              Name = "nixpkgs packages";
              URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
              IconURL = "https://wiki.nixos.org/favicon.ico";
              Alias = "@np";
            }
            {
              Name = "NixOS options";
              URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
              IconURL = "https://wiki.nixos.org/favicon.ico";
              Alias = "@no";
            }
            {
              Name = "NixOS Wiki";
              URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              IconURL = "https://wiki.nixos.org/favicon.ico";
              Alias = "@nw";
            }
            {
              Name = "noogle";
              URLTemplate = "https://noogle.dev/q?term={searchTerms}";
              IconURL = "https://noogle.dev/favicon.ico";
              Alias = "@ng";
            }
          ];
        };
      };
    }
  );
in
{
  options.oxc.desktop.zen-browser = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zen browser";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.flatpak.enable;
        message = "Flatpak must be enabled to install Zen Browser";
      }
    ];

    # services.flatpak.packages = [ "flathub:app/app.zen_browser.zen//stable" ];
    environment.systemPackages = [
      pkg
      pkgs.libva
      pkgs.libva-utils
    ];
  };
}
