{ inputs, ... }: {
  environment.systemPackages = [ inputs.nix-user-repository.nur.repos.LuisChDev.nordvpn ];
}
