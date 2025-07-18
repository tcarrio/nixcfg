{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "awsesh";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "elva-labs";
    repo = "awsesh";
    rev = "v${version}";
    hash = "sha256-AzRHEaa7mwM077pFbNMEuNuTr6xy0C7YJBeF047juoo=";
  };

  vendorHash = "sha256-6Avc5kv2oelgROeWOueDGdiIBk6cAI1NMWDOzzlKHs8=";

  ldflags = [ "-X github.com/elva-labs/awsesh/z.VERSION=${version}" ];

  meta = with lib; {
    description = "A charming TUI for AWS SSO session management ✨";
    mainProgram = "awsesh";
    homepage = "https://github.com/elva-labs/awsesh";
    changelog = "https://github.com/elva-labs/awsesh/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tcarrio ];
  };
}

