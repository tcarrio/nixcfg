{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "auth0-cli";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "auth0";
    repo = "auth0-cli";
    rev = "v${version}";
    sha256 = "sha256-jplnGkqhJ5lKAAXNqF7FpbTsmjBz8ephlrgm1e1oTHY=";
  };

  vendorHash = "sha256-T8y7MPFebDU6skfz4Rqo0ElRRaldtfexOl99D7h+orU=";

  doCheck = false;

  meta = with lib; {
    description = "Build, manage and test your Auth0 integrations from the command line";
    homepage = "https://github.com/auth0/auth0-cli";
    maintainers = with maintainers; [ tcarrio ];
    license = licenses.mit;
  };
}
