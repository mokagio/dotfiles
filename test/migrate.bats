#!/usr/bin/env bats

SCRIPT_DIR=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)
SCRIPT="$SCRIPT_DIR/migrate.sh"

setup() {
  export TMP_ROOT
  TMP_ROOT=$(mktemp -d)
  export HOME="$TMP_ROOT/home"
  mkdir -p "$HOME"
  export OUT="$TMP_ROOT/out"
}

teardown() {
  rm -rf "$TMP_ROOT"
}

@test "archives present local files and skips absent ones" {
  echo gitlocal > "$HOME/.gitconfig.local"
  echo zshrclocal > "$HOME/.zshrc.local"
  # .zshenv.local deliberately absent

  run "$SCRIPT" "$OUT"
  [ "$status" -eq 0 ]

  archive="${lines[${#lines[@]} - 1]}"
  [ -f "$archive" ]

  entries=$(tar -tzf "$archive" | sort)
  [ "$entries" = $'.gitconfig.local\n.zshrc.local' ]
}

@test "dereferences symlinked local files so the archive holds real bytes" {
  echo REAL > "$TMP_ROOT/private-repo-gitconfig"
  ln -s "$TMP_ROOT/private-repo-gitconfig" "$HOME/.gitconfig.local"

  run "$SCRIPT" "$OUT"
  [ "$status" -eq 0 ]
  archive="${lines[${#lines[@]} - 1]}"

  extract="$TMP_ROOT/extract"
  mkdir -p "$extract"
  tar -xzf "$archive" -C "$extract"

  # A regular file with the real content, not a symlink that would dangle
  # once the private repo path is gone on the target machine.
  [ -f "$extract/.gitconfig.local" ]
  [ ! -L "$extract/.gitconfig.local" ]
  [ "$(cat "$extract/.gitconfig.local")" = REAL ]
}

@test "no local files: exits non-zero with a message" {
  run "$SCRIPT" "$OUT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"nothing to migrate"* ]]
}

@test "warns that the GPG signing key is not in the archive" {
  echo gitlocal > "$HOME/.gitconfig.local"
  git config --file "$HOME/.gitconfig" user.signingkey ABC123DEAD

  run "$SCRIPT" "$OUT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GPG key ABC123DEAD"* ]]
  [[ "$output" == *"export-secret-keys"* ]]
}

@test "does not warn when git signs with SSH, not GPG" {
  echo gitlocal > "$HOME/.gitconfig.local"
  git config --file "$HOME/.gitconfig" user.signingkey /key.pub
  git config --file "$HOME/.gitconfig" gpg.format ssh

  run "$SCRIPT" "$OUT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"export-secret-keys"* ]]
}
