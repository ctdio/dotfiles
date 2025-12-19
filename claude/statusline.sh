#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Directory (basename only, like Starship) - color 245 (medium gray)
dir_name=$(basename "$cwd")
printf "\\033[38;5;245m%s\\033[0m" "$dir_name"

# Git information (if in a git repo)
if cd "$cwd" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    # Git branch - color 71 (dark green)
    branch=$(git branch --show-current 2>/dev/null || echo 'HEAD')
    printf " \\033[38;5;71m%s\\033[0m" "$branch"

    # Git status indicators
    git_status=$(git status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        # Status dot - color 240 (dark gray)
        printf " \\033[38;5;240m●\\033[0m"

        # Count different types of changes for additional indicators
        modified=$(echo "$git_status" | grep -E '^.M|^M' | wc -l | tr -d ' ')
        untracked=$(echo "$git_status" | grep '^??' | wc -l | tr -d ' ')
        staged=$(echo "$git_status" | grep -E '^A|^D|^R' | wc -l | tr -d ' ')

        # Check for ahead/behind
        ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null || echo "0	0")
        behind=$(echo "$ahead_behind" | cut -f1)
        ahead=$(echo "$ahead_behind" | cut -f2)

        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            printf " \\033[38;5;243m⇕⇡%s⇣%s\\033[0m" "$ahead" "$behind"
        elif [ "$ahead" -gt 0 ]; then
            printf " \\033[38;5;243m⇡%s\\033[0m" "$ahead"
        elif [ "$behind" -gt 0 ]; then
            printf " \\033[38;5;243m⇣%s\\033[0m" "$behind"
        fi
    fi

    # Check for git state (merge, rebase, etc.) - color 8 (bright-black)
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    if [ -f "$git_dir/MERGE_HEAD" ]; then
        printf " \\033[38;5;8m(MERGING)\\033[0m"
    elif [ -f "$git_dir/rebase-merge/interactive" ]; then
        printf " \\033[38;5;8m(REBASE-i)\\033[0m"
    elif [ -d "$git_dir/rebase-merge" ]; then
        printf " \\033[38;5;8m(REBASE-m)\\033[0m"
    elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
        printf " \\033[38;5;8m(CHERRY-PICKING)\\033[0m"
    elif [ -f "$git_dir/REVERT_HEAD" ]; then
        printf " \\033[38;5;8m(REVERTING)\\033[0m"
    fi
fi

# Python virtual environment - color 8 (bright-black)
if [ -n "$VIRTUAL_ENV" ]; then
    venv_name=$(basename "$VIRTUAL_ENV")
    printf " \\033[38;5;8m%s\\033[0m" "$venv_name"
fi

# Character prompt and model - color 243 (dark gray) for prompt, default for model
printf " \\033[38;5;243m❯\\033[0m %s" "$model"
