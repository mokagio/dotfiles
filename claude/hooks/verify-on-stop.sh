#!/usr/bin/env bash

set -eu

# Find the repo root from the working directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

# Swift (Package.swift)
if [[ -f "$REPO_ROOT/Package.swift" ]]; then
  cd "$REPO_ROOT"
  swift build 2>&1
  exit $?
fi

# Ruby (Gemfile with rubocop)
if [[ -f "$REPO_ROOT/Gemfile.lock" ]] && grep -q 'rubocop' "$REPO_ROOT/Gemfile.lock"; then
  cd "$REPO_ROOT"
  bundle exec rubocop --format quiet 2>&1
  exit $?
fi

# Rust (Cargo.toml)
if [[ -f "$REPO_ROOT/Cargo.toml" ]]; then
  cd "$REPO_ROOT"
  cargo check 2>&1
  exit $?
fi
