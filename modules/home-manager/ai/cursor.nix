{ config, lib, pkgs, ... }:
let
  cfg = config.oxc.ai.cursor;

  optionalSet = predicate: value: if predicate then value else {};

  generateSerenaConfigCommand = let
    serenaCfg = config.ai.serena;
    generateSerenaConfigPath = pkgs.buildEnv {
      name = "generate-serena-config-path";
      paths = [serenaCfg.package];
      pathsToLink = [ "/bin" ];
    };
    PATH = "${generateSerenaConfigPath}/bin";
    HOME = "$TMPDIR/home";
    injectConfigScript = if serenaCfg.config != null
      then ''
        cat "${serenaCfg.config}" 2>/dev/null 1> "$HOME/.serena/serena_config.yml"
      ''
      else null;
    injectFrontmatterScript = ''
      cat << EOF > "$out"
      ---
      globs:
      alwaysApply: true
      ---

      EOF
    '';
    in pkgs.runCommand "serena-config.sh" { inherit HOME PATH; } ''
      export HOME="$(pwd)/home"
      mkdir -p "$HOME/.serena"

      ${injectConfigScript}
      cat > "$HOME/.serena/serena_config.yml"
      if [ ! -f "$HOME/.serena/serena_config.yml" ]; then
        echo "Error: Serena configuration file not found." >&2
        exit 7
      fi

      ${injectFrontmatterScript}

      ${serenaCfg.package}/bin/serena print-system-prompt --log-level CRITICAL 1>> "$out"
      chmod +x "$out"
    '';
in
{
  options.oxc.ai.cursor = {
    enable = lib.mkEnableOption "Enable Cursor AI";
    riper-5.enable = lib.mkEnableOption "Enable Riper-5 AI";
    serena.enable = lib.mkEnableOption "Enable Serena MCP integration";
    typescript.enable = lib.mkEnableOption "Enable TypeScript Cursor rules";
    sk.enable = lib.mkEnableOption "Enable Skillshare Cursor rules";
  };

  config = lib.mkIf cfg.enable {
    home.copy-files =
    # Setup RIPER-5 Cursor files
    {
      ".cursor/skills/jira-ticket-planning.md".source = ./skills/jira-ticket-planning.md;
    }
    // (optionalSet cfg.riper-5.enable {
      ".cursor/rules/riper-5.mdc".source = ./rules/riper-5.mdc;

      # Utility commands for changing RIPER-5 modes
      ".cursor/commands/research.md".text = "ENTER RESEARCH MODE";
      ".cursor/commands/innovate.md".text = "ENTER INNOVATE MODE";
      ".cursor/commands/plan.md".text = "ENTER PLAN MODE";
      ".cursor/commands/execute.md".text = "ENTER EXECUTE MODE";
      ".cursor/commands/review.md".text = "ENTER REVIEW MODE";
    })
    # Setup Serena MCP Cursor rules
    // (optionalSet cfg.serena.enable {
      ".cursor/rules/serena.mdc".source = "${generateSerenaConfigCommand}";
      ".cursor/rules/mcp-tools.mdc".source = ./rules/mcp-tools.mdc;
    })
    # Setup TypeScript Cursor rules
    // (optionalSet cfg.typescript.enable {
      ".cursor/rules/typescript.mdc".source = ./rules/typescript.mdc;
    })
    # END OF home.files
    ;
  };
}
