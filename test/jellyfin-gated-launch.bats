#!/usr/bin/env bats

# Tests for the volume-readiness logic in scripts/jellyfin-gated-launch.
# Sources the script (which bails at the BASH_SOURCE guard) to call the
# functions in isolation.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/scripts/jellyfin-gated-launch"
}

teardown() {
  rm -rf "$TMP"
}

@test "Volume is not ready when the mount point is absent" {
  run volume_ready "$TMP/absent" Movies
  [[ "$status" -eq 1 ]]
}

@test "Volume is not ready when the sentinel directory is absent" {
  mkdir -p "$TMP/volume"
  run volume_ready "$TMP/volume" Movies
  [[ "$status" -eq 1 ]]
}

@test "Volume is not ready when the sentinel directory is empty" {
  mkdir -p "$TMP/volume/Movies"
  run volume_ready "$TMP/volume" Movies
  [[ "$status" -eq 1 ]]
}

@test "Volume is ready when the sentinel directory has content" {
  mkdir -p "$TMP/volume/Movies"
  touch "$TMP/volume/Movies/a-film.mkv"
  run volume_ready "$TMP/volume" Movies
  [[ "$status" -eq 0 ]]
}

@test "A hidden entry alone counts as content" {
  mkdir -p "$TMP/volume/Movies"
  touch "$TMP/volume/Movies/.hidden"
  run volume_ready "$TMP/volume" Movies
  [[ "$status" -eq 0 ]]
}

@test "Waiting returns immediately when the volume is already mounted" {
  mkdir -p "$TMP/volume/Movies"
  touch "$TMP/volume/Movies/a-film.mkv"
  run wait_for_volume "$TMP/volume" Movies 10 1
  [[ "$status" -eq 0 ]]
}

@test "Waiting times out when the volume never appears" {
  run wait_for_volume "$TMP/absent" Movies 1 1
  [[ "$status" -eq 1 ]]
}

@test "Waiting times out rather than launching against an empty sentinel" {
  mkdir -p "$TMP/volume/Movies"
  run wait_for_volume "$TMP/volume" Movies 1 1
  [[ "$status" -eq 1 ]]
}

@test "Waiting polls with a fractional interval rather than failing arithmetic" {
  run wait_for_volume "$TMP/absent" Movies 1 0.1
  [[ "$status" -eq 1 ]]
  [[ "$output" != *"syntax error"* ]]
  [[ "$output" == *"gave up after 1s"* ]]
}

@test "Waiting rejects a non-integer timeout instead of dying in arithmetic" {
  run wait_for_volume "$TMP/absent" Movies 0.5 1
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"whole number of seconds"* ]]
}

@test "Waiting rejects a non-numeric timeout" {
  run wait_for_volume "$TMP/absent" Movies forever 1
  [[ "$status" -eq 2 ]]
}

@test "Main does not launch Jellyfin when the volume never appears" {
  JELLYFIN_VOLUME="$TMP/absent"
  JELLYFIN_SENTINEL=Movies
  JELLYFIN_WAIT_TIMEOUT=1
  JELLYFIN_POLL_INTERVAL=1
  JELLYFIN_LAUNCH_CMD="touch $TMP/launched"

  run main
  [[ "$status" -eq 1 ]]
  [[ ! -e "$TMP/launched" ]]
  [[ "$output" == *"not launching"* ]]
}

@test "Main launches Jellyfin once the volume is mounted" {
  mkdir -p "$TMP/volume/Movies"
  touch "$TMP/volume/Movies/a-film.mkv"
  JELLYFIN_VOLUME="$TMP/volume"
  JELLYFIN_SENTINEL=Movies
  JELLYFIN_WAIT_TIMEOUT=1
  JELLYFIN_POLL_INTERVAL=1
  JELLYFIN_LAUNCH_CMD="touch $TMP/launched"

  run main
  [[ "$status" -eq 0 ]]
  [[ -e "$TMP/launched" ]]
}
