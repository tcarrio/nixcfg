{ lib
, buildGo120Module
, fetchFromGitHub
}:

buildGo120Module rec {
  pname = "auth0-cli";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "auth0";
    repo = "auth0-cli";
    rev = "v${version}";
    sha256 = "sha256-jplnGkqhJ5lKAAXNqF7FpbTsmjBz8ephlrgm1e1oTHY=";
  };

  vendorHash = "sha256-T8y7MPFebDU6skfz4Rqo0ElRRaldtfexOl99D7h+orU=";

  # upstream did not update the tests, so they are broken now
  # https://github.com/sorenisanerd/gotty/issues/13
  doCheck = true;

  meta = with lib; {
    description = "Build, manage and test your Auth0 integrations from the command line";
    homepage = "https://github.com/auth0/auth0-cli";
    maintainers = with maintainers; [ ];
    license = licenses.mit;
  };
}