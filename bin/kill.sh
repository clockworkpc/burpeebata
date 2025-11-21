#!/bin/bash

# Kill the tmux session named "officerobot"
# This script is used to cleanly terminate the tmux session created by startup.sh
# # Usage: ./kill.sh
set -euo pipefail
SESSION="burpeebata"

# cd to the project directory
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)" # Get the parent directory of the script, which is the project root, the script should be in bin/
PROJECT_DIR="$(dirname "$PROJECT_DIR")"      # Move up one level to the project root
cd "$PROJECT_DIR" || exit 1

docker compose stop || true

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
else
  echo "No tmux session named '$SESSION' found."
fi
