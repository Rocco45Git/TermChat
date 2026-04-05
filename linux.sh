#!/bin/bash
# TermChat Linux version

REPO_DIR="$HOME/TermChatRepo"
LOG_FILE="$REPO_DIR/messages.log"

mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# clone if repo not present
if [ ! -d ".git" ]; then
    echo "Enter your GitHub repo HTTPS URL:"
    read REPO_URL
    git clone "$REPO_URL" .
fi

while true; do
    echo -n "You: "
    read MESSAGE
    TIMESTAMP=$(date +%s)
    echo "$TIMESTAMP|$MESSAGE" >> "$LOG_FILE"
    
    git add messages.log
    git commit -m "new message"
    git push origin main
    
    clear
    echo "----- Chat -----"
    git pull origin main
    cat messages.log
    echo "----------------"
done
