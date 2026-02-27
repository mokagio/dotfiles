#!/usr/bin/env bash

# Shared helpers for iTerm2 hooks.
# Source this file — do not execute directly.

# Walk up the process tree to find a tty.
find_tty() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local tty
    tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$tty" ] && [ "$tty" != "??" ]; then
      echo "/dev/$tty"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

# Set the iTerm2 session name for the current tty.
# Usage: iterm_set_session_name "new name"
# An empty string resets to the default profile name.
iterm_set_session_name() {
  local name="$1"
  local tty
  tty=$(find_tty) || return 0

  osascript -e "
tell application \"iTerm2\"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if tty of s is \"$tty\" then
          set name of s to \"$name\"
        end if
      end repeat
    end repeat
  end repeat
end tell
"
}
