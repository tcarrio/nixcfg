{
  lib,
  ...
}:
{
  # SSH key matrix as a module option (not a specialArg) so modules can
  # consume it without the host factory. Defaults to the repo matrix;
  # hosts may override or extend per-system.
  options.oxc.ssh = {
    matrix = lib.mkOption {
      type = lib.types.attrs;
      default = import ../../lib/ssh/matrix.nix;
      description = ''
        SSH key matrix: { groups, systems } as maintained in
        lib/ssh/matrix.nix. Consumers read e.g.
        config.oxc.ssh.matrix.groups.privileged_users.
      '';
    };
  };
}
