#!/usr/bin/env bash

set -e

PORT="${PORT:-10000}"

echo "🕷️ Spider XMD Gateway"
echo "📡 Port: $PORT"

# Start your authorized gateway service here.
# The process must listen on 0.0.0.0:$PORT.

exec python3 -m http.server "$PORT" --bind 0.0.0.0
