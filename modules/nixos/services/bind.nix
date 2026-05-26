{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  # Generate BIND zone file content from declarative record definitions
  generateZoneFile =
    {
      zone,
      records ? [ ],
      ttl ? "1h",
      soa ? null,
      email ? null,
      serial ? null,
      refresh ? null,
      retry ? null,
      expire ? null,
      negativeCacheTtl ? null,
    }@args:
    let
      # Normalize zone name (ensure trailing dot)
      normalizedZone = if lib.hasSuffix "." zone then zone else "${zone}.";
      
      # Sort records by name and type for consistent output
      sortedRecords = builtins.sort (a: b:
        if a.name == b.name then
          lib.lessThan a.type b.type
        else
          lib.lessThan a.name b.name
      ) records;

      # Extract NS records if present
      nsRecords = builtins.filter (r: r.type == "NS") sortedRecords;
      
      # Build SOA parameters with defaults
      soaNs = if soa != null && soa.ns != null then soa.ns else
              if builtins.length nsRecords > 0 then (builtins.head nsRecords).value else "ns1.${normalizedZone}";
      
      soaEmail = if soa != null && soa.email != null then soa.email else
                 if email != null then email else "hostmaster.${normalizedZone}";
      
      soaSerial = if soa != null && soa.serial != null then soa.serial else
                  if serial != null then serial else 1;
      
      soaRefresh = if soa != null && soa.refresh != null then soa.refresh else
                   if refresh != null then refresh else "3h";
      
      soaRetry = if soa != null && soa.retry != null then soa.retry else
                 if retry != null then retry else "1h";
      
      soaExpire = if soa != null && soa.expire != null then soa.expire else
                  if expire != null then expire else "1w";
      
      soaNegativeCacheTtl = if soa != null && soa.negativeCacheTtl != null then soa.negativeCacheTtl else
                            if negativeCacheTtl != null then negativeCacheTtl else "1h";

      # Format individual records
      formatRecord = record: let
        name = if record.name == "@" then "@" else record.name;
        ttlStr = if record.ttl != null then "  ${record.ttl}" else "";
        value = if record.type == "TXT" && !(lib.hasPrefix "\"" record.value) then "\"${record.value}\"" else record.value;
      in ''
        ${name}${ttlStr}  IN  ${record.type}  ${value}
      '';
    in
    ''
      $ORIGIN ${normalizedZone}
              $TTL    ${ttl}
              @            IN      SOA     ${soaNs} ${soaEmail} (
                                   ${builtins.toString soaSerial}    ; Serial
                                   ${soaRefresh}   ; Refresh
                                   ${soaRetry}     ; Retry
                                   ${soaExpire}    ; Expire
                                   ${soaNegativeCacheTtl})  ; Negative Cache TTL
      
      ${lib.concatMapStrings (r: if r.type == "NS" then "${formatRecord r}\n" else "") sortedRecords}
      
      ${lib.concatMapStrings (r: if r.type != "NS" then "${formatRecord r}\n" else "") sortedRecords}
    '';

  # Define the record type
  recordType = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        description = "Record name (use '@' for zone origin)";
        example = "www";
      };
      type = lib.mkOption {
        type = types.enum [ "A" "AAAA" "CNAME" "MX" "TXT" "NS" "PTR" "SRV" "CAA" ];
        description = "DNS record type";
        example = "A";
      };
      value = lib.mkOption {
        type = types.str;
        description = "Record value";
        example = "10.0.0.1";
      };
      ttl = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Per-record TTL (overrides zone default)";
        example = "1h";
      };
    };
  };

in
{
  options.services.bind.zones = lib.mkOption {
    type = with types; attrsOf (submodule (zoneArgs@{
      config,
      name,
      ...
    }: {
      options = {
        records = lib.mkOption {
          type = types.nullOr (types.listOf recordType);
          default = null;
          description = "Declarative DNS records for this zone (mutually exclusive with file)";
          example = [
            { type = "A"; name = "@"; value = "203.0.113.1"; }
            { type = "AAAA"; name = "@"; value = "2001:db8:113::1"; }
            { type = "MX"; name = "@"; value = "10 mail"; }
          ];
        };
        
        zoneTtl = lib.mkOption {
          type = types.str;
          default = "1h";
          description = "Default TTL for records in this zone";
        };
        
        soa = lib.mkOption {
          type = types.nullOr (types.submodule {
            options = {
              ns = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Primary nameserver for SOA record";
                example = "ns1.example.com.";
              };
              email = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Email address for SOA record (with @ replaced by .)";
                example = "hostmaster.example.com.";
              };
              serial = lib.mkOption {
                type = types.nullOr types.int;
                default = null;
                description = "SOA serial number";
              };
              refresh = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "SOA refresh time";
              };
              retry = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "SOA retry time";
              };
              expire = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "SOA expire time";
              };
              negativeCacheTtl = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "SOA negative cache TTL";
              };
            };
          });
          default = null;
          description = "SOA record configuration (if null, uses defaults)";
        };
      };
      
      # Automatically generate file from records
      config.file = lib.mkIf (config.records != null) (pkgs.writeText "${name}.zone" 
        (generateZoneFile {
          zone = name;
          records = config.records;
          ttl = config.zoneTtl;
          inherit (config) soa;
        })
      );
    }));
  };

  # Validation that zones don't have both file and records
  config.warnings = lib.mapAttrsToList (zoneName: zoneConfig:
    if zoneConfig ? file && zoneConfig.file != null && zoneConfig.records != null then
      "bind zone ${zoneName}: cannot specify both 'file' and 'records'"
    else
      null
  ) config.services.bind.zones;

  # System checks for BIND validation
  config.system.checks = lib.mkIf config.services.bind.enable [
    # Validate generated zone files
    (pkgs.writeShellScriptBin "bind-zone-validation" ''
      set -e
      echo "Validating BIND zone files..."
      ${lib.concatMapStringsSep "\n" (zoneName: 
        let zoneConfig = config.services.bind.zones.${zoneName};
        in
          if zoneConfig.records != null then
            let
              zoneFile = pkgs.writeText "${zoneName}-validation.zone" 
                (generateZoneFile {
                  zone = zoneName;
                  records = zoneConfig.records;
                  ttl = zoneConfig.zoneTtl;
                  inherit (zoneConfig) soa;
                });
            in ''
              echo "Validating zone: ${zoneName}"
              ${config.services.bind.package}/bin/named-checkzone "${zoneName}" "${zoneFile}"
            ''
          else ""
      ) (builtins.attrNames config.services.bind.zones)}
      echo "All BIND zone files validated successfully"
    '')
  ];
}
  ];
}