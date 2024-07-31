{ pkgs, lib, config, ... }: {
  options.oxc.desktop.zed = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zed editor";
    };
  };

  config = lib.mkIf config.oxc.desktop.zed.enable {
    environment.systemPackages = [
      pkgs.zed-editor
    ];
  };
}
