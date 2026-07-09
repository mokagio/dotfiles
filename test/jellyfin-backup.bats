#!/usr/bin/env bats

# Tests for the copy, database-snapshot and pruning logic in
# scripts/jellyfin-backup. Sources the script (which bails at the BASH_SOURCE
# guard) to call the functions in isolation.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/scripts/jellyfin-backup"

  SRC="$TMP/jellyfin"
  mkdir -p "$SRC/config" "$SRC/data" "$SRC/metadata" "$SRC/cache" "$SRC/log" "$SRC/transcodes"
  echo '<encoding/>' > "$SRC/config/encoding.xml"
  echo poster > "$SRC/metadata/poster.jpg"
  echo junk > "$SRC/cache/chunk"
  echo junk > "$SRC/log/jellyfin.log"
  echo junk > "$SRC/transcodes/tmp.ts"
  sqlite3 "$SRC/data/jellyfin.db" 'CREATE TABLE items (id INTEGER); INSERT INTO items VALUES (42);'
}

teardown() {
  rm -rf "$TMP"
}

@test "Copy preserves config and metadata" {
  copy_tree "$SRC" "$TMP/dest"
  [[ -f "$TMP/dest/config/encoding.xml" ]]
  [[ -f "$TMP/dest/metadata/poster.jpg" ]]
}

@test "Copy skips regenerable cache, log and transcode directories" {
  copy_tree "$SRC" "$TMP/dest"
  [[ ! -e "$TMP/dest/cache/chunk" ]]
  [[ ! -e "$TMP/dest/log/jellyfin.log" ]]
  [[ ! -e "$TMP/dest/transcodes/tmp.ts" ]]
}

@test "Copy skips the live database so it can be snapshotted separately" {
  copy_tree "$SRC" "$TMP/dest"
  [[ ! -e "$TMP/dest/data/jellyfin.db" ]]
}

@test "Database snapshot is a readable copy of the original" {
  snapshot_database "$SRC/data/jellyfin.db" "$TMP/dest/data/jellyfin.db"
  run sqlite3 "$TMP/dest/data/jellyfin.db" 'SELECT id FROM items;'
  [[ "$status" -eq 0 ]]
  [[ "$output" == 42 ]]
}

@test "Database snapshot of a missing database is not an error" {
  run snapshot_database "$SRC/data/absent.db" "$TMP/dest/data/absent.db"
  [[ "$status" -eq 0 ]]
}

@test "Verification passes on a healthy database" {
  snapshot_database "$SRC/data/jellyfin.db" "$TMP/dest/data/jellyfin.db"
  run verify_database "$TMP/dest/data/jellyfin.db"
  [[ "$status" -eq 0 ]]
}

@test "Verification fails on a corrupt database" {
  mkdir -p "$TMP/dest/data"
  echo 'this is not a database' > "$TMP/dest/data/jellyfin.db"
  run verify_database "$TMP/dest/data/jellyfin.db"
  [[ "$status" -ne 0 ]]
}

@test "Pruning keeps the newest snapshots and removes the rest" {
  mkdir -p "$TMP/backups"/2026-07-0{1,2,3,4}T00-00-00
  prune_snapshots "$TMP/backups" 2
  [[ -d "$TMP/backups/2026-07-04T00-00-00" ]]
  [[ -d "$TMP/backups/2026-07-03T00-00-00" ]]
  [[ ! -d "$TMP/backups/2026-07-02T00-00-00" ]]
  [[ ! -d "$TMP/backups/2026-07-01T00-00-00" ]]
}

@test "Pruning leaves unrelated directories alone" {
  mkdir -p "$TMP/backups/2026-07-01T00-00-00" "$TMP/backups/notes"
  prune_snapshots "$TMP/backups" 0
  [[ ! -d "$TMP/backups/2026-07-01T00-00-00" ]]
  [[ -d "$TMP/backups/notes" ]]
}

@test "Pruning spares a directory that merely starts with the century" {
  mkdir -p "$TMP/backups/2026-tax-receipts" "$TMP/backups/2026-07-01T00-00-00"
  prune_snapshots "$TMP/backups" 0
  [[ ! -d "$TMP/backups/2026-07-01T00-00-00" ]]
  [[ -d "$TMP/backups/2026-tax-receipts" ]]
}

@test "Database snapshot survives a single quote in the destination path" {
  local dest="$TMP/gio's backups/data/jellyfin.db"
  snapshot_database "$SRC/data/jellyfin.db" "$dest"
  run sqlite3 "$dest" 'SELECT id FROM items;'
  [[ "$status" -eq 0 ]]
  [[ "$output" == 42 ]]
}

@test "Database snapshot survives a double quote in the destination path" {
  local dest="$TMP/say \"hi\"/data/jellyfin.db"
  snapshot_database "$SRC/data/jellyfin.db" "$dest"
  run sqlite3 "$dest" 'SELECT id FROM items;'
  [[ "$status" -eq 0 ]]
  [[ "$output" == 42 ]]
}

@test "Pruning an absent directory is not an error" {
  run prune_snapshots "$TMP/absent" 3
  [[ "$status" -eq 0 ]]
}

@test "A full run snapshots the database and prunes to the keep limit" {
  JELLYFIN_DATA_DIR="$SRC"
  JELLYFIN_BACKUP_DIR="$TMP/backups"
  JELLYFIN_BACKUP_KEEP=1
  mkdir -p "$TMP/backups/2026-01-01T00-00-00"

  run main 2026-07-09T12-00-00
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP/backups/2026-07-09T12-00-00/config/encoding.xml" ]]
  [[ -f "$TMP/backups/2026-07-09T12-00-00/data/jellyfin.db" ]]
  [[ ! -d "$TMP/backups/2026-01-01T00-00-00" ]]
}
