{ pkgs }: {
  # Leader keys
  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  # Basic vim options
  opts = {
    # Line numbers
    number = true;
    
    # Search settings
    hlsearch = false;
    ignorecase = true;
    smartcase = true;
    
    # Mouse and clipboard
    mouse = "a";
    clipboard = "unnamedplus";
    
    # Indentation
    breakindent = true;
    
    # Undo
    undofile = true;
    
    # Sign column
    signcolumn = "yes";
    
    # Update time
    updatetime = 250;
    timeoutlen = 300;
    
    # Completion
    completeopt = "menuone,noselect";
    
    # Colors
    termguicolors = true;
  };


  # Key mappings based on init.lua
  keymaps = [
    # Disable Space in normal and visual mode
    {
      mode = ["n" "v"];
      key = "<Space>";
      action = "<Nop>";
      options.silent = true;
    }
    
    # Better movement with word wrap
    {
      mode = "n";
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        expr = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        expr = true;
        silent = true;
      };
    }
    
    # Telescope mappings
    {
      mode = "n";
      key = "<leader>?";
      action = "<cmd>Telescope oldfiles<cr>";
      options.desc = "[?] Find recently opened files";
    }
    {
      mode = "n";
      key = "<leader><space>";
      action = "<cmd>Telescope buffers<cr>";
      options.desc = "[ ] Find existing buffers";
    }
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
      options.desc = "[/] Fuzzily search in current buffer";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>Telescope git_files<cr>";
      options.desc = "Search [G]it [F]iles";
    }
    {
      mode = "n";
      key = "<leader>sf";
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "[S]earch [F]iles";
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<cmd>Telescope help_tags<cr>";
      options.desc = "[S]earch [H]elp";
    }
    {
      mode = "n";
      key = "<leader>sw";
      action = "<cmd>Telescope grep_string<cr>";
      options.desc = "[S]earch current [W]ord";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "[S]earch by [G]rep";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>Telescope diagnostics<cr>";
      options.desc = "[S]earch [D]iagnostics";
    }
    {
      mode = "n";
      key = "<leader>sr";
      action = "<cmd>Telescope resume<cr>";
      options.desc = "[S]earch [R]esume";
    }
    
    # File explorer toggle
    {
      mode = "";
      key = "<C-B>";
      action = "<cmd>NvimTreeToggle<cr>";
    }
    
    # Terminal toggle
    {
      mode = "";
      key = "<C-J>";
      action = "<cmd>ToggleTerm<cr>";
    }
    {
      mode = "t";
      key = "<C-j>";
      action = "<cmd>ToggleTerm<cr>";
    }
    
    # Diagnostic navigation
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
      options.desc = "Go to previous diagnostic message";
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
      options.desc = "Go to next diagnostic message";
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options.desc = "Open floating diagnostic message";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>lua vim.diagnostic.setloclist()<cr>";
      options.desc = "Open diagnostics list";
    }
  ];

  # Autocommands for highlight on yank
  autoCmd = [
    {
      event = ["TextYankPost"];
      pattern = "*";
      callback.__raw = ''
        function()
          vim.highlight.on_yank()
        end
      '';
      desc = "Highlight on yank";
    }
  ];

  # Colorscheme
  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "storm"; # Available: storm, moon, night, day
      transparent = false;
      terminal_colors = true;
      styles = {
        comments = { italic = true; };
        keywords = { italic = true; };
        functions = {};
        variables = {};
        sidebars = "dark";
        floats = "dark";
      };
    };
  };

  # Plugins configuration based on init.lua
  plugins = {
    # Web dev icons (required by other plugins)
    web-devicons.enable = true;
    
    # Status line
    lualine = {
      enable = true;
      settings = {
        options = {
          icons_enabled = false;
          component_separators = "|";
          section_separators = "";
        };
      };
    };
    
    # File explorer
    nvim-tree = {
      enable = true;
      autoClose = false;
      openOnSetup = false;
      hijackNetrw = true;
    };
    
    # Terminal
    toggleterm = {
      enable = true;
    };
    
    # Fuzzy finder
    telescope = {
      enable = true;
      settings = {
        defaults = {
          mappings = {
            i = {
              "<C-u>" = false;
              "<C-d>" = false;
            };
          };
        };
      };
      extensions = {
        fzf-native = {
          enable = true;
        };
      };
    };
    
    # Treesitter
    treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "go"
          "json"
          "lua"
          "nix"
          "php"
          "python"
          "rust"
          "tsx"
          "javascript"
          "typescript"
          "vimdoc"
          "vim"
          "bash"
        ];
        auto_install = false;
        highlight = {
          enable = true;
        };
        indent = {
          enable = true;
        };
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<c-space>";
            node_incremental = "<c-space>";
            scope_incremental = "<c-s>";
            node_decremental = "<M-space>";
          };
        };
      };
    };
    
    # Treesitter textobjects
    treesitter-textobjects = {
      enable = true;
    };
    
    # Git integration
    fugitive.enable = true;
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = { text = "+"; };
          change = { text = "~"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          changedelete = { text = "~"; };
        };
        on_attach.__raw = ''
          function(bufnr)
            local gs = package.loaded.gitsigns
            
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            
            -- Navigation
            map({'n', 'v'}, ']c', function()
              if vim.wo.diff then
                return ']c'
              end
              vim.schedule(function()
                gs.next_hunk()
              end)
              return '<Ignore>'
            end, {expr=true, desc = 'Jump to next hunk'})
            
            map({'n', 'v'}, '[c', function()
              if vim.wo.diff then
                return '[c'
              end
              vim.schedule(function()
                gs.prev_hunk()
              end)
              return '<Ignore>'
            end, {expr=true, desc = 'Jump to previous hunk'})
            
            -- Actions
            map('n', '<leader>hp', gs.preview_hunk, {desc = 'Preview git hunk'})
          end
        '';
      };
    };
    
    # Which key
    which-key = {
      enable = true;
      settings = {
        spec = [
          { __unkeyed-1 = "<leader>c"; group = "[C]ode"; }
          { __unkeyed-1 = "<leader>d"; group = "[D]ocument"; }
          { __unkeyed-1 = "<leader>g"; group = "[G]it"; }
          { __unkeyed-1 = "<leader>h"; group = "More git"; }
          { __unkeyed-1 = "<leader>r"; group = "[R]ename"; }
          { __unkeyed-1 = "<leader>s"; group = "[S]earch"; }
          { __unkeyed-1 = "<leader>w"; group = "[W]orkspace"; }
        ];
      };
    };
    
    # Comments
    comment.enable = true;
    
    # Indentation guides
    indent-blankline.enable = true;
    
    # Auto-detect indentation
    sleuth.enable = true;
    
    # Fidget for LSP progress
    fidget = {
      enable = true;
    };
    
    # LSP
    lsp = {
      enable = true;
      servers = {
        lua_ls = {
          enable = true;
          settings = {
            Lua = {
              workspace = { checkThirdParty = false; };
              telemetry = { enable = false; };
            };
          };
        };
        nil_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        ts_ls.enable = true;
      };
    };
    
    
    # Autocompletion
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        snippet = {
          expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete({})";
          "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif require('luasnip').expand_or_locally_jumpable() then
                require('luasnip').expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif require('luasnip').locally_jumpable(-1) then
                require('luasnip').jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
        ];
      };
    };
    
    # Snippets
    luasnip = {
      enable = true;
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
      fromVscode = [
        {
          lazyLoad = true;
        }
      ];
    };
  };
}