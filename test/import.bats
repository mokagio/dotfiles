#!/usr/bin/env bats

SCRIPT_DIR=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)
SCRIPT="$SCRIPT_DIR/import.sh"

setup() {
  export TMP_ROOT
  TMP_ROOT=$(mktemp -d)
  export HOME="$TMP_ROOT/home"
  mkdir -p "$HOME"
  export SRC="$TMP_ROOT/src"
  mkdir -p "$SRC/.ssh"
  export ARCHIVE="$TMP_ROOT/dotfiles-local.tar.gz"
}

teardown() {
  rm -rf "$TMP_ROOT"
}

# Build an archive from staged files under $SRC.
make_archive() {
  tar -czf "$ARCHIVE" -C "$SRC" "$@"
}

@test "extracts an absent file into HOME" {
  echo zshenvlocal > "$SRC/.zshenv.local"
  make_archive .zshenv.local

  run "$SCRIPT" "$ARCHIVE"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.zshenv.local")" = zshenvlocal ]
}

@test "backs up a pre-existing target before overwriting" {
  echo NEW > "$SRC/.gitconfig.local"
  make_archive .gitconfig.local
  echo OLD > "$HOME/.gitconfig.local"

  run "$SCRIPT" "$ARCHIVE"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.gitconfig.local")" = NEW ]

  backup=$(ls "$HOME"/.gitconfig.local.bak-* 2>/dev/null)
  [ -f "$backup" ]
  [ "$(cat "$backup")" = OLD ]
  [[ "$output" == *"Backed up"* ]]
}

@test "creates .ssh with 700 perms for an ssh config" {
  echo sshlocal > "$SRC/.ssh/config.local"
  make_archive .ssh/config.local

  run "$SCRIPT" "$ARCHIVE"
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.ssh/config.local")" = sshlocal ]

  perms=$(stat -f '%Lp' "$HOME/.ssh" 2>/dev/null || stat -c '%a' "$HOME/.ssh")
  [ "$perms" = 700 ]
}

@test "missing archive argument exits non-zero with usage" {
  run "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "nonexistent archive path exits non-zero" {
  run "$SCRIPT" "$TMP_ROOT/nope.tar.gz"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "warns when the GPG signing key is absent from the keyring" {
  printf '[user]\n\tsigningkey = ABC123DEAD\n' > "$SRC/.gitconfig.local"
  make_archive .gitconfig.local

  run "$SCRIPT" "$ARCHIVE"
  [ "$status" -eq 0 ]
  [[ "$output" == *"GPG key ABC123DEAD"* ]]
  [[ "$output" == *"gpg --import"* ]]
}

@test "does not warn when git signs with SSH, not GPG" {
  printf '[user]\n\tsigningkey = /key.pub\n[gpg]\n\tformat = ssh\n' > "$SRC/.gitconfig.local"
  make_archive .gitconfig.local

  run "$SCRIPT" "$ARCHIVE"
  [ "$status" -eq 0 ]
  [[ "$output" != *"gpg --import"* ]]
}
