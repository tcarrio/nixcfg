# Declarative post-install ZFS dataset management + backup wiring.
#
# disko stays the install-time source of truth and is never re-run against a
# live pool. This module owns datasets created AFTER installation: each entry
# is created idempotently at boot (create-only, never destroy or modify), so
# `oxc.zfs.datasets` is the declarative surface for per-service datasets.
#
# SAFETY (learned the hard way on orca 2026-10-26): this unit REFUSES to
# create a dataset whose mountpoint directory already exists and is
# non-empty — mounting over it would SHADOW the directory's data (the
# dataset mounts at that path, hiding the original contents). Creation
# without `-p`: a missing parent dataset is also a hard error, because
# `zfs create -p` silently creates intermediates as MOUNTED datasets,
# shadowing whatever directory structure lives there. Intermediate
# datasets must be declared explicitly (and want canmount=off — see
# `oxc.zfs.intermediates`).
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
      description = "ZFS datasets to ensure exist on this host (created only if missing, never over non-empty directories)";
    };

    intermediates = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Dataset names that must exist as NON-MOUNTING intermediates
        (canmount=off) so their children can mount at the shared parent
        path — e.g. zroot/var/lib with children zroot/var/lib/<service>.
        Ensured at boot: created with canmount=off if missing, and
        healed to canmount=off if an earlier mistake left them mounted.
        A mounted intermediate shadows the whole directory it mounts
        over; this option makes that state self-correcting.
      '';
    };
  };

  config = {
    systemd.services."oxc-zfs-ensure-datasets" = {
      description = "Ensure declared ZFS datasets exist (idempotent, non-destructive; refuses to shadow non-empty directories)";
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
        # Intermediates first: canmount=off, never mounted, so children
        # mount at the parent path with nothing shadowed. Creation is
        # safe even when the path exists as a plain directory — a
        # canmount=off dataset never mounts over anything. An existing
        # MOUNTED intermediate of the same name is healed to off (its
        # own contents, if any, were a mistake; children are unaffected).
        lib.mapAttrsToList (_: name: ''
          if ! zfs list -H -o name ${lib.escapeShellArg name} >/dev/null 2>&1; then
            echo "oxc-zfs-ensure-datasets: creating intermediate ${name} (canmount=off)"
            zfs create -o canmount=off -o com.sun:auto-snapshot=false ${lib.escapeShellArg name}
          elif [ "$(zfs get -H -o value canmount ${lib.escapeShellArg name})" != "off" ]; then
            echo "oxc-zfs-ensure-datasets: healing intermediate ${name} to canmount=off"
            zfs unmount ${lib.escapeShellArg name} 2>/dev/null || true
            zfs set canmount=off ${lib.escapeShellArg name}
          fi
        '') (lib.listToAttrs (map (n: lib.nameValuePair n n) cfg.intermediates))
        ++ lib.mapAttrsToList (
          name: ds:
          # Create-only, and NEVER over a non-empty directory: the new
          # dataset would mount at ds.mountpoint and hide the original
          # data. Migrating existing data into a fresh dataset is a
          # deliberate runbook operation (stop services, vacate, create,
          # rsync back — see the orca backup & DR plan in eru); this unit
          # failing loudly is the correct behavior.
          ''
            if ! zfs list -H -o name ${lib.escapeShellArg name} >/dev/null 2>&1; then
              if [ -d ${lib.escapeShellArg ds.mountpoint} ] && [ -n "$(ls -A ${lib.escapeShellArg ds.mountpoint} 2>/dev/null)" ]; then
                echo "oxc-zfs-ensure-datasets: REFUSING to create ${name}: ${ds.mountpoint} exists and is non-empty — a new dataset would SHADOW its data. Migrate it first (backup & DR plan runbook)." >&2
                exit 1
              fi
              echo "oxc-zfs-ensure-datasets: creating ${name}"
              zfs create -o com.sun:auto-snapshot=false -o compression=${lib.escapeShellArg ds.compression} ${lib.escapeShellArg name}
            fi
          ''
        ) cfg.datasets
      );
    };
  };
}
