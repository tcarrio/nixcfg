{ config, lib, ... }:
let
  cfg = config.oxc.ai.cursor;

  optionalSet = predicate: value: if predicate then value else {};
in
{
  options.oxc.ai.cursor = {
    enable = lib.mkEnableOption "Enable Cursor AI";
    riper-5.enable = lib.mkEnableOption "Enable Riper-5 AI";
    serena.enable = lib.mkEnableOption "Enable Serena MCP integration";
    typescript.enable = lib.mkEnableOption "Enable TypeScript Cursor rules";
  };

  config = lib.mkIf cfg.enable {
    home.copy-files =
    # Setup RIPER-5 Cursor files
    (optionalSet cfg.riper-5.enable {
      ".cursor/rules/riper-5.mdc".source = ./rules/riper-5.mdc;

      # Utility commands for changing RIPER-5 modes
      "cursor/commands/research.md".text = "ENTER RESEARCH MODE";
      "cursor/commands/innovate.md".text = "ENTER INNOVATE MODE";
      "cursor/commands/plan.md".text = "ENTER PLAN MODE";
      "cursor/commands/execute.md".text = "ENTER EXECUTE MODE";
      "cursor/commands/review.md".text = "ENTER REVIEW MODE";
    })
    # Setup Serena MCP Cursor rules
    // (optionalSet cfg.serena.enable {
      ".cursor/rules/serena.mdc".source = ./rules/serena.mdc;
    })
    # Setup TypeScript Cursor rules
    // (optionalSet cfg.typescript.enable {
      ".cursor/rules/typescript.mdc".source = ./rules/typescript.mdc;
    })
    # END OF home.files
    ;
  };
}
