#!/usr/bin/env bash

set -e

echo "🕷️ SPIDER XMD"
echo "🌐 Starting gateway..."

PORT="${PORT:-10000}"

exec bash gateway.sh
