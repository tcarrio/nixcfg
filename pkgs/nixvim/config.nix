{
  # Leader keys
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  # Basic vim options
  opts = {
    number = true;
    hlsearch = false;
    ignorecase = true;
    smartcase = true;
    mouse = "a";
    clipboard = "unnamedplus";
    breakindent = true;
    undofile = true;
    signcolumn = "yes";
    updatetime = 250;
    timeoutlen = 300;
    completeopt = "menuone,noselect";
    termguicolors = true;
  };

  # Colorscheme
  colorschemes.onedark = {
    enable = true;
  };

  # Essential plugins
  plugins = {
    # Status line
    lualine = {
      enable = true;
    };
    
    # File explorer
    nvim-tree = {
      enable = true;
    };
    
    # Terminal
    toggleterm = {
      enable = true;
    };
    
    # Fuzzy finder
    telescope = {
      enable = true;
      extensions = {
        fzf-native = {
          enable = true;
        };
      };
    };
    
    # Treesitter
    treesitter = {
      enable = true;
    };
    
    # Git integration
    fugitive.enable = true;
    gitsigns = {
      enable = true;
    };
    
    # Comments
    comment.enable = true;
    
    # Auto-detect indentation
    sleuth.enable = true;
    
    # LSP
    lsp = {
      enable = true;
      servers = {
        lua-ls.enable = true;
        nil-ls.enable = true;
      };
    };
    
    # Autocompletion
    cmp = {
      enable = true;
      autoEnableSources = true;
    };
    
    # Snippets
    luasnip = {
      enable = true;
    };
  };
}