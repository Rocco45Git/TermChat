#!/bin/bash
# TermChat Linux - internet-based terminal chat, no Git login required

REPO_RAW="https://raw.githubusercontent.com/Rocco45Git/TermChat/main/messages.log"
REPO_API="https://api.github.com/repos/Rocco45Git/TermChat/contents/messages.log"
TOKEN_FILE="$HOME/.termchat_token"
ARCHIVE="$HOME/.termchat_local.log"

# Username setup
USER_FILE="$HOME/.termchat_user"
if [ ! -f "$USER_FILE" ]; then
    while true; do
        read -p "Choose your username (cannot be Rocco44): " username
        if [[ "$username" == "Rocco44" ]]; then
            echo "That username is reserved."
        else
            echo "$username" > "$USER_FILE"
            break
        fi
    done
fi
USERNAME=$(cat "$USER_FILE")

# Load local archive
touch "$ARCHIVE"

# Function to fetch messages from GitHub
fetch_messages() {
    curl -s $REPO_RAW > "$ARCHIVE.tmp" || echo "" > "$ARCHIVE.tmp"
    mv "$ARCHIVE.tmp" "$ARCHIVE"
}

# Function to push a new message to GitHub via API
push_message() {
    local msg="$1"
    local old=$(curl -s $REPO_API | jq -r '.content' | base64 --decode)
    local new_content=$(echo -e "$old\n$msg" | sed '/^\s*$/d')
    local encoded=$(echo -n "$new_content" | base64 | tr -d '\n')
    local sha=$(curl -s $REPO_API | jq -r '.sha')
    local payload="{\"message\":\"TermChat message\",\"content\":\"$encoded\",\"sha\":\"$sha\"}"
    curl -s -H "Authorization: token $(cat $TOKEN_FILE)" -X PUT -d "$payload" $REPO_API > /dev/null
}

# Main loop
while true; do
    fetch_messages
    clear
    echo "------ TermChat ------"
    grep -v "^@" "$ARCHIVE" # show only normal posts
    echo "---------------------"
    read -p "$USERNAME: " message
    timestamp=$(date +%s)

    # Check for command posts
    if [[ "$message" == @* ]]; then
        case "$message" in
            @ban*)
                target=$(echo "$message" | cut -d' ' -f2)
                echo "@ban $target" >> "$ARCHIVE"
                push_message "@ban $target"
                ;;
            @unban*)
                target=$(echo "$message" | cut -d' ' -f2)
                echo "@unban $target" >> "$ARCHIVE"
                push_message "@unban $target"
                ;;
            @givename*)
                name=$(echo "$message" | cut -d' ' -f2)
                echo "@givename $name" >> "$ARCHIVE"
                push_message "@givename $name"
                ;;
            @help)
                echo "@personalmssg $USERNAME \"All commands: @ban, @unban, @givename, @help\"" >> "$ARCHIVE"
                push_message "@personalmssg $USERNAME \"All commands: @ban, @unban, @givename, @help\""
                ;;
        esac
        continue
    fi

    # Append normal message
    echo "$timestamp|$USERNAME: $message" >> "$ARCHIVE"
    push_message "$timestamp|$USERNAME: $message"
done
