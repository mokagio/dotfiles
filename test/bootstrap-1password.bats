#!/usr/bin/env bats

# Tests for bootstrap_1password() and wait_for_1password_cli() in setup.sh.
# Sources setup.sh (it bails at its BASH_SOURCE guard) and puts stub `op`,
# `brew`, and `open` binaries first on PATH, so nothing touches the real
# machine or the real 1Password install.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  MOCK_DIR="$(mktemp -d)"
  PATH="$MOCK_DIR:$PATH"
  : > "$MOCK_DIR/calls"

  # How many readiness probes fail before one succeeds. 0 = already signed in,
  # a big number = never works. Lets a test flip `op` mid-run without touching
  # stdin, which the prompt loop owns.
  echo 999 > "$MOCK_DIR/op-fails"

  # `whoami` always fails, mirroring op 2.34.1, where it reports "account is not
  # signed in" no matter how healthy the CLI is.
  cat > "$MOCK_DIR/op" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "op $*" >> "$dir/calls"
[[ "$1" == whoami ]] && exit 1
remaining=$(cat "$dir/op-fails")
if [[ "$remaining" -gt 0 ]]; then
  echo $((remaining - 1)) > "$dir/op-fails"
  exit 1
fi
MOCK

  cat > "$MOCK_DIR/brew" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "brew $*" >> "$dir/calls"
case "$1" in
  list)    [[ -f "$dir/installed-$3" ]] ;;
  install) for arg in "$@"; do cask=$arg; done; touch "$dir/installed-$cask" ;;
esac
MOCK

  cat > "$MOCK_DIR/open" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "open $*" >> "$dir/calls"
MOCK

  chmod +x "$MOCK_DIR/op" "$MOCK_DIR/brew" "$MOCK_DIR/open"

  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/setup.sh"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

calls() {
  cat "$MOCK_DIR/calls"
}

# --- bootstrap_1password ---

@test "already signed in: skips the whole bootstrap" {
  echo 0 > "$MOCK_DIR/op-fails"
  run bootstrap_1password < /dev/null
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"already signed in"* ]]
  [[ "$(calls)" != *"brew install"* ]]
  [[ "$(calls)" != *"open"* ]]
}

@test "a broken 'op whoami' does not mask a working CLI" {
  echo 0 > "$MOCK_DIR/op-fails"
  run bootstrap_1password < /dev/null
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"already signed in"* ]]
  [[ "$(calls)" != *"op whoami"* ]]
}

@test "not signed in: installs both the app and the CLI" {
  run bootstrap_1password < /dev/null
  [[ "$status" -eq 0 ]]
  [[ "$(calls)" == *"brew install --cask --adopt 1password"$'\n'* ]]
  [[ "$(calls)" == *"brew install --cask --adopt 1password-cli"* ]]
}

@test "adopts an app already sitting in /Applications" {
  bootstrap_1password >/dev/null < /dev/null
  [[ "$(calls)" == *"brew install --cask --adopt 1password"* ]]
}

@test "installs the app before the CLI" {
  bootstrap_1password >/dev/null < /dev/null
  installs=$(grep 'brew install' "$MOCK_DIR/calls")
  [[ "$(printf '%s\n' "$installs" | head -n 1)" == "brew install --cask --adopt 1password" ]]
}

@test "already-installed casks are not reinstalled" {
  touch "$MOCK_DIR/installed-1password" "$MOCK_DIR/installed-1password-cli"
  run bootstrap_1password < /dev/null
  [[ "$output" == *"1password already installed"* ]]
  [[ "$output" == *"1password-cli already installed"* ]]
  [[ "$(calls)" != *"brew install"* ]]
}

@test "opens the app so the sign-in can happen" {
  bootstrap_1password >/dev/null < /dev/null
  [[ "$(calls)" == *"open -a 1Password"* ]]
}

@test "prints the sign-in and CLI-integration steps in order" {
  run bootstrap_1password < /dev/null
  [[ "$output" == *"1. Sign in"* ]]
  [[ "$output" == *"2. Settings > Developer > enable 'Integrate with 1Password CLI'"* ]]
}

@test "non-interactive stdin: warns and returns 0 instead of waiting" {
  run bootstrap_1password < /dev/null
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Not an interactive shell"* ]]
  [[ "$output" == *"re-run setup.sh"* ]]
}

@test "a failed cask install warns but does not abort the bootstrap" {
  cat > "$MOCK_DIR/brew" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "brew $*" >> "$dir/calls"
[[ "$1" == install ]] && exit 1
exit 1
MOCK
  chmod +x "$MOCK_DIR/brew"
  run bootstrap_1password < /dev/null
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"brew install --cask 1password failed"* ]]
  [[ "$output" == *"brew install --cask 1password-cli failed"* ]]
}

# --- wait_for_1password_cli ---

@test "returns 0 as soon as the readiness probe succeeds" {
  echo 0 > "$MOCK_DIR/op-fails"
  run wait_for_1password_cli <<< $'\n'
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"1Password CLI ready"* ]]
}

@test "re-prompts when the integration is not on yet, then succeeds" {
  echo 1 > "$MOCK_DIR/op-fails"
  run wait_for_1password_cli <<< $'\n\n'
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"still fails"* ]]
  [[ "$output" == *"1Password CLI ready"* ]]
}

@test "gives up after 3 prompts and returns non-zero" {
  run wait_for_1password_cli <<< $'\n\n\n'
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Giving up"* ]]
  [[ "$(grep -c 'op account get' "$MOCK_DIR/calls")" -eq 3 ]]
}

@test "EOF on stdin returns non-zero rather than looping" {
  run wait_for_1password_cli < /dev/null
  [[ "$status" -eq 1 ]]
  [[ "$output" != *"Giving up"* ]]
}
