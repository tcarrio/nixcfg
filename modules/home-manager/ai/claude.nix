{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.ai.claude;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  bundledAgents =
    if builtins.pathExists ./agents then
      lib.filterAttrs (_: type: type == "regular") (builtins.readDir ./agents)
    else
      { };

  enabledAgents = lib.filterAttrs (_: a: a.enable) cfg.agents;
  enabledPlugins = lib.filterAttrs (_: p: p.enable) cfg.plugins;

  resolvableAgents = lib.filterAttrs (_: a: a.source != null || a.text != null) enabledAgents;

  hasDeprecatedPlugins = enabledPlugins != { };

  claudeExe = "${config.programs.claude-code.package}/bin/claude";

  pluginInstallScript = lib.concatMapStringsSep "\n" (pluginRef: ''
    ${claudeExe} plugin install "${pluginRef}"
  '') cfg.pluginsToInstall;
in
{
  options.oxc.ai.claude = {
    enable = mkEnableOption "Claude Code home-manager integration";

    agents = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "agent ${name}";
              source = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to the agent .md file. Mutually exclusive with text.";
              };
              text = mkOption {
                type = types.nullOr types.lines;
                default = null;
                description = "Inline agent definition text. Mutually exclusive with source.";
              };
            };
          }
        )
      );
      default = { };
      description = ''
        Agent definitions installed to ~/.claude/agents/<name>.md.
        Bundled agents (modules/home-manager/ai/agents/) carry a default
        source; anything else requires an explicit source or text.
      '';
    };

    pluginsToInstall = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Plugins to install via `claude plugin add install` during HM activation.
        Marketplaces must be declared in oxc.ai.claude.marketplaces (fetched by Nix,
        symlinked to ~/.claude/marketplaces/known_marketplaces/ — no SSH at activation).
        Format: "<marketplace>@<plugin-name>"
        Example: [ "superpowers@superpowers" "anthropics@caveman" ]
      '';
    };

    plugins = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "plugin ${name}";
              source = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = ''
                  DEPRECATED: Use pluginsToInstall with marketplaces instead.
                  Path to the plugin directory for direct installation.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = ''
        DEPRECATED: Use pluginsToInstall + marketplaces instead.
        Plugin directories installed to ~/.claude/plugins/<name>/.
        Each source must be a directory with a valid Claude Code plugin manifest.
      '';
    };

    # TODO: settings.json management
    # Claude Code writes ~/.claude/settings.json at runtime, making declarative
    # home-manager management conflict-prone (HM symlinks are read-only; Claude
    # Code will fail to update the file). Until a merge/overlay strategy is
    # implemented (e.g. activation script that deep-merges a Nix-generated
    # fragment into an existing writable copy), settings.json-dependent features
    # such as statusline config, marketplace registrations, and keybindings are
    # not supported here. Manage them manually or via the Claude Code UI.
  };

  config = mkIf cfg.enable {
    oxc.ai.claude.agents = lib.mapAttrs' (
      filename: _:
      let
        name = lib.removeSuffix ".md" filename;
      in
      lib.nameValuePair name {
        source = mkDefault (./agents + "/${filename}");
      }
    ) bundledAgents;

    warnings = lib.optionals hasDeprecatedPlugins [
      ''
        oxc.ai.claude.plugins is DEPRECATED and won't work with Claude Desktop.
        Use pluginsToInstall + marketplaces instead.

        Migration: Replace source-based plugin configs with:
          oxc.ai.claude.marketplaces.<name> = "https://...";
          oxc.ai.claude.pluginsToInstall = [ "<marketplace>@<name>" ];
      ''
    ];

    assertions = lib.concatLists (
      lib.mapAttrsToList (name: agent: [
        {
          assertion = agent.source != null || agent.text != null;
          message = "oxc.ai.claude.agents.${name} is enabled but has neither source nor text.";
        }
        {
          assertion = !(agent.source != null && agent.text != null);
          message = "oxc.ai.claude.agents.${name}: source and text are mutually exclusive; set one or the other.";
        }
      ]) enabledAgents
    );

    home.activation.claudePluginInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.optionalString (cfg.pluginsToInstall != [ ]) pluginInstallScript
    );

    home.file = lib.mapAttrs' (
      name: agent:
      lib.nameValuePair ".claude/agents/${name}.md" (
        if agent.source != null then { inherit (agent) source; } else { inherit (agent) text; }
      )
    ) resolvableAgents;
  };
}
