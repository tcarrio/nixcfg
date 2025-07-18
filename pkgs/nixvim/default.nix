{ nixvim, pkgs, config ? {}, extraPlugins ? [], extraConfig ? {} }:
let
  baseConfig = import ./config.nix { inherit pkgs; };
  
  # Helper function to deep merge configurations
  mergeConfig = base: override: 
    if builtins.isAttrs base && builtins.isAttrs override then
      base // (builtins.mapAttrs (name: value: 
        if builtins.hasAttr name base then
          mergeConfig base.${name} value
        else
          value
      ) override)
    else
      override;
  
  # Merge base config with user overrides
  finalConfig = mergeConfig baseConfig (config // extraConfig);
  
  # Add extra plugins to the final config
  configWithExtraPlugins = if extraPlugins != [] then
    finalConfig // {
      plugins = (finalConfig.plugins or {}) // (builtins.listToAttrs 
        (map (plugin: { 
          name = plugin.name; 
          value = plugin.config or { enable = true; }; 
        }) extraPlugins));
    }
  else
    finalConfig;

in
nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  inherit pkgs;
  module = { ... }: configWithExtraPlugins;
}