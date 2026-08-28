{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "damacus";
  domain = "robovac";
  version = "2.4.3";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = "v${version}";
    hash = "sha256-ciuGjaOO8BsvYXQrCjG1Yr3KuWIiySskM0X36Nyl5tU=";
  };

  # Upstream declares no requirements: its only third-party imports
  # (cryptography, requests) already ship with Home Assistant core.
  dependencies = [ ];

  meta = {
    changelog = "https://github.com/damacus/robovac/releases/tag/v${version}";
    description = "Home Assistant integration for Eufy RoboVac vacuums";
    homepage = "https://github.com/damacus/robovac";
    maintainers = [ ];
    license = lib.licenses.asl20;
  };
}
