#!/usr/bin/env bash

set -euo pipefail

# Bundle the machine-local dotfiles — the untracked `*.local` files that the
# tracked configs import — into one archive to carry to a new machine.
#
# Symlinks are dereferenced (`tar -h`): a `.local` may point into a private
# repo whose path won't exist on the target, so we archive the real bytes
# rather than a link that would dangle.
#
# Usage: migrate.sh [output-dir]   (defaults to the current directory)

LOCAL_FILES=(
  .gitconfig.local
  .zshrc.local
  .zshenv.local
  .ssh/config.local
)

out_dir="${1:-$PWD}"

present=()
for f in "${LOCAL_FILES[@]}"; do
  [[ -e "$HOME/$f" ]] && present+=("$f")
done

if [[ ${#present[@]} -eq 0 ]]; then
  echo "No machine-local dotfiles found under $HOME; nothing to migrate." >&2
  exit 1
fi

mkdir -p "$out_dir"
archive="$out_dir/dotfiles-local-$(date +%Y%m%d-%H%M%S).tar.gz"

tar -hczf "$archive" -C "$HOME" "${present[@]}"

echo "Archived ${#present[@]} file(s):"
printf '  %s\n' "${present[@]}"
echo "$archive"
