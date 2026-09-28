#!/usr/bin/env bash
set -u

# ╔══════════════════════════════════════════════╗
# ║          🕷️ SPIDER XMD PREMIUM              ║
# ║              TELEGRAM CORE                  ║
# ╚══════════════════════════════════════════════╝

BOT_TOKEN="${BOT_TOKEN:-}"
GATEWAY_URL="${GATEWAY_URL:-}"
START_TIME=$(date +%s)
OFFSET=0

if [[ -z "$BOT_TOKEN" ]]; then
    echo "❌ BOT_TOKEN is missing"
    exit 1
fi

command -v curl >/dev/null 2>&1 || {
    echo "❌ curl is required"
    exit 1
}

command -v jq >/dev/null 2>&1 || {
    echo "❌ jq is required"
    exit 1
}

API="https://api.telegram.org/bot${BOT_TOKEN}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOGGING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S UTC')] $*"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TELEGRAM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

telegram() {
    local method="$1"
    shift

    curl -sS \
        --max-time 25 \
        -X POST "${API}/${method}" \
        "$@"
}

send_message() {
    local chat_id="$1"
    local text="$2"

    telegram "sendMessage" \
        -d "chat_id=${chat_id}" \
        --data-urlencode "text=${text}" \
        -d "parse_mode=HTML" \
        >/dev/null
}

send_typing() {
    local chat_id="$1"

    telegram "sendChatAction" \
        -d "chat_id=${chat_id}" \
        -d "action=typing" \
        >/dev/null
}

answer_callback() {
    local callback_id="$1"

    telegram "answerCallbackQuery" \
        -d "callback_query_id=${callback_id}" \
        >/dev/null
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAIN PREMIUM MENU
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

send_menu() {
    local chat_id="$1"

    local keyboard='{
        "inline_keyboard": [
            [
                {
                    "text":"🔎 CHECK",
                    "callback_data":"check"
                },
                {
                    "text":"📚 HELP",
                    "callback_data":"help"
                }
            ],
            [
                {
                    "text":"⚡ STATUS",
                    "callback_data":"status"
                },
                {
                    "text":"📊 STATS",
                    "callback_data":"stats"
                }
            ],
            [
                {
                    "text":"🆔 MY ID",
                    "callback_data":"id"
                },
                {
                    "text":"ℹ️ ABOUT",
                    "callback_data":"about"
                }
            ]
        ]
    }'

    telegram "sendMessage" \
        -d "chat_id=${chat_id}" \
        --data-urlencode "text=<b>╭━━━━━━━━━━━━━━━━━━━━━━╮
   🕷️ SPIDER XMD PREMIUM
╰━━━━━━━━━━━━━━━━━━━━━━╯</b>

👋 <b>Welcome to Spider XMD</b>

⚡ Premium Telegram interface
🔎 Authorized number checking
📡 Gateway integration
🛡️ Safe response handling
📊 Runtime monitoring

<b>Choose an option:</b>" \
        -d "parse_mode=HTML" \
        --data-urlencode "reply_markup=${keyboard}" \
        >/dev/null
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HELP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_help() {
    local chat_id="$1"

    send_message "$chat_id" \
"<b>╭━━━━━━━━━━━━━━━━━━━━━━╮
   📚 SPIDER XMD HELP
╰━━━━━━━━━━━━━━━━━━━━━━╯</b>

<b>🚀 CORE</b>
/start
/menu
/help
/ping
/id

<b>🔎 CHECKER</b>
/check +2348012345678

<b>📊 SYSTEM</b>
/status
/stats
/version

<b>ℹ️ INFO</b>
/about

Use /start for the interactive menu."
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UPTIME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

get_uptime() {
    local now
    local elapsed

    now=$(date +%s)
    elapsed=$((now - START_TIME))

    local days=$((elapsed / 86400))
    local hours=$(((elapsed % 86400) / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    local seconds=$((elapsed % 60))

    printf "%sd %sh %sm %ss" \
        "$days" "$hours" "$minutes" "$seconds"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STATUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_status() {
    local chat_id="$1"

    local gateway_status="NOT CONFIGURED"

    if [[ -n "$GATEWAY_URL" ]]; then
        if curl -sS \
            --max-time 5 \
            "$GATEWAY_URL" \
            >/dev/null 2>&1; then
            gateway_status="REACHABLE"
        else
            gateway_status="UNREACHABLE"
        fi
    fi

    send_message "$chat_id" \
"<b>╭━━━━━━━━━━━━━━━━━━━━━━╮
   ⚡ SPIDER SYSTEM
╰━━━━━━━━━━━━━━━━━━━━━━╯</b>

🤖 Telegram Bot: <b>ONLINE</b>
📡 Polling: <b>ACTIVE</b>
🌐 Gateway: <b>${gateway_status}</b>
🕷️ Engine: <b>ACTIVE</b>

⏱️ Uptime:
<code>$(get_uptime)</code>

🕒 $(date '+%Y-%m-%d %H:%M:%S UTC')"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STATS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_stats() {
    local chat_id="$1"

    local pid
    pid="$$"

    send_message "$chat_id" \
"<b>╭━━━━━━━━━━━━━━━━━━━━━━╮
   📊 SPIDER STATISTICS
╰━━━━━━━━━━━━━━━━━━━━━━╯</b>

🧠 Process ID:
<code>${pid}</code>

⏱️ Uptime:
<code>$(get_uptime)</code>

🐚 Runtime:
<code>Bash</code>

📡 Polling:
<code>Long Polling</code>

🕷️ Version:
<code>Spider XMD Premium</code>"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ABOUT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_about() {
    local chat_id="$1"

    send_message "$chat_id" \
"<b>╭━━━━━━━━━━━━━━━━━━━━━━╮
   🕷️ SPIDER XMD
╰━━━━━━━━━━━━━━━━━━━━━━╯</b>

<b>Premium Telegram Engine</b>

⚡ Shell powered
📡 Gateway ready
🔎 Authorized checking
🛡️ Safe API handling
📊 Runtime monitoring

<b>Edition:</b> Premium
<b>Engine:</b> Spider Core"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

run_check() {
    local chat_id="$1"
    local number="$2"

    number="$(echo "$number" | xargs)"

    if [[ -z "$number" ]]; then
        send_message "$chat_id" \
"<b>❌ NUMBER REQUIRED</b>

Example:

<code>/check +2348012345678</code>"
        return
    fi

    if [[ ! "$number" =~ ^\+[0-9]{7,15}$ ]]; then
        send_message "$chat_id" \
"<b>❌ INVALID NUMBER</b>

Use international format:

<code>/check +2348012345678</code>"
        return
    fi

    send_typing "$chat_id"

    send_message "$chat_id" \
"<b>🔎 SPIDER XMD CHECK</b>

📱 Number:
<code>${number}</code>

⏳ Processing request..."

    if [[ ! -f "./checker.sh" ]]; then
        send_message "$chat_id" \
"<b>❌ CHECKER UNAVAILABLE</b>

<code>checker.sh</code> was not found."
        return
    fi

    if [[ ! -x "./checker.sh" ]]; then
        chmod +x ./checker.sh 2>/dev/null || true
    fi

    local result

    if result=$(bash ./checker.sh "$number" 2>&1); then
        send_message "$chat_id" "$result"
    else
        log "Checker failed for ${number}"

        send_message "$chat_id" \
"<b>⚠️ CHECK FAILED</b>

The authorized gateway did not return a valid response.

Please try again later."
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CALLBACK ROUTER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

handle_callback() {
    local update="$1"

    local callback_id
    local callback_data
    local chat_id

    callback_id=$(echo "$update" |
        jq -r '.callback_query.id // empty')

    callback_data=$(echo "$update" |
        jq -r '.callback_query.data // empty')

    chat_id=$(echo "$update" |
        jq -r '.callback_query.message.chat.id // empty')

    [[ -z "$callback_id" ]] && return
    [[ -z "$chat_id" ]] && return

    answer_callback "$callback_id"

    case "$callback_data" in

        check)
            send_message "$chat_id" \
"<b>🔎 NUMBER CHECKER</b>

Use:

<code>/check +2348012345678</code>

Only information returned by your authorized gateway is displayed."
            ;;

        help)
            show_help "$chat_id"
            ;;

        status)
            show_status "$chat_id"
            ;;

        stats)
            show_stats "$chat_id"
            ;;

        id)
            send_message "$chat_id" \
"<b>🆔 TELEGRAM ID</b>

Your ID:

<code>${chat_id}</code>"
            ;;

        about)
            show_about "$chat_id"
            ;;

        *)
            send_message "$chat_id" \
"❌ Unknown menu action."
            ;;

    esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MESSAGE ROUTER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

handle_message() {
    local update="$1"

    local chat_id
    local text

    chat_id=$(echo "$update" |
        jq -r '.message.chat.id // empty')

    text=$(echo "$update" |
        jq -r '.message.text // empty')

    [[ -z "$chat_id" ]] && return
    [[ -z "$text" ]] && return

    log "Message from ${chat_id}: ${text}"

    case "$text" in

        /start|/start@*)
            send_menu "$chat_id"
            ;;

        /menu|/menu@*)
            send_menu "$chat_id"
            ;;

        /help|/help@*)
            show_help "$chat_id"
            ;;

        /ping|/ping@*)
            send_message "$chat_id" \
"<b>🏓 PONG!</b>

🟢 Spider XMD is responding.

⚡ Engine: ACTIVE
📡 Telegram: CONNECTED
🕷️ Core: RUNNING

🕒 $(date '+%Y-%m-%d %H:%M:%S UTC')"
            ;;

        /id|/id@*)
            send_message "$chat_id" \
"<b>🆔 YOUR TELEGRAM ID</b>

<code>${chat_id}</code>"
            ;;

        /status|/status@*)
            show_status "$chat_id"
            ;;

        /stats|/stats@*)
            show_stats "$chat_id"
            ;;

        /version|/version@*)
            send_message "$chat_id" \
"<b>🕷️ SPIDER XMD VERSION</b>

Edition:
<code>Premium</code>

Engine:
<code>Spider Core</code>

Runtime:
<code>Bash</code>"
            ;;

        /about|/about@*)
            show_about "$chat_id"
            ;;

        /check\ *)
            local number="${text#/check }"
            run_check "$chat_id" "$number"
            ;;

        /check)
            run_check "$chat_id" ""
            ;;

        *)
            send_message "$chat_id" \
"<b>🕷️ SPIDER XMD</b>

Unknown command.

Use:

<code>/start</code>

to open the Premium menu."
            ;;

    esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STARTUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log "╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮"
log "│ 🕷️ SPIDER XMD PREMIUM       │"
log "│ 🤖 Telegram Engine ACTIVE   │"
log "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LONG POLLING ENGINE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

while true; do

    RESPONSE=$(curl -sS \
        --max-time 45 \
        "${API}/getUpdates?timeout=30&offset=${OFFSET}" \
        2>/dev/null || true)

    if [[ -z "$RESPONSE" ]]; then
        log "⚠️ Empty Telegram response"
        sleep 5
        continue
    fi

    if ! echo "$RESPONSE" |
        jq -e '.ok == true' >/dev/null 2>&1; then

        log "❌ Telegram API error:"
        echo "$RESPONSE"

        sleep 5
        continue
    fi

    while IFS= read -r UPDATE; do

        [[ -z "$UPDATE" ]] && continue

        UPDATE_ID=$(echo "$UPDATE" |
            jq -r '.update_id // empty')

        if [[ -n "$UPDATE_ID" ]]; then
            OFFSET=$((UPDATE_ID + 1))
        fi

        if echo "$UPDATE" |
            jq -e '.callback_query' >/dev/null 2>&1; then

            handle_callback "$UPDATE"

        elif echo "$UPDATE" |
            jq -e '.message' >/dev/null 2>&1; then

            handle_message "$UPDATE"

        fi

    done < <(
        echo "$RESPONSE" |
        jq -c '.result[]?'
    )

done
