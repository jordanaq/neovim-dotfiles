{ config, lib, pkgs, ... }:

let
  readLua = builtins.readFile;
  minimal = config.dotfiles.neovim.minimal;
  opencodeEnabled = config.programs.opencode.enable or false;
  agenticEnabled = config.dotfiles.neovim.agentic.enable;
  essentialServers = [ "bashls" "lua_ls" "marksman" "nil_ls" ];

  # The packaged 1.0.2 release uses the V1 API; upstream main supports OpenCode 2.
  opencodePlugin = pkgs.vimPlugins.opencode-nvim.overrideAttrs {
    version = "unstable-2026-10-30";
    src = pkgs.fetchFromGitHub {
      owner = "nickjvandyke";
      repo = "opencode.nvim";
      rev = "4851ae503585dc5142ad66a98e8952a74e1f7b3a";
      hash = "sha256-Qhn8hGQ/S6SCV0GxsrS8nAPSq0ndwMNaEYhOw0Mv/Pc=";
    };
  };

  # ACP chat is not packaged in nixpkgs yet. Pin the upstream commit so the
  # Git checkout is immutable without adding a second plugin manager.
  agenticPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = "agentic.nvim";
    version = "unstable-2026-11-19";
    src = builtins.fetchGit {
      url = "https://github.com/carlos-algms/agentic.nvim";
      rev = "4750d6ce4298b3018dd67f975a1457afbeeaa09f";
    };
  };

  latexFiletypes = [ "bib" "context" "plaintex" "tex" ];
  englishLtex = {
    checkFrequency = "save";
    language = "en-US";
  };

  # A server must be listed here for Neovim to enable it.
  lspServers = lib.filter
    (server: !minimal || lib.elem server.name essentialServers)
    availableServers;
  availableServers = with pkgs; [
    { name = "bashls"; package = bash-language-server; }
    { name = "clangd"; package = clang-tools; }
    { name = "cssls"; package = vscode-langservers-extracted; }
    # The Elixir language module supplies elixir-ls on PATH.
    { name = "elixirls"; }
    {
      name = "eslint";
      package = vscode-langservers-extracted;
      settings.workingDirectory.mode = "auto";
    }
    { name = "html"; package = vscode-langservers-extracted; }
    { name = "jsonls"; package = vscode-langservers-extracted; }
    { name = "lua_ls"; package = lua-language-server; }
    {
      # ltex_extra recognizes both ltex and ltex_plus for dictionary commands.
      name = "ltex";
      base = "ltex_plus";
      filetypes = latexFiletypes;
      settings.ltex = englishLtex;
    }
    {
      name = "ltex_plus";
      package = ltex-ls-plus;
      filetypes = [
        "asciidoc"
        "gitcommit"
        "html"
        "markdown"
        "org"
        "pandoc"
        "quarto"
        "mail"
        "mdx"
        "rmd"
        "rnoweb"
        "rst"
        "text"
        "typst"
        "xhtml"
      ];
      settings.ltex = englishLtex // {
        languageToolHttpServerUri = "https://tsiru-cloud.tail892cfb.ts.net:8091";
      };
    }
    { name = "hls"; package = haskell-language-server; }
    # SymbolServer 8.0.1 fails to precompile on Julia 1.13.3.
    # Re-enable with julia_112 or once the default Julia build works.
    # { name = "julials"; package = julia_112.withPackages [ "LanguageServer" "StaticLint" "SymbolServer" ]; }
    { name = "marksman"; package = marksman; }
    {
      name = "millet";
      package = millet;
      cmd = [ "millet-ls" ];
    }
    { name = "nil_ls"; package = nil; }
    { name = "pyright"; package = pyright; }
    { name = "rust_analyzer"; package = rust-analyzer; }
    { name = "svelte"; package = svelte-language-server; }
    { name = "taplo"; package = taplo; }
    { name = "ts_ls"; package = typescript-language-server; }
    {
      name = "vale_ls";
      package = vale-ls;
      # Vale needs project rules. Its upstream root marker is .vale.ini.
      workspace_required = true;
      project_config = ".vale.ini";
    }
    { name = "yamlls"; package = yaml-language-server; }
  ];

  settings = {
    editor = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        vimtex_view_method = "zathura";
      };
      options = {
        clipboard = "unnamedplus";
        number = true;
        signcolumn = "yes";
        splitright = true;
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        updatetime = 300;
        termguicolors = true;
        # UFO owns fold ranges; keep folds open on entry.
        foldcolumn = "1";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;
        mouse = "a";
        undofile = true;
        ignorecase = true;
        smartcase = true;
        scrolloff = 6;
        sidescrolloff = 4;
        splitbelow = true;
        breakindent = true;
        confirm = true;
      };
      filetypes.extension = {
        cabal = "cabal";
        fun = "sml";
        hs = "haskell";
        lhs = "lhaskell";
        nix = "nix";
        sig = "sml";
        sml = "sml";
        svelte = "svelte";
        toml = "toml";
      };
      cIndent = {
        filetypes = [ "c" "cpp" ];
        options = {
          tabstop = 4;
          shiftwidth = 4;
          expandtab = true;
        };
      };
      yankHighlight.timeout = 300;
    };

    colorscheme = "catppuccin-macchiato";
    lspServers = map (server: removeAttrs server [ "package" ]) lspServers;
    ltexExtra = {
      init_check = false;
      load_langs = [ "en-US" ];
      path = ".ltex";
    };

    # Inline Markdown rendering for ordinary files and the Hermes chat sidebar.
    renderMarkdown.file_types = [ "markdown" "AgenticChat" ];

    # The ACP provider, layout, and editor mappings are defined in Nix.
    # assets/nvim/plugin/agentic.lua only translates this data into Neovim API calls.
    agentic = {
      provider = "hermes-agent-acp";
      acp_providers."hermes-agent-acp" = {
        name = "Hermes Agent";
        command = "hermes";
        args = [ "acp" ];
      };
      windows = {
        position = "right";
        width = "40%";
      };
    };
    agenticMappings = [
      { lhs = "<leader>ht"; modes = [ "n" "x" ]; action = "toggle"; desc = "Toggle Hermes chat"; }
      { lhs = "<leader>ha"; modes = [ "n" "x" ]; action = "add_selection_or_file_to_context"; desc = "Add file/selection to Hermes"; }
      { lhs = "<leader>hn"; modes = [ "n" ]; action = "new_session"; desc = "New Hermes session"; }
      { lhs = "<leader>hr"; modes = [ "n" ]; action = "restore_session"; desc = "Restore Hermes session"; }
      { lhs = "<leader>hd"; modes = [ "n" ]; action = "add_current_line_diagnostics"; desc = "Send line diagnostics to Hermes"; }
      { lhs = "<leader>hD"; modes = [ "n" ]; action = "add_buffer_diagnostics"; desc = "Send buffer diagnostics to Hermes"; }
    ];
    whichKeyGroups = {
      f = "Find";
      g = "Git";
      o = "OpenCode";
      q = "Sessions";
      u = "UI toggles";
      x = "Diagnostics";
    } // lib.optionalAttrs agenticEnabled { h = "Hermes"; };

    blink = {
      keymap = {
        preset = "enter";
        "<C-n>" = [ "select_next" "fallback" ];
        "<C-p>" = [ "select_prev" "fallback" ];
        "<Tab>" = [ "snippet_forward" "fallback" ];
        "<S-Tab>" = [ "snippet_backward" "fallback" ];
      };
      completion.documentation.auto_show = true;
      snippets.preset = "default";
      sources = {
        default = [ "lazydev" "lsp" "path" "snippets" "buffer" ];
        providers.lazydev = {
          name = "LazyDev";
          module = "lazydev.integrations.blink";
          score_offset = 100;
        };
      };
    };

    mini.modules = [ "icons" "ai" "surround" "comment" "tabline" "statusline" ];
    mini.textobjects = {
      F = { a = "@function.outer"; i = "@function.inner"; };
      C = { a = "@class.outer"; i = "@class.inner"; };
      P = { a = "@parameter.outer"; i = "@parameter.inner"; };
    };

    snacks = {
      input.enabled = true;
      picker = {
        enabled = true;
        # Buffer picker: jump to an existing editor window showing the buffer.
        sources.buffers.jump.reuse_win = true;
      };
      explorer.enabled = true;
    };

    conform.formatters_by_ft = {
      nix = [ "nixfmt" ];
      lua = [ "stylua" ];
      sh = [ "shfmt" ];
      bash = [ "shfmt" ];
      python = [ "ruff_format" ];
      haskell = [ "fourmolu" ];
      c = [ "clang_format" ];
      cpp = [ "clang_format" ];
      rust = [ "rustfmt" ];
      elixir = [ "mix" ];
      javascript = [ "prettier" ];
      javascriptreact = [ "prettier" ];
      typescript = [ "prettier" ];
      typescriptreact = [ "prettier" ];
      json = [ "prettier" ];
      jsonc = [ "prettier" ];
      yaml = [ "prettier" ];
      markdown = [ "prettier" ];
      "markdown.mdx" = [ "prettier" ];
      # Svelte's language server supplies the formatter with Svelte parser support.
    };

    noice = {
      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
      };
      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = false;
        lsp_doc_border = false;
      };
    };
  };
in
{
  options.dotfiles.neovim.minimal = lib.mkEnableOption
    "an essential set of language servers and formatters for headless hosts";

  options.dotfiles.neovim.agentic.enable = lib.mkOption {
    type = lib.types.bool;
    default = !minimal;
    description = "Enable the Hermes ACP chat interface in Neovim (on by default outside minimal mode).";
  };

  config = {
    xdg.configFile."nvim/dotfiles-settings.json".text = builtins.toJSON settings;
    xdg.configFile."nvim/lua/dotfiles/settings.lua".source = ./assets/nvim/lua/dotfiles/settings.lua;

    programs.neovim = {
      enable = true;

      withRuby = !minimal;
      withPython3 = !minimal;

      package = pkgs.neovim-unwrapped;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = (with pkgs; [
        # Editor tools
        curl
        file
        ripgrep

        # CLI formatters used by conform.nvim (opt-in with :Format).
        nixfmt
        stylua
        shfmt
      ]) ++ lib.optionals (!minimal) (with pkgs; [
        ruff
        fourmolu
        prettier
        rustfmt
        beamPackages.elixir
      ]) ++ lib.unique (lib.catAttrs "package" lspServers);

      # Nix manages all plugins; pinned upstream revisions supplement nixpkgs.
      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim

        # Modern LSP completion; native vim.snippet removes the LuaSnip dependency.
        {
          plugin = blink-cmp;
          type = "lua";
          config = readLua ./assets/nvim/plugin/blink.lua;
        }
        {
          plugin = lazydev-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/lazydev.lua;
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = readLua ./assets/nvim/plugin/lsp.lua;
        }
        # Mini replaces Comment.nvim, Bufferline, Lualine and devicons, while
        # also adding surround and richer text objects.
        {
          plugin = mini-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/mini.lua;
        }
        # Snacks replaces Telescope/FZF and Neo-tree with one picker/explorer.
        {
          plugin = snacks-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/snacks.lua;
        }

        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/git.lua;
        }
        {
          plugin = trouble-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/trouble.lua;
        }
        {
          plugin = flash-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/flash.lua;
        }
        {
          plugin = conform-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/format.lua;
        }

      ] ++ lib.optional (!minimal) ltex_extra-nvim ++ lib.optional opencodeEnabled {
        plugin = opencodePlugin;
        type = "lua";
        config = readLua ./assets/nvim/plugin/opencode.lua;
      } ++ lib.optional agenticEnabled {
        plugin = agenticPlugin;
        type = "lua";
        config = readLua ./assets/nvim/plugin/agentic.lua;
      } ++ [
        {
          plugin = noice-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/noice.lua;
        }

        {
          plugin = persistence-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/persistence.lua;
        }

        # Minimal hosts only need parsers for the essential language set.
        {
          plugin = if minimal then nvim-treesitter.withPlugins (parsers: with parsers; [
            bash lua markdown markdown_inline nix
          ]) else nvim-treesitter.withAllGrammars;
          type = "lua";
          config = readLua ./assets/nvim/plugin/treesitter.lua;
        }
        # Query files for mini.ai. Keep the mappings and selection logic in Mini.
        nvim-treesitter-textobjects
        # Syntax-aware folding with indentation fallback.
        promise-async
        {
          plugin = nvim-ufo;
          type = "lua";
          config = readLua ./assets/nvim/plugin/ufo.lua;
        }
        {
          plugin = render-markdown-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/render-markdown.lua;
        }
        vim-nix
      ] ++ lib.optional (!minimal) vimtex ++ [
        {
          plugin = which-key-nvim;
          type = "lua";
          config = readLua ./assets/nvim/plugin/which-key.lua;
        }
      ];

      initLua = readLua ./assets/nvim/init.lua;
    };

    # Self-clearing reminder: delete this entry when the Julia LSP comes back.
    warnings = [
      "${__curPos.file}:${toString __curPos.line}: TODO: the Julia language server is removed from neovim — nixpkgs' SymbolServer 8.0.1 cannot precompile on Julia 1.13 (`KeyError: key :_apply not found`). Re-enable in lspServers with (julia_112.withPackages [ \"LanguageServer\" \"StaticLint\" \"SymbolServer\" ]) — verified building — or plain julia once SymbolServer supports 1.13, then delete this warning."
    ];
  };
}
