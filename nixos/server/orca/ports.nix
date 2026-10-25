_: {
  # Central port map for orca. `oxc.ports` (modules/shared/ports.nix) is
  # shared across the nixos/darwin/home-manager module trees and carries a
  # build-time assertion: two services claiming the same port fail the
  # evaluation, so a rebuild with a port collision cannot be built.
  #
  # Every port this host intentionally binds is claimed here, including
  # infrastructure ports (ssh, caddy) that the services below do not read
  # from the map — claiming them anyway keeps an application claim from
  # silently colliding with them at runtime.
  oxc.ports = {
    # Infrastructure (firewall only allows 22 and 443)
    ssh = 22;
    caddy-http = 80;
    caddy-https = 443;

    # Applications (loopback or firewall-closed; Caddy-fronted)
    dawarich = 3001; # dawarich.nix — module default 3000 taken by trek
    trek = 3000; # trek.nix
    stirling-pdf = 8080; # stirling-pdf.nix
    oxicloud = 8086; # oxicloud.nix
    jellyfin = 8096; # media-server.nix — module hardcodes 8096, no port option
    pinchflat = 8945; # pinchflat.nix
    paperless = 8300; # paperless.nix — web
    gotenberg = 8301; # paperless.nix — module default 3000 collides with trek
    tika = 9998; # paperless.nix
    home-assistant = 8123; # hass.nix
    mosquitto = 1883; # hass.nix
    zigbee2mqtt = 9807; # hass.nix
    collabora = 9980; # collabora.nix
  };
}
