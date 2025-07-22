# see install/development.sh
{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      cargo
      clang # llvmPackages.clangNoLibc?
      llvm # llvmPackages.clangNoLibc?
      mise
      imagemagick
      mariadb # from mariadb-libs
      postgresql # from postgresql-libs
      gh # from github-cli
      lazygit
      lazydocker
    ];
  };
}
