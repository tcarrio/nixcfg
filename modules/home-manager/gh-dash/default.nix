{ config, lib, ... }:
let
  ghCfg = config.oxc.github;
  cfg = ghCfg.dash;

  presetFiles = {
    eearomatics = import ./presets/eearomatics.nix;
    open-feature = import ./presets/open-feature.nix;
    personal = import ./presets/personal.nix;
    skillshare = import ./presets/skillshare.nix;
  };

  loadedPresets = map (name: presetFiles.${name}) cfg.presets;

  mergedSections = {
    prSections = lib.concatMap (p: p.prSections or [ ]) loadedPresets;
    issuesSections = lib.concatMap (p: p.issuesSections or [ ]) loadedPresets;
  };

  defaultConfig = {
    defaults = {
      view = "prs";
      prsLimit = 20;
      issuesLimit = 20;
      preview = {
        open = true;
        width = 70;
      };
    };
    pager = {
      diff = "delta";
    };
  };

  finalConfig = lib.recursiveUpdate (defaultConfig // mergedSections) cfg.extraConfig;
in
{
  options.oxc.github.dash = {
    presets = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames presetFiles));
      default = [ ];
      description = "List of gh-dash presets to compose. Sections are concatenated in order.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra gh-dash configuration merged on top of presets (keybindings, theme, repoPaths, etc.)";
    };

    generatedConfig = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = finalConfig;
      description = "The fully merged gh-dash configuration (read-only).";
    };
  };

  config = lib.mkIf (ghCfg.enable && cfg.enable) {
    home.packages = [
      cfg.package
    ];

    xdg.configFile."gh-dash/config.yml" = lib.mkIf (cfg.enable && cfg.presets != [ ]) {
      text = lib.generators.toYAML { } cfg.generatedConfig;
    };
  };
}
