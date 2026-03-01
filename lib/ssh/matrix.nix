rec {
  # exports the system definitions directly
  systems = import ./systems.nix;

  # collect logical groupings of systems
  groups = rec {
    remote_build_clients = with systems; [
    ];

    privileged_users = with systems; [
      obsidian.host
      obsidian.tcarrio
    ];

    users = with systems; [
      void.tcarrio
    ] ++ privileged_users;

    deploy_keys = with systems; [
    ];

    backup_keys = [
    ];
  };
}
