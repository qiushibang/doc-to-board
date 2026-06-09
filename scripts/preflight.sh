#!/usr/bin/env bash
# doc-to-board 依赖检查
set -u
ok=1
echo "▶ Checking prerequisites for doc-to-board…"
echo

# Node ≥ 20
if command -v node >/dev/null 2>&1; then
  node_version=$(node -v | sed 's/v//' | cut -d. -f1)
  if [ "$node_version" -ge 20 ]; then
    echo "  ✓ Node $(node -v)"
  else
    echo "  ✗ Node ≥ 20 required (found $(node -v))"
    ok=0
  fi
else
  echo "  ✗ Node.js not found — install Node ≥ 20"
  ok=0
fi

# lark-cli
if command -v lark-cli >/dev/null 2>&1; then
  echo "  ✓ lark-cli ($(lark-cli --version 2>/dev/null | head -1))"
  if lark-cli auth status >/dev/null 2>&1; then
    echo "  ✓ lark-cli authenticated"
  else
    echo "  ! lark-cli may not be authenticated. Run:"
    echo "        lark-cli config init && lark-cli auth login"
    ok=0
  fi
else
  echo "  ✗ lark-cli not found. Install:"
  echo "        npm install -g @larksuite/cli"
  echo "        lark-cli config init && lark-cli auth login"
  ok=0
fi

# whiteboard-cli (npx)
echo "  ✓ @larksuite/whiteboard-cli (via npx, auto-download)"

echo
if [ "$ok" = 1 ]; then
  echo "✅ doc-to-board ready."
else
  echo "❌ Missing prerequisites. Fix above, then re-run."
  exit 1
fi
