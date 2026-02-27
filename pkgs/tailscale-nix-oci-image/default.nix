{
  build-oci-image,
  iptables-legacy,
  sysctl,
  tailscale,
  writeShellApplication,
  ...
}:
let
  scriptDeps = [
    iptables-legacy
    sysctl
    tailscale
  ];
  script = writeShellApplication {
    name = "entrypoint.sh";
    text = builtins.readFile ./entrypoint.sh;
    runtimeInputs = scriptDeps;
  };
in build-oci-image {
  drv = script;
  extraContents = scriptDeps ++ [];
  ociLabels = {
    "org.label-schema.name" = "tailscale-nix-oci-image";
    "org.label-schema.description" = "A Tailscale server packaged with Nix";
  };
}
