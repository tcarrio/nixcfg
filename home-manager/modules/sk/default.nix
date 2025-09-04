{ lib, config, username, pkgs, ... }:
let
  cfg = config.sk;
  homeDir = config.home.homeDirectory;
  devDir = "${homeDir}/Developer";
  wsDir = "${devDir}/workstation";
  repoBase = "Skillshare";

  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    ./rancher-desktop.nix
  ];

  options.sk.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable the SK work module";
  };

  options.sk.containerization.engine = lib.mkOption {
    type = lib.types.str;
    default = "docker";
    description = "Which containerization technology to use";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs.unstable; [
        cursor-cli
      ];
      # General support for non-fish shell or sessions
      sessionPath = [ "/opt/homebrew/bin" "${homeDir}/.asdf/bin" ];
      sessionVariables = {
        AWS_REGION = "us-east-1";
        AWS_PROFILE = "skillshare-utility-developer";
        NIXPKGS_ALLOW_UNFREE="1";
        SKILLSHARE_WORKSTATION_WARP = "true";
        SKILLSHARE_SRC_DIRECTORY = "${devDir}";
        PUPPETEER_EXECUTABLE_PATH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
        PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "true";
        SSH_AUTH_SOCK = "${homeDir}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      };
      file = {
        "${config.xdg.configHome}/direnv/direnv.toml".text = lib.mkForce ''
          [global]
          load_dotenv = true
          strict_env = true

          [whitelist]
          prefix = [ "${devDir}" ]
        '';
      };
    };

    programs.bash.initExtra = ''
      if [ -d "${wsDir}" ]
        source "${wsDir}/workstation.sh"
      else
        echo "⚠️ No workstation environment found. Please set up your workstation environment."
      end
    '';

    programs.fish = {
      interactiveShellInit = ''
        if [ ! -d "${devDir}" ]
          mkdir -p "${devDir}"
        end
        if command -v brew >/dev/null
          set -x PATH "$(brew --prefix)/bin:$PATH"
        end
        if command -v asdf >/dev/null
          set -x PATH "${homeDir}/.asdf/bin:$PATH"
        end
        if [ -f "${homeDir}/.nix-profile/share/asdf-vm/asdf.fish" ]
          source "${homeDir}/.nix-profile/share/asdf-vm/asdf.fish"
        end
        if command -v task >/dev/null
          task --completion fish | source
        end
        if command -v jira >/dev/null
          jira completion fish | source
        end

        # add existing gcloud to PATH
        [ -f "${homeDir}/sdks/google-cloud-sdk/path.fish.inc" ] && source "${homeDir}/sdks/google-cloud-sdk/path.fish.inc"

        # TODO: Initialize workstation if SSH is set up

        if [ -d "${wsDir}" ]
          fenv source "${wsDir}/workstation.sh"
        else
          echo "⚠️ No workstation environment found. Please set up your workstation environment."
        end
      '';
      shellAliases =
        let
          sksh = target: "nix develop ${homeDir}/0xc/sksh#${target} --command \$SHELL";
          skillshareWorkstation = "${wsDir}/bin/skillshare-workstation";
        in
        {
          sk = skillshareWorkstation;
          sw = skillshareWorkstation;

          asso = "aws sso login";

          "sksh:skillshare" = sksh "skillshare";

          clear-all-cache = lib.mkForce ''
            which nix && echo 'Pruning nix' && nix-collect-garbage --delete-older-than 14d
            which docker && echo 'Pruning docker' && docker system prune -a --volumes -f
            which yarn && echo 'Pruning yarn' && yarn cache clean
            which npm && echo 'Pruning npm' && npm cache clean --force
            which bun && echo 'Pruning bun' && bun cache clean
            which pnpm && echo 'Pruning pnpm' && pnpm cache clean --all
            [ -d "${devDir}" ] && find "${devDir}" -type d -name "node_modules" | xargs -I '{}' -P 12 rm -rf "{}"
          '';

          aws-list-accounts = "aws organizations list-accounts | ${pkgs.jq}/bin/jq '[.Accounts[] | {Id, Name, Arn}]' | ${pkgs.jtbl}/bin/jtbl";
        };
    };

    programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
  };
}
