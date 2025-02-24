# compose2nix

This [tool](https://github.com/aksiksi/compose2nix) supports taking an existing `docker-compose.yml` and generating a Nix config uses the `oci-containers` directive. This allows you to effectively import an existing Docker Compose project, utilize Docker containers, but manage it via the standard Nix configuration for your system.

## Usage

I plan to create directories per projects that I translate. These may end up being reworked into modules that under `nixos/modules` instead, which would allow further configuration of the tooling, dynamic mounting of secret files, etc.

🚧 **Any usage of these comes with absolutely zero guarantees. I'm just testing this out myself.**

## Protecting secrets

There are going to be some secret values that are referenced in services that SHOULD NOT be including as part of the conversion. With docker-compose, you often reference an *env file* to provide secrets. With `convert2nix`, The output of the conversion is a *plaintext* NixOS configuration- so secrets should never be part of this.

In most cases, secrets will be defined in `secrets/secrets.nix` which is powered by `agenix`. This encrypts all data with `age` and provides access to hosts via the host's *private* key to decrypt data. The definition for access rules is simply references to the *public* keys of the hosts.

## Converting 2 Nix

A basic conversion can be done by executing, within the directory with a `docker-compose.yml`, the following command:

```shell
compose2nix -project=$whatever_you_want_to_call_your_docker_compose_project
```

Which will convert it to a `docker-compose.nix` file.

### Converting 2 Nix with Secrets

If you must provide secrets, make sure to generate the secrets with `agenix`. The path of the secrets file as mounted under `/run/agenix/...` will be determined by the NixOS configuration. You will have something like `age.secrets.service-foo-env = { ... }`. This will result in a file at `/run/agenix/service-foo-env` that can only be read by the host `root` user.

In case you are setting up services to execute under different users, or want to modify the default permissions mode, you can adjust this like so:

```nix
age.secrets.service-foo-env = {
  file = path/to/secret.age;
  owner = "service_user";
  group = "service_group";
  mode = "400";
};
```

Now, `compose2nix` can refer to an environment file in two ways: Evaluating and including environment file values in the output, or referencing the file path instead, deferring evaluation to the container runtime. The latter MUST be used for secrets. You would do something like the following in this case:

```shell
compose2nix -env_files=/run/agenix/service-foo-env -include_env_files=true -ignore_missing_env_files -project=foo
nix run github:aksiksi/compose2nix -- -project=hoarder --env_files=/run/agenix/service-foo-env -env_files_only=true -ignore_missing_env_files
```

⚠️ If you are generating a new service, or not running the generation on the host you will run the containers, you definitely will need `-ignore_missing_env_files`, as you will not have the env files mounted on your system.

⚠️ The behavior of `env_file` in Docker Compose files with regards to `compose2nix` can be confusing. These files are read and their values injected into the output Nix configuration. Avoid these for secrets.