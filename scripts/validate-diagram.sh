#!/usr/bin/env bash
# validate-diagram.sh – verify architecture.mmd renders without errors.
# Usage: ./scripts/validate-diagram.sh
#
# Strategy:
#   1. If mmdc (Mermaid CLI) is available, render to a temp PNG and check exit code.
#   2. Otherwise fall back to a lightweight grep-based syntax check that verifies
#      the required structural keywords are present.

set -euo pipefail

DIAGRAM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/ai-track-docs/architecture.mmd"

if [[ ! -f "$DIAGRAM" ]]; then
  echo "ERROR: diagram not found at $DIAGRAM" >&2
  exit 1
fi

echo "==> Validating $DIAGRAM"

# ── Strategy 1: mmdc render ──────────────────────────────────────────
if command -v mmdc >/dev/null 2>&1; then
  echo "==> mmdc found – rendering diagram to temp file"
  TMPOUT="$(mktemp /tmp/arch-render-XXXXXX.png)"
  if mmdc -i "$DIAGRAM" -o "$TMPOUT" 2>&1; then
    echo "==> mmdc render PASSED"
    rm -f "$TMPOUT"
    exit 0
  else
    echo "==> mmdc render failed; retrying with --no-sandbox Chromium args"
    PUPPETEER_CFG="$(mktemp /tmp/mmdc-puppeteer-XXXXXX.json)"
    cat >"$PUPPETEER_CFG" <<'EOF'
{
  "args": ["--no-sandbox", "--disable-setuid-sandbox"]
}
EOF
    if mmdc -p "$PUPPETEER_CFG" -i "$DIAGRAM" -o "$TMPOUT" 2>&1; then
      echo "==> mmdc render PASSED (no-sandbox retry)"
      rm -f "$TMPOUT" "$PUPPETEER_CFG"
      exit 0
    fi

    echo "ERROR: mmdc render FAILED" >&2
    rm -f "$TMPOUT" "$PUPPETEER_CFG"
    exit 1
  fi
fi

# ── Strategy 2: lightweight syntax checks ────────────────────────────
echo "==> mmdc not found – running lightweight syntax checks"
FAIL=0

check() {
  local desc="$1"
  local pattern="$2"
  if grep -qE "$pattern" "$DIAGRAM"; then
    echo "  [PASS] $desc"
  else
    echo "  [FAIL] $desc (pattern: $pattern)" >&2
    FAIL=1
  fi
}

check "graph directive present"         "^graph (TD|LR|BT|RL)"
check "at least one subgraph"           "^[[:space:]]*subgraph "
check "at least one node label"         "\[\"[^\"]+\""
check "at least one dependency arrow"   " -->"
check "at least one data-flow arrow"    " -\.->"
check "file path reference in node"     "components/"

if [[ $FAIL -eq 0 ]]; then
  echo "==> Syntax checks PASSED"
  exit 0
else
  echo "==> Syntax checks FAILED – fix diagram before merging" >&2
  exit 1
fi
