#!/bin/bash

BLOB_URL="https://jsonblob.com/api/jsonBlob/019d61d5-808c-7125-8911-f59a97277d99"

ARCHIVE="$HOME/.termchat_local.log"
USER_FILE="$HOME/.termchat_user"
BANS="$HOME/.termchat_bans.log"

mkdir -p "$(dirname "$ARCHIVE")"
touch "$ARCHIVE" "$BANS"

# USERNAME SETUP
if [ ! -f "$USER_FILE" ]; then
    while true; do
        read -p "Choose username: " name
        if [[ "$name" == "Rocco44" ]]; then
            echo "Reserved."
        else
            echo "$name" > "$USER_FILE"
            break
        fi
    done
fi

USERNAME=$(cat "$USER_FILE")

fetch() {
    curl -s "$BLOB_URL" | jq -r '.messages[]' > "$ARCHIVE"
}

send() {
    msg="$1"
    data=$(curl -s "$BLOB_URL")
    updated=$(echo "$data" | jq --arg m "$msg" '.messages += [$m]')
    curl -s -X PUT "$BLOB_URL" -H "Content-Type: application/json" -d "$updated" > /dev/null
}

is_banned() {
    grep -qx "$USERNAME" "$BANS"
}

while true; do
    fetch
    clear
    echo "==== TermChat ===="
    grep -v "^@" "$ARCHIVE"
    echo "=================="

    if is_banned; then
        echo "You are banned."
        sleep 3
        continue
    fi

    read -p "$USERNAME: " MSG

    if [[ "$MSG" == @* ]]; then
        CMD=$(echo "$MSG" | cut -d' ' -f1)
        ARG=$(echo "$MSG" | cut -d' ' -f2)

        if [[ "$USERNAME" == "Rocco44 (MOD)" || "$USERNAME" == "GalixigaGamez (MOD)" ]]; then
            if [[ "$CMD" == "@ban" && "$ARG" != "Rocco44" ]]; then
                echo "$ARG" >> "$BANS"
                continue
            fi
            if [[ "$CMD" == "@unban" ]]; then
                sed -i "/^$ARG$/d" "$BANS"
                continue
            fi
        fi

        if [[ "$CMD" == "@givename" ]]; then
            continue
        fi

        if [[ "$CMD" == "@help" ]]; then
            send "@personalmssg $USERNAME Commands: @ban @unban @givename @help"
            continue
        fi
    fi

    send "$USERNAME: $MSG"
done
