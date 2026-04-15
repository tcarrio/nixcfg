{ config, lib, pkgs, ... }:
let
  cfg = config.sk.asdf;

  asdfClearAll = pkgs.writeShellApplication {
    name = "asdf-clear-all";
    text = ''
      if ! which asdf 2>/dev/null
      then
        echo 'No asdf found in PATH!'
      fi

      function usage() {
        echo "
        asdf-clear-all <plugin-name>

        The plugin-name must be one of:
        $(asdf plugin list | sed -E 's#^#  - #g')
        ";
      }

      target="''${1:-}"

      case "$target" in
        "")
          echo 'Missing plugin name'
          exit 1
          ;;
        "--help"|"-h")
          usage
          exit 0
          ;;
        "-*")
          usage
          exit 1
          ;;
      esac

      asdf list "$target" \
        | sed 's#[* ]##g' \
        | while read -r target_version
          do
            asdf uninstall "$target" "$target_version"
          done
    '';
    runtimeInputs = with pkgs; [
      gnused
    ];
  };
in
{
  options.sk.asdf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable support for asdf helpers";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      asdfClearAll
    ];
  };
}
