#!/usr/bin/env bash

# Resets the iTerm tab name after the notification hook sets it to "🤖‼️".
# Currently wired to UserPromptSubmit — ideally this would also run on
# SessionEnd, but that hook event doesn't exist yet in Claude Code.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=iterm-helpers.sh
source "$SCRIPT_DIR/iterm-helpers.sh"

iterm_set_session_name ""
