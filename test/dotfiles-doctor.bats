#!/usr/bin/env bats

# Tests for the check_link()/report() logic in scripts/dotfiles-doctor.
# Sources the script (which bails at the BASH_SOURCE guard) to call the
# functions in isolation.

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  TMP="$(mktemp -d)"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/scripts/dotfiles-doctor"
  problems=0
  warnings=0
}

teardown() {
  rm -rf "$TMP"
}

@test "correct symlink: quiet and no problem" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "correct symlink counts as OK, not a problem" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  check_link "$TMP/src" "$TMP/dest" >/dev/null
  [[ "$problems" -eq 0 ]]
}

@test "verbose lists OK links" {
  echo content > "$TMP/src"
  ln -s "$TMP/src" "$TMP/dest"
  DOCTOR_VERBOSE=1 run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"OK"* ]]
}

@test "missing destination: reports MISSING and counts a problem" {
  echo content > "$TMP/src"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"MISSING"* ]]
  check_link "$TMP/src" "$TMP/dest" >/dev/null
  [[ "$problems" -eq 1 ]]
}

@test "symlink to wrong target: reports WRONG with expected" {
  echo content > "$TMP/src"
  ln -s "$TMP/elsewhere" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"WRONG"* ]]
  [[ "$output" == *"expected"* ]]
}

@test "real file where a symlink is expected: reports NOTLINK and diffs" {
  printf 'repo\n' > "$TMP/src"
  printf 'local\n' > "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"NOTLINK"* ]]
  [[ "$output" == *"-repo"* ]]
  [[ "$output" == *"+local"* ]]
}

@test "dangling symlink to the expected source: reports BROKEN" {
  ln -s "$TMP/src" "$TMP/dest"
  run check_link "$TMP/src" "$TMP/dest"
  [[ "$output" == *"BROKEN"* ]]
}

@test "env var set to an existing dir: quiet, no problem, no warning" {
  export DOCTOR_TEST_VAR="$TMP"
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
  check_env "DOCTOR_TEST_VAR|dir|notes root" >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "env var set to an existing dir: verbose lists OK with value" {
  export DOCTOR_TEST_VAR="$TMP"
  DOCTOR_VERBOSE=1 run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"OK"* ]]
  [[ "$output" == *"$TMP"* ]]
}

@test "unset env var: reports WARN and counts a warning, not a problem" {
  unset DOCTOR_TEST_VAR
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"unset"* ]]
  check_env "DOCTOR_TEST_VAR|dir|notes root" >/dev/null
  [[ "$warnings" -eq 1 ]]
  [[ "$problems" -eq 0 ]]
}

@test "dir var pointing at a missing path: reports WARN not a directory" {
  export DOCTOR_TEST_VAR="$TMP/does-not-exist"
  run check_env "DOCTOR_TEST_VAR|dir|notes root"
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"not a directory"* ]]
}

@test "kind=any: a set value is OK regardless of filesystem" {
  export DOCTOR_TEST_VAR="anything-goes"
  check_env "DOCTOR_TEST_VAR|any|freeform value" >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "every expected_env_vars entry is well-formed: name|kind|desc" {
  [[ "${#expected_env_vars[@]}" -gt 0 ]]
  for spec in "${expected_env_vars[@]}"; do
    IFS='|' read -r name kind desc <<<"$spec"
    [[ -n "$name" ]]
    [[ "$kind" == dir || "$kind" == any ]]
    [[ -n "$desc" ]]
  done
}

@test "gh_credential_hosts extracts gh-wired hosts, scheme stripped" {
  cat > "$TMP/cfg" <<'CFG'
[credential "https://github.com"]
  helper = !gh auth git-credential
[credential "https://gist.github.com"]
  helper = !gh auth git-credential
CFG
  run gh_credential_hosts "$TMP/cfg"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"github.com"* ]]
  [[ "$output" == *"gist.github.com"* ]]
}

@test "gh_credential_hosts follows [include] imports" {
  cat > "$TMP/inc" <<'CFG'
[credential "https://ghe.example.com"]
  helper = !gh auth git-credential
CFG
  cat > "$TMP/cfg" <<CFG
[include]
  path = $TMP/inc
CFG
  run gh_credential_hosts "$TMP/cfg"
  [[ "$output" == *"ghe.example.com"* ]]
}

@test "gh_credential_hosts ignores non-gh credential helpers" {
  cat > "$TMP/cfg" <<'CFG'
[credential "https://example.com"]
  helper = osxkeychain
[credential "https://github.com"]
  helper = !gh auth git-credential
CFG
  run gh_credential_hosts "$TMP/cfg"
  [[ "$output" == *"github.com"* ]]
  [[ "$output" != *"example.com"* ]]
}

@test "gh_credential_hosts: empty when nothing is gh-wired" {
  cat > "$TMP/cfg" <<'CFG'
[credential "https://example.com"]
  helper = osxkeychain
CFG
  run gh_credential_hosts "$TMP/cfg"
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "check_gh_auth: authenticated host is OK, no warning" {
  gh_available() { return 0; }
  gh_credential_hosts() { echo github.com; }
  gh_auth_ok() { return 0; }
  check_gh_auth >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "check_gh_auth: unauthenticated host warns with the login hint" {
  gh_available() { return 0; }
  gh_credential_hosts() { echo github.com; }
  gh_auth_ok() { return 1; }
  run check_gh_auth
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"gh:github.com"* ]]
  [[ "$output" == *"gh auth login"* ]]
}

@test "check_gh_auth: counts one warning per unauthenticated host" {
  gh_available() { return 0; }
  gh_credential_hosts() { printf '%s\n' github.com gist.github.com; }
  gh_auth_ok() { return 1; }
  check_gh_auth >/dev/null
  [[ "$warnings" -eq 2 ]]
  [[ "$problems" -eq 0 ]]
}

@test "check_gh_auth: gh missing but wired warns once" {
  gh_available() { return 1; }
  gh_credential_hosts() { echo github.com; }
  run check_gh_auth
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"not on PATH"* ]]
}

@test "check_gh_auth: no gh-wired hosts is a clean no-op" {
  gh_available() { return 0; }
  gh_credential_hosts() { :; }
  check_gh_auth >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "check_iterm_prefs: skipped entirely when iTerm2 is not installed" {
  iterm_installed() { return 1; }
  iterm_default() { echo "should not be called"; }
  run check_iterm_prefs
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
  check_iterm_prefs >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "check_iterm_prefs: custom folder off warns to wire it up" {
  iterm_installed() { return 0; }
  iterm_default() { :; }  # both keys absent
  run check_iterm_prefs
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"iterm2"* ]]
  [[ "$output" == *"custom folder"* ]]
  [[ "$output" == *"$HOME/Dropbox"* ]]
}

@test "check_iterm_prefs: custom folder on but pointed elsewhere warns" {
  iterm_installed() { return 0; }
  iterm_default() {
    case "$1" in
      LoadPrefsFromCustomFolder) echo 1 ;;
      PrefsCustomFolder) echo "/somewhere/else" ;;
    esac
  }
  run check_iterm_prefs
  [[ "$output" == *"WARN"* ]]
  [[ "$output" == *"/somewhere/else"* ]]
  [[ "$output" == *"expected"* ]]
}

@test "check_iterm_prefs: pointed at Dropbox is OK, no warning" {
  iterm_installed() { return 0; }
  iterm_default() {
    case "$1" in
      LoadPrefsFromCustomFolder) echo 1 ;;
      PrefsCustomFolder) echo "$HOME/Dropbox" ;;
    esac
  }
  check_iterm_prefs >/dev/null
  [[ "$problems" -eq 0 ]]
  [[ "$warnings" -eq 0 ]]
}

@test "check_iterm_prefs: trailing slash on the folder still matches" {
  iterm_installed() { return 0; }
  iterm_default() {
    case "$1" in
      LoadPrefsFromCustomFolder) echo 1 ;;
      PrefsCustomFolder) echo "$HOME/Dropbox/" ;;
    esac
  }
  check_iterm_prefs >/dev/null
  [[ "$warnings" -eq 0 ]]
}

@test "check_iterm_prefs: resolved CloudStorage target matches the Dropbox symlink" {
  HOME=$(mktemp -d)
  mkdir -p "$HOME/Library/CloudStorage/Dropbox"
  ln -s "$HOME/Library/CloudStorage/Dropbox" "$HOME/Dropbox"
  iterm_installed() { return 0; }
  iterm_default() {
    case "$1" in
      LoadPrefsFromCustomFolder) echo 1 ;;
      PrefsCustomFolder) echo "$HOME/Library/CloudStorage/Dropbox" ;;
    esac
  }
  check_iterm_prefs >/dev/null
  [[ "$warnings" -eq 0 ]]
}
