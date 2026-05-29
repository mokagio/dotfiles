# shellcheck shell=bash
#
# Single source of truth for the symlinks the dotfiles manage. emit_links
# walks every (source, destination) pair and calls `$act "$source" "$dest"`,
# so setup.sh can create them and dotfiles-doctor can check them against the
# same list.

emit_links() {
  local act=$1 d=$2
  local dot f rule rule_name skill skill_name

  for dot in editorconfig gemrc gitconfig gitignore ghci ideavimrc lldbinit \
             liftoffrc tigrc vimrc vimrc.zettelkasten vimrc.plugs xvimrc \
             zshrc zshenv zshprompt; do
    "$act" "$d/$dot" "$HOME/.$dot"
  done

  "$act" "$d/vim/spell/custom-spell.utf-8.add" "$HOME/.vim/spell/custom-spell.utf-8.add"
  "$act" "$d/neovim_init.vim" "$HOME/.config/nvim/init.vim"
  "$act" "$d/nvim/lsp" "$HOME/.config/nvim/lsp"
  "$act" "$d/hammerspoon_init.lua" "$HOME/.hammerspoon/init.lua"

  # mise — idiomatic_version_file_enable_tools = ["ruby"] lets a repo's
  # .ruby-version win over the global pin.
  "$act" "$d/mise/global-config.toml" "$HOME/.config/mise/config.toml"

  "$act" "$d/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

  for f in claude/settings.json claude/CLAUDE.md claude/statusline.sh; do
    "$act" "$d/$f" "$HOME/.$f"
  done

  # AGENTS.md at the conventional home location and the XDG location so the
  # various agent tools all resolve the same file.
  "$act" "$d/agents/AGENTS.md" "$HOME/AGENTS.md"
  "$act" "$d/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
  "$act" "$d/agents/AGENTS.md" "$HOME/.config/agents/AGENTS.md"

  # Guard each glob with -e so an empty match is skipped, not passed through
  # as a literal `*.md` / `*/`.
  for rule in "$d"/agents/rules/*.md; do
    [[ -e "$rule" ]] || continue
    rule_name=$(basename "$rule")
    "$act" "$rule" "$HOME/.config/agents/rules/$rule_name"
    "$act" "$rule" "$HOME/.claude/rules/$rule_name"
  done

  "$act" "$d/claude/hooks" "$HOME/.claude/hooks"
  "$act" "$d/agents/skills" "$HOME/.agents/skills"

  # Per-skill symlinks so Claude-only skills can coexist with the shared set.
  for skill in "$d"/agents/skills/*/; do
    [[ -e "$skill" ]] || continue
    skill_name=$(basename "$skill")
    "$act" "$skill" "$HOME/.claude/skills/$skill_name"
  done
  for skill in "$d"/claude/skills/*/; do
    [[ -e "$skill" ]] || continue
    skill_name=$(basename "$skill")
    "$act" "$skill" "$HOME/.claude/skills/$skill_name"
  done
}
