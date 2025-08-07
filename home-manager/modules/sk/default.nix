{ lib, config, username, pkgs, ... }:
let 
  cfg = config.sk;
  homeDir = config.home.homeDirectory;
  devDir = "${homeDir}/Developer";
  wsDir = "${devDir}/workstation";
  repoBase = "Skillshare";
in {
  options.sk.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable the SK work module";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        asdf-vm
      ];
      sessionPath = [ "/opt/homebrew/bin" ];
      sessionVariables = {
        AWS_REGION = "us-east-1";
        AWS_PROFILE = "skillshare-utility-developer";
        NIXPKGS_ALLOW_UNFREE="1";
        SKILLSHARE_WORKSTATION_WARP = "true";
        SKILLSHARE_SRC_DIRECTORY = "${devDir}";
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

    programs.fish = {
      interactiveShellInit = ''
        if [ ! -d "${devDir} ]
          mkdir -p "${devDir}
        end
        if command -v brew >/dev/null
          set -x PATH "$(brew --prefix)/bin:$PATH"
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

        if [ ! -d "${wsDir}" ]
          if [ -d "${homeDir}/.ssh" ]
            git clone 
          end
        end

        if [ -d "${wsDir}" ]
          fenv source "${wsDir}/workstation.sh"
        end
      '';
      shellAliases =
        let
          skShell = target: "nix develop ${homeDir}/0xc/sksh#${target} --command \$SHELL";
          skillshareWorkstation = "${wsDir}/bin/skillshare-workstation";
        in
        {
          sk = skillshareWorkstation;
          sw = skillshareWorkstation;

          asso = "aws sso login";

          "sk:mono" = skShell "sk";
          "sk:web" = skShell "web";
          "sk:php74" = skShell "php74";
          "sk:php80" = skShell "php80";
          "sk:php81" = skShell "php81";
          "sk:php82" = skShell "php82";
          "sk:node" = skShell "node";
          "sk:node16" = skShell "node16";
          "sk:node18" = skShell "node18";
          "sk:node20" = skShell "node20";
          "sk:python" = skShell "python";

          clear-all-cache = lib.mkForce ''
            which nix && echo 'Pruning nix' && nix-collect-garbage --delete-older-than 14d
            which docker && echo 'Pruning docker' && docker system prune -a --volumes -f
            which yarn && echo 'Pruning yarn' && yarn cache clean
            which npm && echo 'Pruning npm' && npm cache clean --force
            which bun && echo 'Pruning bun' && bun cache clean
            which pnpm && echo 'Pruning pnpm' && pnpm cache clean --all
            [ -d "${devDir}" ] && find "${devDir}" -type d -name "node_modules" | xargs -I '{}' -P 12 rm -rf "{}"
          '';
        };
    };

    programs.git.userEmail = lib.mkForce "thomas.carrio@skillshare.com";
  };
}