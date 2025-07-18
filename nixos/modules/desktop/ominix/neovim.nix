# Neovim configuration using nixvim package
{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.ominix.enable {
    # Install nixvim system-wide and set as default editor
    environment.systemPackages = with pkgs; [
      nixvim
    ];
    
    # Set nixvim as the default editor
    environment.variables = {
      EDITOR = "${pkgs.nixvim}/bin/nvim";
      VISUAL = "${pkgs.nixvim}/bin/nvim";
    };
    
    # Enable neovim system program (for any system integrations)
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
