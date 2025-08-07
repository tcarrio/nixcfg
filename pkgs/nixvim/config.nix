{ pkgs, allowUnfree ? true }:
let
  pager = "${pkgs.bat}/bin/bat --style=plain --paging=always";
  batTheme = "base16";

  env = {
    # Use bat as git pager in Neovim terminals (disable delta)
    GIT_PAGER = pager;
    BAT_THEME = batTheme;
  };

  setup.tabby = ''
    local theme = {
      fill = 'TabLineFill',
      -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
      head = 'TabLine',
      current_tab = 'TabLineSel',
      tab = 'TabLine',
      win = 'TabLine',
      tail = 'TabLine',
    }
    require('tabby').setup({
      line = function(line)
        return {
          {
            { '  ', hl = theme.head },
            line.sep('', theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep('', hl, theme.fill),
              tab.is_current() and '' or '󰆣',
              tab.number(),
              tab.name(),
              tab.close_btn(''),
              line.sep('', hl, theme.fill),
              hl = hl,
              margin = ' ',
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep('', theme.win, theme.fill),
              win.is_current() and '' or '',
              win.buf_name(),
              line.sep('', theme.win, theme.fill),
              hl = theme.win,
              margin = ' ',
            }
          end),
          {
            line.sep('', theme.tail, theme.fill),
            { '  ', hl = theme.tail },
          },
          hl = theme.fill,
        }
      end,
      -- option = {}, -- setup modules' option,
    })

    -- Always show the tab line
    vim.o.showtabline = 2
  '';

  setup.mini-move = ''
    -- Configure mini-move plugin
    require('mini.move').setup()
  '';

  setup.navigator = ''
    -- Configure the navigator.lua plugin
    require('navigator').setup()
  '';

  setup.colorscheme = ''
    -- Force colorscheme application
    vim.cmd('colorscheme tokyonight-night')
  '';

  setup.term-env = ''
    -- Also set when opening terminals to ensure it's available
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function()
        vim.fn.setenv("GIT_PAGER", "${pager}")
        vim.fn.setenv("BAT_THEME", "${batTheme}")
      end,
    })
  '';

  lspServers = {
    # Lua support
    lua_ls = {
      enable = true;
      settings = {
        Lua = {
          workspace = { checkThirdParty = false; };
          telemetry = { enable = false; };
        };
      };
    };

    # Nix support
    nil_ls.enable = true;
    nixd.enable = true;

    # Rust support
    rust_analyzer = {
      enable = true;
      installCargo = false;
      installRustc = false;
    };

    # Web dev support
    ts_ls.enable = true;
    html.enable = true;
    tailwindcss.enable = true;

    # PHP support
    phan.enable = true;
    phpactor.enable = true;

    # Python support
    ruff.enable = true;

    # Postgres support
    postgres_lsp.enable = true;

    # JSON / YAML
    jsonls.enable = true;
    yamlls.enable = true;

    # Markdown editing
    markdown_oxide.enable = true;

    # Container tooling
    dockerls.enable = true;
    docker_compose_language_service.enable = true;

    # Some useful workstation support
    ansiblels.enable = true;
    jqls.enable = true;

    # IaC
    terraformls.enable = true;

    # You never know when you might need Go
    gopls.enable = true;

    # Bazel / Starlark
    starlark_rust.enable = true;
  };
in rec {
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

    # Language server interactions
    {
      mode = "n";
      key = "<leader>lc";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    }
  ];


  # Colorscheme
  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night"; # Available: storm, moon, night, day
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

  inherit env;

  # Packages to include with the Neovim derivation
  extraPackages = with pkgs; [
    bat
    nerdfonts
    ripgrep
  ];

  # Plugins that are not directly supported via the plugins module
  extraPlugins = with pkgs.vimPlugins; [
    tabby-nvim
    mini-move
    Navigator-nvim
  ];

  # Extra configuration to ensure colorscheme loads
  extraConfigLua = ''
    -- Load all extraPlugins manually
    ${setup.tabby}
    ${setup.mini-move}
    ${setup.navigator}
    ${setup.colorscheme}
    ${setup.term-env}
  '';

  # Plugins configuration based on init.lua
  plugins = {
    # Web dev icons (required by other plugins)
    web-devicons.enable = true;

    # Landing page
    dashboard.enable = true;
    
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

    # NOTE: Tab plugin 'tabby' is configured in extraPlugins
    
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

    # Comment utilities
    todo-comments.enable = true;
    
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
    fugitive.enable = false;
    neogit.enable = true;
    git-conflict.enable = true;
    gitblame.enable = true;
    gitmessenger.enable = true;
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
      servers = lspServers;
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
          "<C-Space>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.mapping.complete({})
              elseif require('luasnip').locally_jumpable(-1) then
                require('luasnip').expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
        };
        sources = []
          ++ (map (name: { inherit name; }) (builtins.attrNames lspServers))
          ++ [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
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

  } // pkgs.lib.optionalAttrs allowUnfree {
    # Claude Code AI assistant (unfree license)
    claude-code.enable = false;
  };
}
