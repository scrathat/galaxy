#!/usr/bin/env zsh
# Requirements
# tmux, stdbuf, bash/zsh, awk

TIMEOUT="${1:-2m}" # 2 min timeout by default if no arg is given
GALAXY_DIR="/path/to/galaxy"
SESSION_NAME="galaxy"
NODE_PATH="/path/to/node(v10)"
[[ -x $NODE_PATH/node ]] && PATH="$NODE_PATH:$PATH"


if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
	echo "Tmux session \"$SESSION_NAME\" already exists."
	exit 0
fi

echo "Starting tmux session \"$SESSION_NAME\""

cd "$GALAXY_DIR"
rm run.log

tmux new -d -s "$SESSION_NAME" \; send-keys 'stdbuf -o0 ./run.sh 2>&1 | tee run.log' C-m 
timeout -sHUP "$TIMEOUT" tail -F run.log 2>/dev/null | \
	awk -F" " '/serving on https?:\/\//{ print "Galaxy output:", $0; exit 0 }'

EXIT_CODE_BASH="${PIPESTATUS[0]}"
EXIT_CODE_ZSH="${pipestatus[1]}"
if [[ -n $EXIT_CODE_ZSH ]]; then
	EXIT_CODE=$EXIT_CODE_ZSH
elif [[ -n $EXIT_CODE_BASH ]]; then
	EXIT_CODE=$EXIT_CODE_BASH
else
	EXIT_CODE=""
fi

if [[ -n $EXIT_CODE && $EXIT_CODE != 124 ]]; then
	MESSAGE="Galaxy instance is running"
	echo "$MESSAGE"
	echo "Starting client-watch..."
	which osascript 2>&1 >/dev/null && osascript -e "display notification \"$MESSAGE\" with title \"Galaxy\""
	tmux split-window -t "$SESSION_NAME" -h
	tmux send-keys -t "$SESSION_NAME" "PATH=\"$PATH\" make client-watch" C-m
else
	MESSAGE="Timout starting galaxy instance"
	echo "$MESSAGE"
	which osascript 2>&1 >/dev/null && osascript -e "display notification \"$MESSAGE\" with title \"Galaxy timeout\""
	tmux attach -t "$SESSION_NAME"
fi
