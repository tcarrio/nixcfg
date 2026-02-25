{ lib, buildGoModule, fetchFromGitHub, ... }:

# See https://github.com/JFryy/qq
buildGoModule rec {
  pname = "qq-cli";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-Ukk9PWlTKQ1S9LbGJtvrrKxXqYZDIdYkrs6f2vFJcZs=";
  };

  vendorHash = "sha256-dTC9Nk1zixv/9jG+xUGC7Yoc8FFlY7wio9FLoUQO7RA=";

  meta = with lib; {
    description = "jq, but with many interoperable configuration format transcodings and interactive querying.";
    mainProgram = "qq";
    homepage = "https://github.com/JFryy/qq";
    changelog = "https://github.com/JFryy/qq/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ tcarrio ];
  };
}
