#!/bin/sh
set -e
run_segment() {
  command -v pomodoro >/dev/null 2>&1 && pomodoro status --format "%r/%l"
  return 0
}
