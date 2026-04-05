#!/bin/bash
# TermChat Linux - fully anonymous, no Git login needed

REPO_RAW="https://raw.githubusercontent.com/Rocco45Git/TermChat/main/messages.log"
ARCHIVE="$HOME/.termchat_local.log"
USER_FILE="$HOME/.termchat_user"
BANS="$HOME/.termchat_bans.log"

# Setup
touch "$ARCHIVE"
touch "$BANS"

# Username setup
if [ ! -f "$USER_FILE" ]; then
    while true; do
        read -p "Choose your username (cannot be Rocco44 unless owner patch): " username
        if [[ "$username" == "Rocco44" ]]; then
            echo "That username is reserved."
        else
            echo "$username" > "$USER_FILE"
            break
        fi
    done
fi
USERNAME=$(cat "$USER_FILE")

# Fetch messages from GitHub
fetch_messages() {
    curl -s "$REPO_RAW" > "$ARCHIVE.tmp" || echo "" > "$ARCHIVE.tmp"
    mv "$ARCHIVE.tmp" "$ARCHIVE"
}

# Display messages excluding hidden posts
display_messages() {
    clear
    echo "----- TermChat -----"
    grep -v "^@" "$ARCHIVE"
    echo "-------------------"
}

# Append a message to local archive
append_message() {
    local msg="$1"
    echo "$(date +%s)|$USERNAME: $msg" >> "$ARCHIVE"
}

# Handle command posts
handle_commands() {
    local msg="$1"
    if [[ "$msg" == @* ]]; then
        cmd=$(echo "$msg" | cut -d' ' -f1)
        case "$cmd" in
            @ban)
                if [[ "$USERNAME" == "Rocco44 (MOD)" ]]; then
                    target=$(echo "$msg" | cut -d' ' -f2)
                    echo "$target" >> "$BANS"
                    echo "[MOD] $target banned."
                else
                    echo "Only the owner can ban."
                fi
                ;;
            @unban)
                if [[ "$USERNAME" == "Rocco44 (MOD)" ]]; then
                    target=$(echo "$msg" | cut -d' ' -f2)
                    sed -i "/^$target$/d" "$BANS"
                    echo "[MOD] $target unbanned."
                else
                    echo "Only the owner can unban."
                fi
                ;;
            @givename)
                name=$(echo "$msg" | cut -d' ' -f2)
                echo "[SYSTEM] Username $name is now available."
                ;;
            @help)
                echo "[AUTOMOD] Commands: @ban, @unban, @givename, @help, hidden posts start with @"
                ;;
        esac
        return 0
    fi
    return 1
}

# Main loop
while true; do
    fetch_messages
    display_messages
    read -p "$USERNAME: " MESSAGE
    handle_commands "$MESSAGE" || append_message "$MESSAGE"
done
