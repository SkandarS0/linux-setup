#!/bin/bash

# * * * * * /home/skandars0/auto_commit_history.sh >> /home/skandars0/cron.log 2>&1

# Directory paths
HISTORY_DIR="$HOME/.history"

# Check if directories exist
if [ ! -d "$HOME" ] || [ ! -d "$HISTORY_DIR" ]; then
    echo "One or both directories do not exist."
    exit 1
fi

# Function to handle Git operations
commit() {
    # Navigate to history directory
    cd "$HISTORY_DIR" || exit 1

    # Check if there are changes to commit
    if [ -n "$(git status --porcelain)" ]; then
        echo "Changes detected in history directory. Committing..."
        git add .
        git commit -m "Auto-commit: Updated history files $(date '+%Y-%m-%d %H:%M:%S')"
        
        # Navigate to parent repo
        cd "$HOME" || exit 1
        
        echo "Updating submodule reference in parent repo..."
        git add .history
        git commit -m "Auto-update: Submodule .history updated to latest commit $(date '+%Y-%m-%d %H:%M:%S')"
        
        echo "Changes committed successfully."
    else
        echo "No changes to commit in submodule."
    fi
}

# Run the commit function
commit