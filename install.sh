#!/usr/bin/env bash

set -e

echo "🕷️ Installing Spider XMD..."

if command -v apt-get >/dev/null 2>&1; then

    sudo apt-get update

    sudo apt-get install -y \
        curl \
        jq \
        python3

elif command -v pkg >/dev/null 2>&1; then

    pkg update -y

    pkg install -y \
        curl \
        jq \
        python

else

    echo "⚠️ Install curl, jq and Python 3 manually."
fi

chmod +x \
    bot.sh \
    checker.sh \
    gateway.sh \
    config.sh \
    install.sh

echo ""
echo "✅ Installation complete."
echo ""
echo "Set BOT_TOKEN in .env/config.sh"
echo "Then run:"
echo "./bot.sh"
