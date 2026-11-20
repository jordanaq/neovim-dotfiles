# Neovim usage guide

This is the day-to-day guide for [`jordanaq/neovim-dotfiles`](https://github.com/jordanaq/neovim-dotfiles). It documents **the bindings and features actually configured in this repository**, rather than every command a plugin can provide.

The editor is managed by **NixOS/Home Manager**, not `lazy.nvim` or Mason. Home Manager installs Neovim plugins, language servers, and formatter executables. `default.nix` generates `~/.config/nvim/dotfiles-settings.json`, which the Lua configuration reads at startup.

## Getting started

- **Leader key:** `Space` (`<leader>`); local leader is also `Space`. Press `Space` and wait for **which-key** to show available groups and descriptions.
- **Find a file:** `Space f f`; **search project text:** `Space f g`; **browse files:** `Space e`.
- **Navigate code:** `gd` for definition, `gr` for references, `K` for hover documentation, `Space a` for code actions.
- **Format the current buffer:** `Space c f` or `:Format`. Formatting is **manual**; saving does not invoke Conform.
- **Inspect problems:** `Space x x` for workspace diagnostics or `Space x b` for the current buffer.
- **Open OpenCode (when enabled):** `Space o t` for its terminal, `Space o a` to ask about the cursor/selection.

For example, a typical code-editing loop is: `Space f f` → open file → `gd`/`gr` → make edits → `Space c f` → `]h` to review the next changed Git hunk → `Space g s` to stage that hunk.

> In the binding tables below, `Space` means `<leader>`, and `Ctrl-.` means `<C-.>`. Modes are **Normal** (N), **Visual/Select** (V), **Operator-pending** (O), and **Terminal** (T). Some bindings appear only when a language server or Git integration attaches to the current buffer.

## Keybinding reference

### Finding files, searching, and jumping

| Keys | Modes | Action / when to use it |
| --- | --- | --- |
| `Space e` | N | Open the Snacks file explorer. |
| `Space f f` | N | Find files with Snacks picker. |
| `Space f g` | N | Grep project text with Snacks; `ripgrep` is installed. |
| `Space f b` | N | Switch among open buffers. |
| `Space f h` | N | Search Neovim help topics. |
| `Space j` | N, V, O | Flash jump to a visible match. Useful for rapid cursor movement or as a motion. |
| `Space J` | N, V, O | Flash Tree-sitter-aware syntax selection/jump. |

**Choosing tools:** use `Space f f` when you know a filename, `Space f g` when you know a text fragment, `Space f b` when a file is already open, and `Space e` when you want to explore the directory hierarchy. Flash is for moving *within visible text*, not searching the entire project.

### LSP: navigation, edits, and diagnostics

| Keys | Scope | Action |
| --- | --- | --- |
| `gd` | LSP-attached buffer | Go to definition. |
| `gD` | LSP-attached buffer | Go to declaration. |
| `gI` | LSP-attached buffer | Go to implementation. |
| `Space D` | LSP-attached buffer | Go to type definition. |
| `gr` | LSP-attached buffer | Search references in Snacks picker. |
| `Space s` | LSP-attached buffer | Search document symbols. |
| `Space S` | LSP-attached buffer | Search workspace symbols. |
| `K` | LSP-attached buffer | Hover documentation. |
| `Space r` | LSP-attached buffer | Rename symbol. |
| `Space a` | LSP-attached buffer | Show available code actions. |
| `Space u h` | LSP-attached buffer | Toggle inlay hints **only if** that language server supports them. |
| `gl` | N, global | Open a diagnostic float at the cursor. |
| `Space x x` | N | Toggle Trouble's workspace diagnostics view. |
| `Space x b` | N | Toggle Trouble diagnostics filtered to the current buffer. |

`gr` is **references**; `Space g r` is **reset Git hunk**. These are separate bindings. LSP navigation and refactoring actions require an attached, capable language server; the mappings are created on `LspAttach`.

### Completions and snippets (blink.cmp)

| Keys | Action |
| --- | --- |
| `Enter` | Accept the selected completion (Blink's `enter` preset). |
| `Ctrl-n` | Select next completion item; fall back to Neovim when not applicable. |
| `Ctrl-p` | Select previous completion item; fall back when not applicable. |
| `Tab` | Jump forward through an active snippet; otherwise fall back. |
| `Shift-Tab` | Jump backward through an active snippet; otherwise fall back. |

Blink completion sources are **LazyDev** (Lua), LSP, filesystem paths, snippets, and buffer words. Completion documentation is displayed automatically. Snippet support uses Neovim's native `vim.snippet` rather than LuaSnip. The `Tab` mappings are for **snippet navigation**, not a general-purpose accept-completion shortcut.

### Editing and text objects (mini.nvim)

| Keys | Modes / example | Action |
| --- | --- | --- |
| `sa` | N / V | Add surrounding characters around a motion or selection. |
| `sd` | N | Delete surrounding characters. |
| `sr` | N | Replace surrounding characters. |
| `gc` | N / V | Toggle a comment for a motion or selected text. |
| `gcc` | N | Toggle a comment on the current line. |
| `aF` / `iF` | Text-object context | Around/inside a Tree-sitter **function**. |
| `aC` / `iC` | Text-object context | Around/inside a Tree-sitter **class**. |
| `aP` / `iP` | Text-object context | Around/inside a Tree-sitter **parameter**. |

Examples: `vaF` selects a whole function; `diP` deletes the contents of a parameter text object. These uppercase custom objects depend on applicable Tree-sitter captures and a parser for the file type. The usual built-in Vim text objects (such as `iw`, `aw`, `i(`, and `a{`) remain available.

Examples of Mini surround: `saiw)` surrounds the word under the cursor with parentheses, `sd"` removes enclosing double quotes, and `sr"'` replaces enclosing double quotes with single quotes.

The other active Mini modules are **icons**, **tabline**, and **statusline**. Mini Icons also supplies a compatibility layer for plugins expecting `nvim-web-devicons`. There are no separately configured keybindings for those display modules.

### Git changes (gitsigns.nvim)

| Keys | Action |
| --- | --- |
| `]h` | Next changed Git hunk. |
| `[h` | Previous changed Git hunk. |
| `Space g p` | Preview the current hunk. |
| `Space g s` | Stage the current hunk. |
| `Space g r` | Reset the current hunk's changes. **Destructive:** use carefully. |

These are buffer-local bindings added by Gitsigns when it attaches to a Git-tracked buffer. They operate on **hunks**, not entire files or commits. For whole-repository operations (commits, rebase, etc.), use Git in a terminal. There is no configured Git UI such as Lazygit or Neogit in this repository.

### Formatting (conform.nvim)

| Keys / command | Action |
| --- | --- |
| `Space c f` | Asynchronously format the current buffer. |
| `:Format` | Same action from the command line. |
| `:ConformInfo` | Inspect available configured formatters for the current file type (plugin-provided command). |

Conform tries the configured formatter and uses LSP formatting as a **fallback**. It does not automatically format on save. Check the formatter table below for file types and executables.

### Saved sessions (persistence.nvim)

| Keys | Action |
| --- | --- |
| `Space q s` | Restore the saved session for the current working directory/project. |
| `Space q S` | Pick a saved session. |
| `Space q l` | Restore the most recent session. |

Open Neovim from the intended project directory if you want `Space q s` to restore that project's buffers and layout. Session restoration is not the same as Git state or unsaved file recovery.

### OpenCode (conditional)

These mappings exist **only when** the Home Manager option `programs.opencode.enable` is enabled and the OpenCode Neovim integration is installed.

| Keys | Modes | Action |
| --- | --- | --- |
| `Space o t` | N | Toggle OpenCode's TUI in a right-side Snacks terminal. |
| `Ctrl-.` | N, T | Toggle the TUI (only if your terminal correctly sends this key). |
| `Space o a` | N, V | Ask OpenCode about the cursor or visual selection (`@this`). |
| `Space o x` | N, V | Open the OpenCode action selector. |
| `go` + motion | N | Use OpenCode's range operator on a motion. |
| `go` | V | Send the selected range to OpenCode. |
| `goo` | N | Send the current line to OpenCode. |

Typical workflow: open a file → optionally select some code → `Space o a` → write a request in OpenCode. For a precise region, use a Visual selection or `go` with a Vim motion; use `goo` for one line. The integration targets the **most recently updated OpenCode session in the current working directory**. In the TUI, use `/sessions` and `/models` to browse sessions and models.

**Save files before sending them as context.** For example, the plugin does not guarantee that unsaved edits are represented in external file context. If `Ctrl-.` does nothing in your terminal, use `Space o t` instead. The terminal opens on the **right** and initially does **not** steal focus.

The OpenCode binary, provider credentials, and model definitions are configured **outside** this Neovim repository. This repository configures the editor bridge, not your provider API keys. Check the separate OpenCode configuration when troubleshooting model selection or authentication.

## Installed plugin inventory

Every plugin below is declared in [`default.nix`](../default.nix). Plugin setup files live in [`assets/nvim/plugin/`](../assets/nvim/plugin/), and their settings are largely generated from `default.nix`.

| Plugin | Primary role | How this config uses it |
| --- | --- | --- |
| **catppuccin-nvim** | Colorscheme | Catppuccin **Macchiato**. |
| **blink.cmp** | Completion | LSP/path/snippet/buffer completions; Enter-to-accept. |
| **lazydev.nvim** | Lua development | Lua library awareness as a high-priority Blink source. |
| **nvim-lspconfig** | Language-server configurations | Native `vim.lsp.config`/`vim.lsp.enable`; see LSP section. |
| **mini.nvim** | Core editing/UI | `ai`, `surround`, `comment`, `icons`, `tabline`, `statusline`. |
| **snacks.nvim** | Navigation and UI | File picker, grep, buffer/help pickers, explorer, input, and OpenCode terminal. |
| **gitsigns.nvim** | Git | Changed-hunk navigation, preview, stage, reset. |
| **trouble.nvim** | Diagnostics | Workspace- and buffer-scoped diagnostics panels. |
| **flash.nvim** | Fast movement | Visible-text jumps and syntax-aware selection. |
| **conform.nvim** | Formatting | Explicit `:Format`, with LSP fallback. |
| **noice.nvim** | UI for messages and prompts | Command palette, bottom search, long-message splits, LSP Markdown rendering. |
| **persistence.nvim** | Sessions | Restore current, selected, or last session. |
| **nvim-treesitter** | Syntax trees/highlighting | Starts Tree-sitter for available filetypes/parsers. |
| **nvim-treesitter-textobjects** | Syntax-aware objects | Supplies query captures consumed by Mini.ai. |
| **vim-nix** | Nix editing | Nix filetype/syntax support. |
| **which-key.nvim** | Shortcut discovery | Labels Find, Git, OpenCode, Sessions, UI toggles, Diagnostics groups. |
| **ltex_extra.nvim** | LTeX vocabulary/state | **Full profile only**; persistent dictionaries, disabled rules, false-positive state. |
| **vimtex** | LaTeX editing | **Full profile only**; PDF viewer method set to Zathura (viewer must be installed separately). |
| **opencode.nvim** (`nickjvandyke`) | AI assistant integration | **When `programs.opencode.enable` is true**; pinned upstream commit for OpenCode 2 compatibility. |

**Not installed here:** `lazy.nvim` as a plugin manager, Telescope, Neo-tree, nvim-cmp, LuaSnip, standalone Comment.nvim/Bufferline/Lualine/devicons, `neodev.nvim`, or `obsidian.nvim`. This matters when looking up setup instructions: use the tools above rather than instructions for the replaced plugins.

## Language servers and prose checking

The full profile declares these language servers in [`default.nix`](../default.nix):

| Area | LSP server(s) | Notes |
| --- | --- | --- |
| Shell | `bashls` | Essential: also present in minimal mode. |
| Lua | `lua_ls` | Essential; LazyDev augments Lua completion. |
| Nix | `nil_ls` | Essential. |
| Markdown | `marksman` | Essential. |
| C / C++ | `clangd` | Uses `clang-tools`. |
| Web | `cssls`, `html`, `eslint`, `jsonls`, `ts_ls`, `svelte`, `yamlls` | ESLint working-directory mode is `auto`. |
| Elixir | `elixirls` | Executable supplied externally by the Elixir language module/project environment, not directly by this Neovim module. |
| Haskell | `hls` | Haskell Language Server. |
| Standard ML | `millet` | Invokes `millet-ls`. |
| Python | `pyright` | Python type/analysis support. |
| Rust | `rust_analyzer` | Rust language support. |
| TOML | `taplo` | TOML diagnostics and language features. |
| Writing | `ltex`, `ltex_plus`, `vale_ls` | Prose checking details below. |

The `ltex` entry is based on LTeX+ and handles **LaTeX, BibTeX, and ConTeXt**-related filetypes locally. `ltex_plus` handles prose and markup filetypes such as Markdown, text, Org, RST, MDX, Typst, HTML, and mail. Both use `en-US` and check **on save**. For prose filetypes, `ltex_plus` is configured to use a **self-hosted LanguageTool HTTP server** at `https://tsiru-cloud.tail892cfb.ts.net:8091` over Tailscale; text sent to that service leaves the local editor. Make sure you are connected to the relevant Tailnet and comfortable sending the checked text to that server. LaTeX/BibTeX/ConTeXt use the bundled/local checker rather than that remote URI.

**Vale** only activates in a workspace with a `.vale.ini` project configuration. LTeX Extra stores dictionary/disabled-rule/false-positive state in `.ltex` (full profile), with its initialization check disabled. **Julia LSP is deliberately disabled**: the repository records a nixpkgs SymbolServer/Julia compatibility issue and a future re-enable path.

LSP setup uses **Neovim's native LSP APIs** rather than calling `require('lspconfig').SERVER.setup(...)`. A server is only enabled if it appears in `lspServers` in `default.nix`; providing an executable alone does not enable it. Server executable availability, root detection, and client capabilities still determine whether it attaches to a buffer.

## Formatter reference

Formatting is explicitly requested with `Space c f` / `:Format`.

| Filetypes | Conform formatter | Provisioning |
| --- | --- | --- |
| Nix | `nixfmt` | Bundled in both profiles. |
| Lua | `stylua` | Bundled in both profiles. |
| `sh`, `bash` | `shfmt` | Bundled in both profiles. |
| Python | `ruff_format` | Full profile (`ruff`). |
| Haskell | `fourmolu` | Full profile. |
| C, C++ | `clang_format` | Available through `clang-tools` in the full LSP package set. |
| Rust | `rustfmt` | Full profile. |
| Elixir | `mix` | Full profile's Elixir tooling. |
| JavaScript / JSX, TypeScript / TSX | `prettier` | Full profile. |
| JSON, JSONC, YAML | `prettier` | Full profile. |
| Markdown, MDX | `prettier` | Full profile. |
| Svelte | LSP fallback | No explicit Conform formatter; uses Svelte language server when available/capable. |

**Minimal mode** bundles only `nixfmt`, `stylua`, and `shfmt` as formatters, although any tools supplied independently by your project shell/PATH may still be found. Formatting with an unavailable CLI formatter may fall back to an attached LSP that supports formatting.

## Editor behavior and profiles

### General editing defaults

- **Indentation:** spaces, with `tabstop=2` and `shiftwidth=2` by default; **C/C++ use four spaces** (`tabstop=4`, `shiftwidth=4`). Filetype-specific indentation is enabled.
- **Search:** ignore case unless the search contains uppercase characters (`ignorecase` + `smartcase`).
- **Windows:** splits open to the right/below; `confirm` prompts about unsaved changes when appropriate.
- **UI:** line numbers, permanent sign column, mouse, true-color, and wrapped-line indentation are enabled.
- **Editing:** persistent undo (`undofile`), system clipboard (`unnamedplus`), 6-line vertical scroll context, 4-column horizontal scroll context, and yank highlighting.
- **Tree-sitter:** highlighting starts for available parsers, but Tree-sitter indentation is not explicitly enabled. Standard Vim motions/window commands still work; for example, `Ctrl-w h/j/k/l` moves among splits.

### Full versus minimal mode

Set `dotfiles.neovim.minimal = true` in the importing Home Manager/NixOS configuration for a reduced language-tooling profile. This mode does **not** strip out normal editor navigation/completion/plugin UX.

| Feature | Full profile (default) | Minimal profile |
| --- | --- | --- |
| Language servers | All declared, enabled servers (subject to executable availability) | `bashls`, `lua_ls`, `marksman`, `nil_ls` only |
| Tree-sitter parsers | All grammars provided by nixpkgs' `withAllGrammars` | Bash, Lua, Markdown, Markdown inline, Nix |
| CLI formatters | Full formatter tools as listed above | Nix, Lua, shell tools bundled |
| `ltex_extra.nvim`, `vimtex` | Included | Omitted |
| Python and Ruby Neovim providers | Enabled | Disabled |
| Snacks, Blink, Mini, Git, Trouble, Flash, Conform, etc. | Included | Included |
| OpenCode integration | Conditional on `programs.opencode.enable` | Same condition |

The minimal profile is useful for small/headless machines where keeping only basic language tooling is preferable. Note that `programs.opencode.enable` is **independent** of the minimal switch.

## Configuration layout and changing behavior

| Path | Responsibility |
| --- | --- |
| [`default.nix`](../default.nix) | Home Manager module, plugin list, language servers, formatter packages, shared settings, `minimal` option. |
| [`assets/nvim/init.lua`](../assets/nvim/init.lua) | Apply editor settings, colorscheme, filetypes, yank highlight, C/C++ indentation override. |
| [`assets/nvim/lua/dotfiles/settings.lua`](../assets/nvim/lua/dotfiles/settings.lua) | Read generated `dotfiles-settings.json`. |
| [`assets/nvim/plugin/`](../assets/nvim/plugin/) | Plugin setup and explicit mappings. |
| `~/.config/nvim/dotfiles-settings.json` | **Generated by Nix** from `default.nix`; don't treat it as the source of truth. |

To **change a binding**, edit the relevant `assets/nvim/plugin/*.lua` file. To **add a plugin**, edit `programs.neovim.plugins` in `default.nix` and add its Lua setup if needed. To **change LSP servers, formatter packages, editor settings, or completion sources**, change the corresponding settings in `default.nix`. Rebuild/switch the Home Manager configuration to apply those changes; edits to the generated JSON will be overwritten.

From the parent dotfiles repository, with submodules initialized (the invocation documented by this repo):

```sh
nix build '.?submodules=1#homeConfigurations.tsiru.activationPackage' --no-link
home-manager switch --flake '.?submodules=1#tsiru'
nvim +checkhealth
```

Replace the Home Manager configuration name if using a different host/user. This repository is a **Home Manager module**, not a self-installing Neovim configuration.

## Troubleshooting and discoverability

| Symptom | Check |
| --- | --- |
| Forgot a keybinding | Press `Space` and wait for which-key, or inspect `:map`, `:nmap`, `:vmap`; `:verbose nmap <keys>` reports the definition. |
| `gd`, `gr`, rename, etc. do nothing | Check whether an LSP attached: `:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))`; run `:checkhealth`. Verify the server is enabled in `default.nix` and available on PATH. |
| Completion missing | Verify Blink is loaded, an appropriate source is available, and (for LSP completion) a server attached. Run `:checkhealth`. |
| Formatter doesn't run | Use `:ConformInfo`, verify the executable on PATH, inspect the current filetype (`:set filetype?`), and check whether LSP fallback is available. |
| `Space g s` doesn't work | Check you're editing a Git-tracked buffer and Gitsigns attached; compare `:map <leader>gs` in that buffer. |
| `Space o ...` not mapped | Verify `programs.opencode.enable` and rebuild. Check `:checkhealth opencode`; OpenCode and its provider auth must be configured separately. |
| `Ctrl-.` doesn't toggle OpenCode | Your terminal might not transmit that key distinctly; use `Space o t`. |
| Prose checks aren't working | Save the file (check frequency is **save**); verify LTeX/LTeX+ is attached and the Tailnet LanguageTool endpoint is reachable when applicable. Vale additionally needs `.vale.ini`. |
| Syntax-dependent text objects fail | Verify your filetype and Tree-sitter parser/captures; minimal mode ships fewer parsers. |
| Session restoration finds wrong layout | Start Neovim in the intended project's working directory, then use `Space q s` or choose a session with `Space q S`. |

For a machine-specific problem, compare the active setup with the repository's [`README.md`](../README.md) and inspect the matching file under `assets/nvim/plugin/` before changing plugin defaults.