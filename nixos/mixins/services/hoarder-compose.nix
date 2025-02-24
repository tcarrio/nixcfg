_: {
  imports = [
    ../../../compose2nix/hoarder/docker-compose.nix
  ];

  age.secrets.hoarder-env-file = {
    file = ../../../secrets/services/hoarder/env.age;
    owner = "root";
    group = "root";
    mode = "400";
  };
}