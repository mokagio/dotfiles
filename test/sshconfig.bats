#!/usr/bin/env bats

# The seam's correctness hinges on ordering: ssh applies the FIRST matching
# value per directive across the composed config, so the private overlay
# (config.local, carrying specific Host stanzas) must be Included BEFORE the
# `Host *` wildcard, and nothing may follow `Host *`.

SCRIPT_DIR=$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)
CONFIG="$SCRIPT_DIR/ssh/config"

@test "includes the machine-local overlay" {
  run grep -qE '^Include ~/\.ssh/config\.local$' "$CONFIG"
  [ "$status" -eq 0 ]
}

@test "Include precedes the Host * wildcard" {
  include_line=$(grep -n '^Include ~/\.ssh/config\.local$' "$CONFIG" | cut -d: -f1)
  wildcard_line=$(grep -n '^Host \*$' "$CONFIG" | cut -d: -f1)
  [ -n "$include_line" ]
  [ -n "$wildcard_line" ]
  [ "$include_line" -lt "$wildcard_line" ]
}

@test "Host * is the last Host block (nothing more specific after it)" {
  # No `Host` line may appear after the wildcard, or it would be unreachable.
  wildcard_line=$(grep -n '^Host \*$' "$CONFIG" | cut -d: -f1)
  last_host_line=$(grep -n '^Host ' "$CONFIG" | tail -1 | cut -d: -f1)
  [ "$wildcard_line" -eq "$last_host_line" ]
}
