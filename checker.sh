#!/usr/bin/env bash

set -euo pipefail

source "./config.sh"

NUMBER="${1:-}"

if [ -z "$NUMBER" ]; then
    echo "❌ Phone number is required."
    exit 1
fi

if ! [[ "$NUMBER" =~ ^\+?[0-9]{8,15}$ ]]; then
    echo "❌ Invalid international phone number."
    exit 1
fi

[[ "$NUMBER" != +* ]] && NUMBER="+$NUMBER"

case "$NUMBER" in
    +234*) COUNTRY="Nigeria" ;;
    +233*) COUNTRY="Ghana" ;;
    +254*) COUNTRY="Kenya" ;;
    +27*)   COUNTRY="South Africa" ;;
    +44*)   COUNTRY="United Kingdom" ;;
    +1*)    COUNTRY="United States/Canada" ;;
    +91*)   COUNTRY="India" ;;
    +92*)   COUNTRY="Pakistan" ;;
    *)      COUNTRY="Unknown" ;;
esac

AUTH_HEADER=""

if [ -n "${GATEWAY_API_KEY:-}" ]; then
    AUTH_HEADER="Authorization: Bearer ${GATEWAY_API_KEY}"
fi

if [ -n "$AUTH_HEADER" ]; then

    RESPONSE=$(curl -sS \
        -X POST "$GATEWAY_URL" \
        -H "Content-Type: application/json" \
        -H "$AUTH_HEADER" \
        -d "{\"phone_number\":\"$NUMBER\"}")

else

    RESPONSE=$(curl -sS \
        -X POST "$GATEWAY_URL" \
        -H "Content-Type: application/json" \
        -d "{\"phone_number\":\"$NUMBER\"}")

fi

if ! echo "$RESPONSE" | jq empty >/dev/null 2>&1; then

    echo "🕷️ SPIDER XMD BAN CHECK

📱 Phone Number: $NUMBER
🌍 Phone Country: $COUNTRY

🚫 Ban Status: UNABLE TO VERIFY

⚠️ Gateway returned an invalid response."

    exit 0
fi

STATUS=$(echo "$RESPONSE" | jq -r '.ban_status // "UNKNOWN"')
BAN_TYPE=$(echo "$RESPONSE" | jq -r '.ban_type // "Not available"')
BAN_DATE=$(echo "$RESPONSE" | jq -r '.ban_date // "Not available"')
BAN_TIME=$(echo "$RESPONSE" | jq -r '.ban_time // "Not available"')
VIOLATION=$(echo "$RESPONSE" | jq -r '.violation_type // "Not available"')
REASON=$(echo "$RESPONSE" | jq -r '.violation_reason // "Not available"')
APPEAL=$(echo "$RESPONSE" | jq -r '.can_appeal // "Unknown"')
CREATED=$(echo "$RESPONSE" | jq -r '.appeal_created // "Unknown"')

cat <<EOF
🕷️ SPIDER XMD BAN CHECK

📱 Phone Number: $NUMBER
🌍 Phone Country: $COUNTRY

🚫 Ban Status: $STATUS
📌 Ban Type: $BAN_TYPE
📅 Ban Date: $BAN_DATE
⏰ Ban Time: $BAN_TIME

⚠️ Violation Type: $VIOLATION
📝 Violation Reason: $REASON

📨 Can Appeal: $APPEAL
📤 Appeal Created: $CREATED

━━━━━━━━━━━━━━━━━━━━
🕷️ SPIDER XMD BAN CHECK
━━━━━━━━━━━━━━━━━━━━
EOF
