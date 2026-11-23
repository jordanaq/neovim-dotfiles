# Neovim usage guide

This is the day-to-day guide for [`jordanaq/neovim-dotfiles`](https://github.com/jordanaq/neovim-dotfiles). It documents **the bindings and features actually configured in this repository**, rather than every command a plugin can provide.

The editor is managed by **NixOS/Home Manager**, not `lazy.nvim` or Mason. Home Manager installs Neovim plugins, language servers, and formatter executables. `default.nix` generates `~/.config/nvim/dotfiles-settings.json`, which the Lua configuration reads at startup.

## Getting started

- **Leader key:** `<leader>` is mapped to **Space** (`<Space>`); `<localleader>` is also Space. Press `<leader>` and wait for **which-key** to show available groups and descriptions.
- **Find a file:** `<leader>ff`; **search project text:** `<leader>fg`; **browse files:** `<leader>e`.
- **Navigate code:** `gd` for definition, `gr` for references, `K` for hover documentation, `<leader>a` for code actions.
- **Format the current buffer:** `<leader>cf` or `:Format`. Formatting is **manual**; saving does not invoke Conform.
- **Inspect problems:** `<leader>xx` for workspace diagnostics or `<leader>xb` for the current buffer.
- **Open Hermes chat (full profile):** `<leader>ht` for the interactive ACP sidebar, `<leader>ha` to send a file or selection.
- **Open OpenCode (when enabled):** `<leader>ot` for its terminal, `<leader>oa` to ask about the cursor/selection.

For example, a typical code-editing loop is: `<leader>ff` → open file → `gd`/`gr` → make edits → `<leader>cf` → `]h` to review the next changed Git hunk → `<leader>gs` to stage that hunk.

> In all binding tables, `<leader>` represents the configured Space key, and `Ctrl-.` means `<C-.>`. Modes are **Normal** (N), **Visual/Select** (V), **Operator-pending** (O), and **Terminal** (T). Some bindings appear only when a language server or Git integration attaches to the current buffer.

## Keybinding reference

### Finding files, searching, and jumping

| Keys | Modes | Action / when to use it |
| --- | --- | --- |
| `<leader>e` | N | Open the Snacks file explorer. |
| `<leader>ff` | N | Find files with Snacks picker. |
| `<leader>fg` | N | Grep project text with Snacks; `ripgrep` is installed. |
| `<leader>fb` | N | Switch among open buffers. |
| `<leader>bd` | N | Close the current buffer using Snacks.bufdelete without closing the pane. |
| `<leader>fh` | N | Search Neovim help topics. |
| `<leader>j` | N, V, O | Flash jump to a visible match. Useful for rapid cursor movement or as a motion. |
| `<leader>J` | N, V, O | Flash Tree-sitter-aware syntax selection/jump. |

**Choosing tools:** use `<leader>ff` when you know a filename, `<leader>fg` when you know a text fragment, `<leader>fb` when a file is already open, and `<leader>e` when you want to explore the directory hierarchy. Flash is for moving *within visible text*, not searching the entire project.

### LSP: navigation, edits, and diagnostics

| Keys | Scope | Action |
| --- | --- | --- |
| `gd` | LSP-attached buffer | Go to definition. |
| `gD` | LSP-attached buffer | Go to declaration. |
| `gI` | LSP-attached buffer | Go to implementation. |
| `<leader>D` | LSP-attached buffer | Go to type definition. |
| `gr` | LSP-attached buffer | Search references in Snacks picker. |
| `<leader>s` | LSP-attached buffer | Search document symbols. |
| `<leader>S` | LSP-attached buffer | Search workspace symbols. |
| `K` | LSP-attached buffer | Hover documentation. |
| `<leader>r` | LSP-attached buffer | Rename symbol. |
| `<leader>a` | LSP-attached buffer | Show available code actions. |
| `<leader>uh` | LSP-attached buffer | Toggle inlay hints **only if** that language server supports them. |
| `gl` | N, global | Open a diagnostic float at the cursor. |
| `<leader>xx` | N | Toggle Trouble's workspace diagnostics view. |
| `<leader>xb` | N | Toggle Trouble diagnostics filtered to the current buffer. |

`gr` is **references**; `<leader>gr` is **reset Git hunk**. These are separate bindings. LSP navigation and refactoring actions require an attached, capable language server; the mappings are created on `LspAttach`.

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
| `<leader>gp` | Preview the current hunk. |
| `<leader>gs` | Stage the current hunk. |
| `<leader>gr` | Reset the current hunk's changes. **Destructive:** use carefully. |

These are buffer-local bindings added by Gitsigns when it attaches to a Git-tracked buffer. They operate on **hunks**, not entire files or commits. For whole-repository operations (commits, rebase, etc.), use Git in a terminal. There is no configured Git UI such as Lazygit or Neogit in this repository.

### Formatting (conform.nvim)

| Keys / command | Action |
| --- | --- |
| `<leader>cf` | Asynchronously format the current buffer. |
| `:Format` | Same action from the command line. |
| `:ConformInfo` | Inspect available configured formatters for the current file type (plugin-provided command). |

Conform tries the configured formatter and uses LSP formatting as a **fallback**. It does not automatically format on save. Check the formatter table below for file types and executables.

### Saved sessions (persistence.nvim)

| Keys | Action |
| --- | --- |
| `<leader>qs` | Restore the saved session for the current working directory/project. |
| `<leader>qS` | Pick a saved session. |
| `<leader>ql` | Restore the most recent session. |

Open Neovim from the intended project directory if you want `<leader>qs` to restore that project's buffers and layout. Session restoration is not the same as Git state or unsaved file recovery.

### Code folding (nvim-ufo)

UFO provides Tree-sitter-aware code folding with indentation fallback. Files
open with folds expanded; the fold gutter is shown at the left. Folding works
independently of LSP availability. When a Tree-sitter grammar is unavailable,
the indent provider is used instead.

| Keys | Action |
| --- | --- |
| `za` | Toggle the fold under the cursor. |
| `zc` / `zo` | Close/open the fold under the cursor. |
| `zM` / `zR` | Close/open all folds through UFO. |
| `zK` | Preview the folded text under the cursor in a rounded floating window. |
| `zm` / `zr` | Close/open one fold level. |
| `<leader>un` | Hide/show line numbers and the fold gutter in the current pane only. |

`<leader>un` is window-local: it preserves the current pane's number, relative
number, and fold-column settings and restores them on the next toggle. Other
splits are unaffected, and code folding still works while the gutter is hidden.

`K` remains the LSP hover documentation binding; fold previews use `zK`
instead. The plugin is declared in `default.nix` and configured in
`assets/nvim/plugin/ufo.lua`.

### Markdown rendering (render-markdown.nvim)

\`render-markdown.nvim\` decorates Markdown directly inside Neovim, including normal
\`markdown\` files and Hermes responses in Agentic's \`AgenticChat\` sidebar. It
uses the existing Tree-sitter Markdown parsers and Mini icons; neither Obsidian
nor a browser preview is required. Rendering is enabled by default in Normal
mode and gives way to raw Markdown while editing in Insert mode.

- \`:RenderMarkdown toggle\` toggles rendering globally.
- \`:RenderMarkdown buf_toggle\` toggles rendering for the current buffer.
- \`:RenderMarkdown preview\` opens a separate rendered split.

This changes presentation only: \`marksman\` still handles Markdown language
features, and \`:Format\` still formats files using Prettier when available.
The filetype settings live in \`default.nix\`.

### Hermes Agent (Agentic.nvim / ACP)

**Open Hermes chat:** in Normal mode, press `<leader>ht` (**Space**, then **h**,
then **t**). Agentic opens an interactive right-hand sidebar, configured to use
40% of Neovim's width. Type a prompt in its input buffer; `q` in the widget
hides it without stopping the active session. Press `<leader>ht` again to
reopen it. Unlike OpenCode's Snacks terminal, this is a native Neovim chat UI.

Hermes chat is enabled by default in the full profile. Disable it with
`dotfiles.neovim.agentic.enable = false;`; the minimal profile leaves it
disabled unless explicitly enabled. Provider, window layout, and editor
mappings are configured declaratively in `default.nix`; the small
`assets/nvim/plugin/agentic.lua` adapter loads those settings and creates
the mappings. OpenCode remains available separately when enabled.

**Global Hermes mappings** (from normal editor buffers):

| Keys | Modes | Action |
| --- | --- | --- |
| `<leader>ht` (Space h t) | N, V | Toggle the chat sidebar. |
| `<leader>ha` (Space h a) | N, V | Add the current file or a Visual selection to chat context. |
| `<leader>hn` (Space h n) | N | Start a new conversation. |
| `<leader>hr` (Space h r) | N | Restore a conversation supported by the Hermes ACP provider. |
| `<leader>hd` (Space h d) | N | Add diagnostics at the cursor line. |
| `<leader>hD` (Space h Shift-d) | N | Add all diagnostics from the current buffer. |

**Within Agentic's chat/prompt buffers**, the upstream plugin provides these
mappings. Here `<localLeader>` is also Space in this configuration:

| Keys | Where / mode | Action |
| --- | --- | --- |
| `<C-s>` | Prompt, N/V/I | Submit the prompt. |
| `<CR>` | Prompt, N | Submit the prompt; Enter in Insert mode is not this mapping. |
| `<localLeader>m` (Space m) | Widget, N | Select a model if Hermes exposes models over ACP. |
| `<localLeader>l` (Space l) | Widget, N | Select among *currently live* Agentic sessions. |
| `<localLeader>]` / `<localLeader>[` | Widget, N | Cycle to next/previous live session. |
| `<localLeader>D` | Widget, N | Destroy the selected session (different from hiding it). |
| `<localLeader>o` | Widget, N | Open Agentic options. |
| `<localLeader>s` | Widget, N | Switch ACP provider when another provider is installed/configured. |
| `<S-Tab>` | Widget, N/V/I | Switch agent mode *if Hermes advertises modes*. |
| `q` | Widget, N | Hide the sidebar; keep the session running. |
| `d` | Context item, N | Remove the file/selection/diagnostic under the cursor from context. |
| `]]` / `[[` | Chat, N | Jump to next/previous chat heading. |
| `]t` / `[t` | Chat, N | Jump to next/previous tool call. |
| `]c` / `[c` | Diff preview, N | Jump to next/previous changed hunk. |

**Useful prompt syntax and workflows:**

- Type `@filename` in the prompt for workspace file autocomplete; multiple
  references such as `@src/main.rs @Cargo.toml` are supported. Alternatively,
  Visual-select code and use `<leader>ha` before asking for a change.
- Type `/` at the beginning of a prompt to list ACP-advertised slash commands.
  `/new` is provided by Agentic; additional slash commands depend on Hermes.
- Use `<leader>hr` to restore provider-backed history; `Space l` inside the
  widget selects among sessions already live in the current editor. Hiding a
  sidebar does **not** destroy its session. Session restoration and model
  switching depend on the capabilities Hermes advertises over ACP.
- Review tool permissions and proposed file diffs in the chat UI. Diff previews
  use Agentic's default split layout; `]c` and `[c` navigate diff hunks.
  Confirm a proposed edit before accepting it when the agent requests approval.
- To discuss an LSP error, place the cursor on the diagnostic and press
  `<leader>hd`; use `<leader>hD` for the entire file.

**Example coding workflow:** open a project file → Visual-select a function →
`Space h a` → type “Refactor this function while preserving behavior” →
`Ctrl-s` to send → inspect Hermes's proposed changes and approve or reject
tool requests as appropriate. If the sidebar is hidden, `Space h t` reopens it.

**How it connects:** Agentic launches `hermes acp` as an ACP subprocess over
stdio. Hermes supplies its existing configuration, provider credentials,
skills, memory, and available toolsets, rather than borrowing OpenCode's
agent, prompts, or tools. Hermes may use its configured gateway/runtime; you
do not enter a gateway URL or provider API key into this Neovim module.
ACP mode uses an editor-oriented toolset, so not every Hermes CLI or messaging
feature is available.

**Commands and troubleshooting:**

```fish
command -v hermes
hermes acp --check
```

From inside Neovim:

```vim
:checkhealth agentic
:lua require("agentic").toggle()
:lua require("agentic").new_session()
:lua require("agentic").restore_session()
:messages
```

The `:lua` commands are alternatives to the configured keybindings; they are
not separate `:Agentic` Ex commands. If the chat cannot start, check that
Hermes is in Neovim's PATH, its ACP dependency is installed, the plugin is
enabled for the host, and the ACP health check passes. Your Hermes credentials
and skills belong in Hermes's own configuration, **not** in this repo.

### OpenCode (conditional)

These mappings exist **only when** the Home Manager option `programs.opencode.enable` is enabled and the OpenCode Neovim integration is installed.

| Keys | Modes | Action |
| --- | --- | --- |
| `<leader>ot` | N | Toggle OpenCode's TUI in a right-side Snacks terminal. |
| `Ctrl-.` | N, T | Toggle the TUI (only if your terminal correctly sends this key). |
| `<leader>oa` | N, V | Ask OpenCode about the cursor or visual selection (`@this`). |
| `<leader>ox` | N, V | Open the OpenCode action selector. |
| `go` + motion | N | Use OpenCode's range operator on a motion. |
| `go` | V | Send the selected range to OpenCode. |
| `goo` | N | Send the current line to OpenCode. |

Typical workflow: open a file → optionally select some code → `<leader>oa` → write a request in OpenCode. For a precise region, use a Visual selection or `go` with a Vim motion; use `goo` for one line. The integration targets the **most recently updated OpenCode session in the current working directory**. In the TUI, use `/sessions` and `/models` to browse sessions and models.

**Save files before sending them as context.** For example, the plugin does not guarantee that unsaved edits are represented in external file context. If `Ctrl-.` does nothing in your terminal, use `<leader>ot` instead. The terminal opens on the **right** and initially does **not** steal focus.

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
| **render-markdown.nvim** | In-buffer Markdown rendering | Renders ordinary Markdown files and the Agentic chat sidebar. |
| **nvim-treesitter-textobjects** | Syntax-aware objects | Supplies query captures consumed by Mini.ai. |
| **nvim-ufo** | Syntax-aware code folding | Tree-sitter folds, indentation fallback, and folded-code previews. |
| **promise-async** | UFO dependency | Provides UFO's asynchronous operations. |
| **vim-nix** | Nix editing | Nix filetype/syntax support. |
| **which-key.nvim** | Shortcut discovery | Labels Find, Git, OpenCode, Sessions, UI toggles, Diagnostics groups. |
| **ltex_extra.nvim** | LTeX vocabulary/state | **Full profile only**; persistent dictionaries, disabled rules, false-positive state. |
| **vimtex** | LaTeX editing | **Full profile only**; PDF viewer method set to Zathura (viewer must be installed separately). |
| **agentic.nvim** (`carlos-algms`) | Hermes ACP chat | Full profile by default, configurable with `dotfiles.neovim.agentic.enable`; pinned upstream Git revision. |
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

Formatting is explicitly requested with `<leader>cf` / `:Format`.

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
| Hermes Agentic integration | Enabled by default | Disabled by default; explicitly opt in |
| OpenCode integration | Conditional on `programs.opencode.enable` | Same condition |

The minimal profile is useful for small/headless machines where keeping only basic language tooling is preferable. Note that `programs.opencode.enable` is **independent** of the minimal switch.

## Configuration layout and changing behavior

| Path | Responsibility |
| --- | --- |
| [`default.nix`](../default.nix) | Home Manager module, plugin list, Hermes/Agentic provider and keymaps, language servers, formatters, shared settings. |
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
| Forgot a keybinding | Press `<leader>` and wait for which-key, or inspect `:map`, `:nmap`, `:vmap`; `:verbose nmap <keys>` reports the definition. |
| `gd`, `gr`, rename, etc. do nothing | Check whether an LSP attached: `:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))`; run `:checkhealth`. Verify the server is enabled in `default.nix` and available on PATH. |
| Completion missing | Verify Blink is loaded, an appropriate source is available, and (for LSP completion) a server attached. Run `:checkhealth`. |
| Formatter doesn't run | Use `:ConformInfo`, verify the executable on PATH, inspect the current filetype (`:set filetype?`), and check whether LSP fallback is available. |
| `<leader>gs` doesn't work | Check you're editing a Git-tracked buffer and Gitsigns attached; compare `:map <leader>gs` in that buffer. |
| Hermes chat doesn't open | Confirm `dotfiles.neovim.agentic.enable` is on for this host and that `hermes acp --check` succeeds in fish. Verify the Hermes executable is in Neovim's PATH. |
| OpenCode `<leader>o` mappings missing | Verify `programs.opencode.enable` and rebuild. Check `:checkhealth opencode`; OpenCode and its provider auth must be configured separately. |
| `Ctrl-.` doesn't toggle OpenCode | Your terminal might not transmit that key distinctly; use `<leader>ot`. |
| Prose checks aren't working | Save the file (check frequency is **save**); verify LTeX/LTeX+ is attached and the Tailnet LanguageTool endpoint is reachable when applicable. Vale additionally needs `.vale.ini`. |
| Syntax-dependent text objects fail | Verify your filetype and Tree-sitter parser/captures; minimal mode ships fewer parsers. |
| Session restoration finds wrong layout | Start Neovim in the intended project's working directory, then use `<leader>qs` or choose a session with `<leader>qS`. |

For a machine-specific problem, compare the active setup with the repository's [`README.md`](../README.md) and inspect the matching file under `assets/nvim/plugin/` before changing plugin defaults.