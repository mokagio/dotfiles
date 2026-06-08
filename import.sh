#!/usr/bin/env bash

set -euo pipefail

# Unpack a machine-local dotfiles archive (see migrate.sh) into $HOME on a new
# machine.
#
# Existing targets are backed up to <name>.bak-<timestamp> before being
# replaced: a `.local` is machine-specific, so a file already here is real
# config we must not silently clobber.
#
# Usage: import.sh <archive.tar.gz>

# Look up a GPG secret key; wrapped so tests can stub it without a real keyring.
has_gpg_secret_key() { gpg --list-secret-keys "$1" >/dev/null 2>&1; }

archive="${1:-}"
if [[ -z "$archive" ]]; then
  echo "Usage: import.sh <archive.tar.gz>" >&2
  exit 1
fi
if [[ ! -f "$archive" ]]; then
  echo "Archive not found: $archive" >&2
  exit 1
fi

ts=$(date +%Y%m%d-%H%M%S)

entries=()
while IFS= read -r entry; do
  entries+=("$entry")
done < <(tar -tzf "$archive" | grep -v '/$')

if [[ ${#entries[@]} -eq 0 ]]; then
  echo "Archive holds no files: $archive" >&2
  exit 1
fi

backed_up=()
for entry in "${entries[@]}"; do
  target="$HOME/$entry"
  if [[ -e "$target" ]]; then
    mv "$target" "$target.bak-$ts"
    backed_up+=("$entry")
  fi
done

# tar stores .ssh/config.local but not the .ssh dir, so its mode would come from
# the umask. SSH refuses a config in a group/other-accessible dir.
for entry in "${entries[@]}"; do
  if [[ "$entry" == .ssh/* ]]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    break
  fi
done

tar -xzpf "$archive" -C "$HOME"

echo "Imported ${#entries[@]} file(s):"
printf '  %s\n' "${entries[@]}"
if [[ ${#backed_up[@]} -gt 0 ]]; then
  echo "Backed up ${#backed_up[@]} pre-existing file(s) to *.bak-$ts:"
  printf '  %s\n' "${backed_up[@]}"
fi

# .gitconfig.local may name a signing key whose secret half migrate.sh kept out
# of the archive. Warn so signing doesn't silently break.
gitconfig_local="$HOME/.gitconfig.local"
if [[ -f "$gitconfig_local" ]]; then
  signingkey=$(git config --file "$gitconfig_local" user.signingkey 2>/dev/null || true)
  format=$(git config --file "$gitconfig_local" gpg.format 2>/dev/null || true)
  if [[ -n "$signingkey" && "$format" != "ssh" ]] && ! has_gpg_secret_key "$signingkey"; then
    echo >&2
    echo "Reminder: git signs with GPG key $signingkey, which is NOT in this keyring." >&2
    echo "Import it from the private channel you exported it to:" >&2
    echo "  gpg --import gpg-secret-keys.asc" >&2
    echo "  gpg --import-ownertrust gpg-ownertrust.txt" >&2
  fi
fi
