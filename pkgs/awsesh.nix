{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "awsesh";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "elva-labs";
    repo = "awsesh";
    tag = "v.${version}";
    hash = "sha256-IJd6l+04ie8jiBgmpbWr/txKJDAzetXQqyb5naZSGBg=";
  };

  vendorHash = "sha256-hGwGvE9Y0awezAijHMt5heBERcV92olugCaMzzvDvKc=";

  meta = with lib; {
    description = "A charming TUI for AWS SSO session management ✨";
    mainProgram = "awsesh";
    homepage = "https://github.com/elva-labs/awsesh";
    changelog = "https://github.com/elva-labs/awsesh/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tcarrio ];
  };
}

