# Largely based on the nix-community/docker-nixpkgs approach
# @see https://github.com/nix-community/docker-nixpkgs/blob/10b83cdcf12c7d37db50cd8d2c68b336881b91de/lib/buildCLIImage.nix
{ dockerTools
, busybox
, cacert
}:
{ drv # derivation to build the image for
  # Name of the binary to run by default
, binName ? (builtins.parseDrvName drv.name).name
, extraContents ? [ ]
, meta ? drv.meta
, ociLabels ? { }
}:
let
  architecture = "x86_64-linux";

  image = dockerTools.buildLayeredImage {
    inherit (drv) name;

    inherit architecture;

    contents = [
      # add a /bin/sh on all images
      busybox
      # most program need TLS certs
      cacert
      drv
    ] ++ extraContents;

    config = {
      Cmd = [ "/bin/${binName}" ];
      Env = [
        "PATH=/bin"
        "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      Labels = {
        # https://github.com/microscaling/microscaling/blob/55a2d7b91ce7513e07f8b1fd91bbed8df59aed5a/Dockerfile#L22-L33
        "org.label-schema.vcs-ref" = "main";
        "org.label-schema.vcs-url" = "https://github.com/tcarrio/nixcfg";
      }
      //
      # Inject additional labels from the meta definition
      ociLabels;
    };
  };
in
image // { meta = meta // image.meta; }
