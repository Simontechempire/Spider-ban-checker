#!/usr/bin/env bash

set -euo pipefail

source "./config.sh"

send_message() {
    local chat_id="$1"
    local text="$2"

    curl -sS -X POST \
        "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${chat_id}" \
        --data-urlencode "text=${text}" \
        >/dev/null
}

check_number() {
    local number="$1"

    bash "./checker.sh" "$number"
}

OFFSET=0

echo "🕷️ Spider XMD started"

while true; do

    RESPONSE=$(curl -sS \
        "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=30")

    while read -r UPDATE; do

        UPDATE_ID=$(echo "$UPDATE" | jq -r '.update_id')
        CHAT_ID=$(echo "$UPDATE" | jq -r '.message.chat.id // empty')
        TEXT=$(echo "$UPDATE" | jq -r '.message.text // empty')

        OFFSET=$((UPDATE_ID + 1))

        [ -z "$CHAT_ID" ] && continue

        case "$TEXT" in

            /start)
                send_message "$CHAT_ID" \
                    "🕷️ SPIDER XMD BAN CHECK

Use:
/check +2348012345678"
                ;;

            /check*)
                NUMBER="${TEXT#/check }"

                if [ -z "$NUMBER" ]; then
                    send_message "$CHAT_ID" \
                        "📱 Usage:
/check +2348012345678"
                    continue
                fi

                RESULT=$(check_number "$NUMBER")

                send_message "$CHAT_ID" "$RESULT"
                ;;

        esac

    done < <(
        echo "$RESPONSE" |
        jq -c '.result[]?'
    )

done
