{ lib, buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "typescript-go";
  version = "0.0.0-unstable-2025-01-15";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "typescript-go";
    rev = "main";
    hash = "sha256-wgTiVxKqoy9jIa1QnaOJ7K28oETCB9LmqpDiILNbWBc=";
  };

  vendorHash = "sha256-ywhlLaUq2bjfE9GZIUOIcufIY1GLw3ZRGM+ZDfEpOiU=";

  subPackages = [ "cmd/tsgo" ];

  # Build with noembed and release tags as per Herebyfile.mjs
  tags = [ "noembed" "release" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Native port of TypeScript implemented in Go";
    mainProgram = "tsgo";
    homepage = "https://github.com/microsoft/typescript-go";
    license = licenses.asl20;
    maintainers = with maintainers; [ tcarrio ];
    platforms = platforms.unix ++ platforms.darwin;
  };
}
