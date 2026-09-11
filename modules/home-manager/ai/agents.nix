{
  config,
  lib,
  ...
}:
let
  cfg = config.oxc.agents;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  # Skills bundled with this repository: every directory under ./skills is
  # a defined skill whose source defaults to its contents. Consumers enable
  # by name — only defined skills can be enabled this way.
  bundledSkills =
    if builtins.pathExists ./skills then
      lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills)
    else
      { };

  enabledSkills = lib.filterAttrs (_: skill: skill.enable) cfg.skills;

  # Enabled skills with a resolvable source; sourceless ones are dropped
  # here and reported through assertions instead.
  mountableSkills = lib.filterAttrs (_: skill: skill.source != null) enabledSkills;
in
{
  options.oxc.agents = {
    skillRoots = mkOption {
      type = types.listOf types.str;
      default = [ ".claude/skills" ];
      description = ''
        Home-relative agent skill root directories. Every enabled skill is
        mounted as <root>/<skill-name>, making the same skill installable
        for any SKILL.md-compatible agent: ".claude/skills" (Claude Code,
        also scanned by OpenCode), ".codex/skills" (Codex),
        ".config/opencode/skills" (OpenCode), ".agents/skills"
        (tool-agnostic).
      '';
    };

    skills = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "the ${name} agent skill";
              source = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Skill source: a directory containing SKILL.md. Defaults to the bundled copy for skills shipped with nixcfg.";
              };
            };
          }
        )
      );
      default = { };
      description = ''
        Agent skills in the open SKILL.md format (a directory with a
        SKILL.md manifest). Only defined skills can be enabled: bundled
        skills (modules/home-manager/ai/skills) carry a default source,
        anything else requires an explicit source.
      '';
    };
  };

  config = {
    # Definitions for skills bundled with this repository: the source is
    # available without enabling anything, so consumers only set enable.
    oxc.agents.skills = lib.mapAttrs (name: _: {
      source = mkDefault (./skills + "/${name}");
    }) bundledSkills;

    assertions = lib.concatLists (
      lib.mapAttrsToList (name: skill: [
        {
          assertion = skill.source != null;
          message = "oxc.agents.skills.${name} is enabled but has no source — it is not bundled with nixcfg; set an explicit source or disable it.";
        }
        {
          assertion = skill.source == null || builtins.pathExists skill.source;
          message = "oxc.agents.skills.${name}.source (${toString skill.source}) does not exist — untracked files are invisible to git flakes; stage or commit the skill directory.";
        }
      ]) enabledSkills
    );

    home.file = mkIf (mountableSkills != { }) (
      lib.listToAttrs (
        lib.concatMap (
          root:
          lib.mapAttrsToList (name: skill: {
            name = "${root}/${name}";
            value = {
              inherit (skill) source;
            };
          }) mountableSkills
        ) cfg.skillRoots
      )
    );
  };
}
