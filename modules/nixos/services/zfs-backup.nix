# Declarative post-install ZFS dataset management + backup wiring.
#
# disko stays the install-time source of truth and is never re-run against a
# live pool. This module owns datasets created AFTER installation: each entry
# is created idempotently at boot (create-only, never destroy or modify), so
# `oxc.zfs.datasets` is the declarative surface for per-service datasets.
#
# `backup.enable` is the single opt-in switch for snapshot (sanoid) and
# off-host (restic) coverage; later phases of the orca backup plan consume
# that flag from here.
{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.zfs;
in
{
  options.oxc.zfs = {
    datasets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            mountpoint = lib.mkOption {
              type = lib.types.str;
              description = "Where the dataset mounts (informational; ZFS derives it from the dataset path)";
            };
            compression = lib.mkOption {
              type = lib.types.str;
              default = "lz4";
              description = ''
                Compression algorithm applied at dataset CREATION only
                (e.g. "lz4", "zstd", "off"); existing datasets are never
                modified. Retroactive changes are a runbook operation —
                see the orca backup & DR plan in eru.
              '';
            };
            backup = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Opt the dataset into snapshot policy and off-host backup coverage";
              };
            };
          };
        }
      );
      default = { };
      description = "ZFS datasets to ensure exist on this host (created only if missing)";
    };
  };

  config = lib.mkIf (cfg.datasets != { }) {
    # Runs after the pool is imported but before zfs-mount, so a freshly
    # created dataset is mounted by zfs-mount like any other.
    systemd.services."oxc-zfs-ensure-datasets" = {
      description = "Ensure declared ZFS datasets exist (idempotent, non-destructive)";
      wantedBy = [ "sysinit.target" ];
      after = [ "zfs-import.target" ];
      before = [
        "zfs-mount.service"
        "local-fs.target"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ config.boot.zfs.package ];
      script = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: ds:
          # zfs list fails when the dataset is absent -> create it.
          # -p also creates missing parents (e.g. zroot/data for zroot/data/media).
          # auto-snapshot=false keeps zfs-auto-snapshot off these datasets;
          # sanoid (backup.enable) manages snapshots instead.
          ''
            if ! zfs list -H -o name ${lib.escapeShellArg name} >/dev/null 2>&1; then
              echo "oxc-zfs-ensure-datasets: creating ${name}"
              zfs create -p -o com.sun:auto-snapshot=false -o compression=${lib.escapeShellArg ds.compression} ${lib.escapeShellArg name}
            fi
          '') cfg.datasets
      );
    };
  };
}
