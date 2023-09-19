{ lib, hostname, username, pkgs, ... }:
let
  systemShortName = "darwin";
in
{
  imports = []
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
    ++ lib.optional (builtins.pathExists (./. + "/systems/${systemShortName}.nix")) ./systems/${systemShortName}.nix;

  home = {
    file.".ssh/config".text = "
      Host github.com
        HostName github.com
        User git
    ";
    file."Quickemu/nixos-console.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-console/disk.qcow2"
      disk_size="96G"
      iso="nixos-console/nixos.iso"
    '';
    file."Quickemu/nixos-desktop.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-desktop/disk.qcow2"
      disk_size="96G"
      iso="nixos-desktop/nixos.iso"
    '';
    file."Quickemu/nixos-nuc.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-nuc/disk.qcow2"
      disk_size="96G"
      iso="nixos-nuc/nixos.iso"
    '';
    sessionVariables = {
      # ...
    };
    file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
    '';
  };
  programs = {
    git = {
      userEmail = "tom@carrio.dev";
      userName = "Tom Carrio";
    };
  };
}
