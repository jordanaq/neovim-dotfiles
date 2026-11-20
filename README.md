# Neovim

Import `default.nix` as a Home Manager module. The dotfiles repository uses
this module through its `user/utils/neovim` submodule.
Set `dotfiles.neovim.minimal = true` on hosts that need only the
Bash, Lua, Markdown, and Nix language servers and basic formatters.
Minimal mode also restricts Tree-sitter parsers to those languages, omits
the LTeX and VimTeX plugins, and disables the Ruby and Python providers.
General-purpose editor plugins remain enabled.
Home Manager installs Neovim plugins from Nixpkgs or pinned upstream sources.
The OpenCode plugin is conditional on `programs.opencode.enable`.
The Hermes Agentic ACP chat interface is enabled on full-profile hosts by default;
set `dotfiles.neovim.agentic.enable = false` to disable it.

Heavily inspired by [Vimjoyer's Neovim guide](https://youtu.be/YZAnJ0rwREA?si=IJYKeHpk4viX1upY).

## Usage documentation

For installed plugins, keybindings, common workflows, language servers, formatting, OpenCode integration, and troubleshooting, see the [Neovim usage guide](docs/USAGE.md).

## What changed

- `blink.cmp` + native `vim.snippet` replace `nvim-cmp`, the cmp sources,
  LuaSnip, and its config file.
- `snacks.nvim` picker/explorer replace Telescope, telescope-fzf-native,
  and Neo-tree. Existing LSP symbol/reference mappings continue using Snacks.
- `mini.nvim` provides text objects, surround, comments, icons, tabline,
  and statusline; standalone Comment, Bufferline, Lualine, and devicons are
  no longer installed. Surround motions: `sa`, `sd`, `sr`; comments: `gc`.
- `lazydev.nvim` replaces `neodev.nvim` and supplies Lua module completions to Blink.
- Native LSP setup enables the servers listed in `lspServers` in `default.nix`.
  Each entry can declare a Nix package and server settings. Omit `package`
  when another module or your project shell provides the executable. Julia
  stays disabled until a working Julia environment is configured.
- Gitsigns, Trouble, Flash, and Conform provide Git hunk tools, a diagnostics
  panel, fast jumps, and explicit formatting.
- Native `vim.hl.on_yank()` replaces the yank-highlighting plugin.
- `lazy.nvim` was unused as a package manager; Home Manager already manages
  plugins.

## Mappings

| Keys | Action |
| --- | --- |
| `<leader>e` | Snacks explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Grep project |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find Neovim help |
| `<leader>s`, `<leader>S`, `gr` | Document symbols, workspace symbols, references (Snacks) |
| `<leader>xx`, `<leader>xb` | Workspace/buffer diagnostics (Trouble) |
| `<leader>j`, `<leader>J` | Flash jump, syntax-aware Flash |
| `]h`, `[h`, `<leader>gp`, `<leader>gs`, `<leader>gr` | Git hunk operations |
| `<leader>cf`, `:Format` | Format buffer using Conform, with LSP fallback |
| `<leader>qs`, `<leader>qS`, `<leader>ql` | Restore the project session, pick a saved session, or restore the last session |
| `aF`/`iF`, `aC`/`iC`, `aP`/`iP` | Around/inside function, class, or parameter using Tree-sitter captures |
| `sa`, `sd`, `sr` | Mini surround add/delete/replace |
| `gc` | Mini comment |
| `<leader>ht` | Toggle Hermes chat (Agentic.nvim) | 
| `<leader>ha` | Add file/visual selection to Hermes context | 
| `<leader>hn`, `<leader>hr` | New / restore Hermes session | 
| `<leader>hd`, `<leader>hD` | Send line / buffer diagnostics to Hermes | 
| `<leader>ot` | Toggle the OpenCode TUI in a Snacks terminal |
| `<C-.>` | Toggle the OpenCode TUI from Normal or Terminal mode (terminal permitting) |
| `<leader>uh` | Toggle inlay hints for the current buffer, when supported |
| `<leader>oa` | Ask OpenCode about the visual selection or cursor |
| `<leader>ox` | Open the OpenCode action picker |
| `go` + motion, visual `go`, or `goo` | Send a range, selection, or line to OpenCode |

Hermes runs through `hermes acp` and uses the existing Hermes skills, memory,
models, and tools. Install Hermes with its ACP extra and verify `hermes acp --check`.
The interactive chat uses a right-side Agentic.nvim panel. OpenCode remains available.

OpenCode's Neovim integration targets the most recently updated session for
the working directory. Use the TUI's `/sessions` and `/models` commands to
browse sessions and models. Save a file before sending it as context.

Blink uses Enter to accept completion and Tab/Shift-Tab for snippet navigation.

Formatting is **manual**. Prettier handles JavaScript, TypeScript, JSON, YAML,
and Markdown. Elixir uses `mix format`, and Svelte uses its language server's
formatter. Nix, Lua, shell, Python, Haskell, C/C++, and Rust keep their
language-specific formatters.
The full profile supplies the configured CLI formatters, including `clang-format`
(via clang-tools), `rustfmt`, and Elixir's `mix`; minimal mode supplies only
Nix, Lua, and shell formatters. Project-local tools may still affect formatting.
Tree-sitter provides highlighting where a parser is available; indentation
uses Neovim's filetype-specific defaults instead of experimental Tree-sitter indentation.

LTeX+ checks `en-US` prose on save. Markdown and other prose formats use the
self-hosted LanguageTool server over Tailscale, which receives the text being
checked. LaTeX, BibTeX, and ConTeXt use the bundled checker locally. Vale
checks style in projects with a `.vale.ini`.

## Deferred decisions

- `obsidian.nvim` is not installed; add it back with a vault/workspace setup
  if needed.
- The current Tree-sitter all-grammars set is preserved for less common
  languages (notably SML). Prune parsers only after checking your workflow.

## Test

From the dotfiles repository root with its submodules initialized:

```sh
nix build '.?submodules=1#homeConfigurations.tsiru.activationPackage' --no-link
home-manager switch --flake '.?submodules=1#tsiru'
nvim +checkhealth
```

Run `hermes acp --check` and open Hermes chat with `<leader>ht` on a full-profile host.
Also run `:checkhealth opencode`, open the TUI with `<leader>ot`, and try
`<leader>oa` on a visual selection.
