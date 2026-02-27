#!/usr/bin/env bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=iterm-helpers.sh
source "$SCRIPT_DIR/iterm-helpers.sh"

iterm_set_session_name "🤖‼️"
