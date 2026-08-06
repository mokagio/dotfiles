# Claude Code's browser login expires far sooner than the year-long token
# `claude setup-token` mints, so hand it that token on every launch.
#
# The Keychain, not 1Password, is on the hot path: `op read` costs ~2s and an
# "allow CLI access" prompt once per terminal app, a Keychain read 10ms and no
# prompt. 1Password stays the source of truth — a cache miss reseeds from it, so
# a fresh machine or a rotated token costs one prompt and nothing after.
#
# Passed as a command prefix rather than exported. Claude Code strips the
# variable from its own subprocesses, so agents can't read it either way, but an
# export would also hand it to every later child of the launching shell.
claude() {
  local service=claude-code-oauth-token
  local token

  token=$(security find-generic-password -a "$USER" -s "$service" -w 2>/dev/null) \
    || token=$(_claude_seed_oauth_token "$service")

  if [[ -n "$token" ]]; then
    CLAUDE_CODE_OAUTH_TOKEN="$token" command claude "$@"
  else
    command claude "$@"
  fi
}

# Copy the token from 1Password into the Keychain, and echo it so the launch it
# was triggered by can use it. Fails quietly when `op` is missing or can't read:
# Claude Code then falls back to whatever login it has stored.
_claude_seed_oauth_token() {
  local service=$1
  local token

  command -v op >/dev/null 2>&1 || return 1
  token=$(op read --no-newline "op://Personal/Claude Code OAuth token/credential" 2>/dev/null) || return 1
  [[ -n "$token" ]] || return 1

  security add-generic-password -a "$USER" -s "$service" -w "$token" -U 2>/dev/null
  print -r -- "$token"
}
