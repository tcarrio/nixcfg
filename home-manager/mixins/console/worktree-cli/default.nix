{ pkgs, lib, ... }: {
  home.packages = [(
    pkgs.writeShellApplication {
      name = "wt";
      text = (lib.readFile ./wt.sh);
    }
  )];
}
