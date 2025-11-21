#!/usr/bin/env bash

set -euo pipefail

SESSION="burpeebata"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)" # Get the parent directory of the script, which is the project root, the script should be in bin/
PROJECT_DIR="$(dirname "$PROJECT_DIR")"      # Move up one level to the project root

cd "$PROJECT_DIR"

# Start tmux session if not already running
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "docker"
fi

# Docker window
tmux send-keys -t "$SESSION:docker" "docker compose up" C-m

# VIM window with split pane
tmux new-window -t "$SESSION" -n "VIM"
tmux split-window -t "$SESSION:VIM" -v
tmux select-pane -t "$SESSION:VIM.1" -T "CLI"
tmux send-keys -t "$SESSION:VIM.0" "nvim" C-m
# tmux send-keys -t "$SESSION:VIM.1" "docker compose exec flutter bundle exec guard" C-m


tmux select-window -t "$SESSION:VIM"
tmux select-pane -t 0

# Attach to session if not already in tmux
if [[ -z "${TMUX:-}" ]]; then
  tmux attach-session -t "$SESSION"
fi
