#!/usr/bin/env bash

set -euo pipefail

PORT="${PORT:-8000}"

echo "🕷️ Spider XMD Gateway"
echo "🌐 Port: $PORT"

python3 -m http.server "$PORT"
