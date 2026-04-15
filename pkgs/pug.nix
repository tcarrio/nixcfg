{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:

buildGoModule rec {
  pname = "pug";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "leg100";
    repo = "pug";
    rev = "v${version}";
    hash = "sha256-evt2wlRFjCcO+2IWme55QCEPuI0jluVaS/fGQVWEd44=";
  };

  vendorHash = "sha256-jKQ979iDsTMjiH7F5k4EKUzTxyQgZNIs0xhi4ZqZD2E=";

  ldflags = [ "-X github.com/leg100/pug/z.VERSION=${version}" ];

  meta = with lib; {
    description = "Drive terraform at terminal velocity.";
    mainProgram = "pug";
    homepage = "https://github.com/leg100/pug";
    changelog = "https://github.com/leg100/pug/releases/tag/v${version}";
    license = licenses.mpl20;
    maintainers = with maintainers; [ tcarrio ];
  };
}
