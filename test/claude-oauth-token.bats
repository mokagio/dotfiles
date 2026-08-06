#!/usr/bin/env bats

# Tests for the `claude` wrapper in zsh/functions/claude.zsh.
# Stub `security`, `op`, and `claude` binaries go first on PATH and the function
# is sourced in a `zsh --no-rcs` subshell, so nothing reaches the real Keychain,
# the real 1Password vault, or the real Claude Code.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  ZSH_BIN="$(command -v zsh)"
  MOCK_DIR="$(mktemp -d)"
  : > "$MOCK_DIR/calls"
  : > "$MOCK_DIR/invocation"

  # The Keychain is the `keychain` file: absent means a cache miss, which the
  # real `security` reports as exit 44.
  cat > "$MOCK_DIR/security" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "security $1" >> "$dir/calls"
case "$1" in
  find-generic-password)
    [[ -f "$dir/keychain" ]] || exit 44
    cat "$dir/keychain"
    ;;
  add-generic-password)
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == -w ]]; then printf '%s' "$2" > "$dir/keychain"; break; fi
      shift
    done
    ;;
esac
MOCK

  cat > "$MOCK_DIR/op" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
echo "op $*" >> "$dir/calls"
[[ -f "$dir/op-fails" ]] && exit 1
printf 'token-from-vault'
MOCK

  cat > "$MOCK_DIR/claude" <<'MOCK'
#!/usr/bin/env bash
dir="$(cd "$(dirname "$0")" && pwd)"
{
  echo "args: $*"
  echo "token: ${CLAUDE_CODE_OAUTH_TOKEN-<unset>}"
} >> "$dir/invocation"
MOCK

  chmod +x "$MOCK_DIR/security" "$MOCK_DIR/op" "$MOCK_DIR/claude"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

# Homebrew's bin is off PATH so `command -v op` and `command claude` can only
# find the stubs; the system dirs stay on it for the stubs' `env bash` shebang.
run_wrapper() {
  run env PATH="$MOCK_DIR:/usr/bin:/bin" "$ZSH_BIN" --no-rcs -c \
    "source '$SCRIPT_DIR/zsh/functions/claude.zsh'; $*"
}

@test "Token already in the Keychain is used without touching 1Password" {
  printf 'token-from-keychain' > "$MOCK_DIR/keychain"
  run_wrapper claude
  grep -q 'token: token-from-keychain' "$MOCK_DIR/invocation"
  ! grep -q '^op ' "$MOCK_DIR/calls"
}

@test "Keychain miss falls back to 1Password" {
  run_wrapper claude
  grep -q 'op read --no-newline op://Personal/Claude Code OAuth token/credential' "$MOCK_DIR/calls"
  grep -q 'token: token-from-vault' "$MOCK_DIR/invocation"
}

@test "Keychain miss seeds the Keychain so the next launch skips 1Password" {
  run_wrapper claude
  [ "$(cat "$MOCK_DIR/keychain")" = "token-from-vault" ]
  grep -q 'security add-generic-password' "$MOCK_DIR/calls"
}

@test "Launch without op available still starts Claude Code" {
  rm "$MOCK_DIR/op"
  run_wrapper claude
  grep -q 'token: <unset>' "$MOCK_DIR/invocation"
}

@test "Launch with a failing vault read still starts Claude Code" {
  touch "$MOCK_DIR/op-fails"
  run_wrapper claude
  grep -q 'token: <unset>' "$MOCK_DIR/invocation"
}

# The token must not outlive the launch: an exported one would be inherited by
# every later child of the shell, well outside Claude Code's own scrubbing.
@test "Token does not leak into the launching shell" {
  printf 'token-from-keychain' > "$MOCK_DIR/keychain"
  run_wrapper 'claude; echo "leaked: ${CLAUDE_CODE_OAUTH_TOKEN-<unset>}"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"leaked: <unset>"* ]]
}

@test "Arguments reach Claude Code unchanged" {
  printf 'token-from-keychain' > "$MOCK_DIR/keychain"
  run_wrapper claude --plugin-dir /some/dir --dangerously-skip-permissions
  grep -q 'args: --plugin-dir /some/dir --dangerously-skip-permissions' "$MOCK_DIR/invocation"
}
