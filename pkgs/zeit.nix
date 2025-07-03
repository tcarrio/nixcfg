{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "zeit";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "mrusme";
    repo = "zeit";
    rev = "v${version}";
    hash = "sha256-6zRHEaa7mwM077pFbNMEuNuTr6xy0C7YJBeF047juoo=";
  };

  vendorHash = "sha256-60vc5kv2oelgROeWOueDGdiIBk6cAI1NMWDOzzlKHs8=";

  ldflags = [ "-X github.com/mrusme/zeit/z.VERSION=${version}" ];

  meta = with lib; {
    description = "Zeit, erfassen. A command line tool for tracking time spent on activities.";
    mainProgram = "zeit";
    homepage = "https://github.com/mrusme/zeit";
    changelog = "https://github.com/mrusme/zeit/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tcarrio ];
  };
}
