rec {
  # exports the system definitions directly
  systems = import ./systems.nix;

  manualKeys = {
    yubikeyFido = "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBHd1Depf72rUBC6FCZ06ziB5SRik7FRfYaCDMoju2HkoWRT1X5655144waK0hUQ2ptgvqffDwX0YINiN2xZWFK0AAAAEc3NoOg== tom@carrio.dev";
  };

  # collect logical groupings of systems
  groups = rec {
    remote_build_clients = with systems; [
    ];

    privileged_users = with systems; [
      obsidian.host
      obsidian.tcarrio
      manualKeys.yubikeyFido
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
