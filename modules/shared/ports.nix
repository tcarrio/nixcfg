{
  lib,
  config,
  ...
}:
let
  # Invert the service -> port map into port -> claimants for the
  # duplicate check.
  claimantsByPort = lib.foldl' (
    acc: name:
    let
      port = toString config.oxc.ports.${name};
    in
    acc // { ${port} = (acc.${port} or [ ]) ++ [ name ]; }
  ) { } (lib.attrNames config.oxc.ports);

  duplicates = lib.filterAttrs (_: names: lib.length names > 1) claimantsByPort;
in
{
  options.oxc.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
    description = ''
      Per-host port claims: service name -> TCP port. Each service reads
      its port from this map (`config.oxc.ports.<name>`), making the map
      the single source of truth for a host's port layout. An assertion
      fails the evaluation — and therefore any rebuild — if two services
      claim the same port.
    '';
  };

  config.assertions = [
    {
      assertion = duplicates == { };
      message = ''
        oxc.ports: duplicate port claims:
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            port: names: "  ${port} claimed by ${lib.concatStringsSep ", " names}"
          ) duplicates
        )}
      '';
    }
  ];
}
