#!/bin/bash

# * * * * * /home/skandars0/auto_commit_history.sh >> /home/skandars0/cron.log 2>&1

#  Export environment variables
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export GIT_AUTHOR_NAME="Commit history bot"
export GIT_AUTHOR_EMAIL="commit-history-bot@not-found.com"
export GIT_COMMITTER_NAME="Commit history bot"
export GIT_COMMITTER_EMAIL="commit-history-bot@not-found.com"

# Log file
LOG_FILE="$HOME/cron.log"

# Start SSH agent if not already running or not accessible
if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)"
    echo "SSH agent started."
else
    echo "SSH agent is already running and accessible."
fi

# Add SSH key if not already added
if ! ssh-add -l | grep -q "id_ed25519_automation"; then
    ssh-add ~/.ssh/id_ed25519_automation
    echo "SSH key added."
else
    echo "SSH key is already added."
fi

   # Navigate to submodule
cd $HOME/.history || {
    echo "[$(date)] Failed to navigate to .history submodule" >> "$LOG_FILE"
    ssh-agent -k > /dev/null
    exit 1
}

# Check for changes in submodule
if git status --porcelain | grep -q .; then
    echo "[$(date)] Changes detected in .history submodule" >> "$LOG_FILE"
    git add . || {
        echo "[$(date)] Git add failed in submodule" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    git commit -m "Automated commit: Updated history files" || {
        echo "[$(date)] Git commit failed in submodule" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    git push origin master || {
        echo "[$(date)] Git push failed in submodule" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    echo "[$(date)] Submodule changes committed and pushed to origin" >> "$LOG_FILE"
else
    echo "[$(date)] No changes in .history submodule" >> "$LOG_FILE"
    ssh-agent -k > /dev/null
    exit 0
fi

# Navigate to parent repository
cd $HOME || {
    echo "[$(date)] Failed to navigate to parent repository" >> "$LOG_FILE"
    ssh-agent -k > /dev/null
    exit 1
}

if git status --porcelain | grep -q .history; then
    git commit --no-verify -m "Automated commit: Updated .history submodule reference" .history || {
        echo "[$(date)] Git commit failed for submodule reference" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    # change remote URL of origin to git@github-automation:SkandarS0/linux-setup.git then push, then change it back to
    # git@github.com:SkandarS0/linux-setup.git
    git remote set-url origin git@github-automation:SkandarS0/linux-setup.git || {
        echo "[$(date)] Failed to change remote URL to automation" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    git push origin master || {
        echo "[$(date)] Git push failed for parent repository" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    git remote set-url origin git@github.com:SkandarS0/linux-setup.git || {
        echo "[$(date)] Failed to change remote URL back to original" >> "$LOG_FILE"
        ssh-agent -k > /dev/null
        exit 1
    }
    echo "[$(date)] Parent repository updated with new submodule reference" >> "$LOG_FILE"
else
    echo "[$(date)] No update needed for .history submodule reference" >> "$LOG_FILE"
fi

# Clean up
ssh-agent -k > /dev/null
echo "[$(date)] Automation script completed" >> "$LOG_FILE"