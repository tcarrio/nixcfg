{ pkgs, inputs, username, ... }: {
  environment.systemPackages = [
    emacs
  ];
}
