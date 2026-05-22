#!/usr/bin/env bash
# refresh-diagram.sh – Drift-check architecture.mmd against the live codebase
# and emit a change summary.
#
# What it does:
#   1. Discovers component modules (components/*/go.mod → module names).
#   2. Discovers key Go source files in commands/ (non-test, non-vendor).
#   3. Checks each against node labels currently in architecture.mmd.
#   4. Prints a change-summary section suitable for a PR comment or CI step summary.
#   5. Always exits 0 – advisory only, never blocks a PR.
#
# Usage:
#   ./scripts/refresh-diagram.sh [--diagram <path>] [--components-root <path>]
#
# Env-var overrides:
#   DIAGRAM_PATH       – path to .mmd file (default: ai-track-docs/architecture.mmd)
#   COMPONENTS_ROOT    – path to components/ root (default: components/)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIAGRAM="${DIAGRAM_PATH:-${REPO_ROOT}/ai-track-docs/architecture.mmd}"
COMPONENTS="${COMPONENTS_ROOT:-${REPO_ROOT}/components}"

# ── helpers ──────────────────────────────────────────────────────────────────
in_diagram() {
  grep -qF "$1" "$DIAGRAM"
}

section() { echo ""; echo "### $*"; }
row()     { printf "  %-52s %s\n" "$1" "$2"; }

# ── 1. Discover component modules ────────────────────────────────────────────
declare -a MODULES=()
while IFS= read -r gomod; do
  dir="$(dirname "$gomod")"
  rel="${dir#"${REPO_ROOT}/"}"
  MODULES+=("$rel")
done < <(find "$COMPONENTS" -maxdepth 2 -name go.mod -not -path "*/vendor/*" | sort)

# ── 2. Discover key source files in commands/ ────────────────────────────────
declare -a CMD_FILES=()
while IFS= read -r f; do
  base="$(basename "$f")"
  CMD_FILES+=("$base")
done < <(find "$COMPONENTS" -path "*/commands/*.go" \
           -not -name "*_test.go" \
           -not -path "*/vendor/*" | sort)

# ── 3. Compute drift ─────────────────────────────────────────────────────────
declare -a MISSING_MODULES=()
declare -a PRESENT_MODULES=()
for m in "${MODULES[@]}"; do
  # Match the last path segment (e.g. "main-chef-wrapper") in the diagram
  leaf="${m##*/}"
  if in_diagram "$leaf"; then
    PRESENT_MODULES+=("$m")
  else
    MISSING_MODULES+=("$m")
  fi
done

declare -a MISSING_FILES=()
declare -a PRESENT_FILES=()
for f in "${CMD_FILES[@]}"; do
  # Strip extension for fuzzy match
  stem="${f%.go}"
  if in_diagram "$stem"; then
    PRESENT_FILES+=("$f")
  else
    MISSING_FILES+=("$f")
  fi
done

# ── 4. Emit change summary ────────────────────────────────────────────────────
echo "# Architecture Diagram – Drift Report"
echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Diagram  : ${DIAGRAM#"${REPO_ROOT}/"}"
echo ""

section "Component modules vs diagram nodes"
row "Module path" "In diagram?"
row "$(printf '%0.s-' {1..52})" "$(printf '%0.s-' {1..10})"
for m in "${PRESENT_MODULES[@]+"${PRESENT_MODULES[@]}"}"; do  row "$m" "✓ matched"; done
for m in "${MISSING_MODULES[@]+"${MISSING_MODULES[@]}"}"; do  row "$m" "✗ MISSING"; done

section "commands/ source files vs diagram nodes"
row "File" "In diagram?"
row "$(printf '%0.s-' {1..52})" "$(printf '%0.s-' {1..10})"
for f in "${PRESENT_FILES[@]+"${PRESENT_FILES[@]}"}"; do  row "$f" "✓ matched"; done
for f in "${MISSING_FILES[@]+"${MISSING_FILES[@]}"}"; do  row "$f" "✗ MISSING"; done

echo ""
echo "### Summary"
echo "  Component modules  : ${#PRESENT_MODULES[@]} matched, ${#MISSING_MODULES[@]} missing from diagram"
echo "  commands/ files    : ${#PRESENT_FILES[@]} matched, ${#MISSING_FILES[@]} missing from diagram"

TOTAL_MISSING=$(( ${#MISSING_MODULES[@]} + ${#MISSING_FILES[@]} ))
if [[ $TOTAL_MISSING -gt 0 ]]; then
  echo ""
  echo "  ⚠  $TOTAL_MISSING item(s) found in the codebase but not reflected in the diagram."
  echo "     Update ai-track-docs/architecture.mmd and re-run this script to clear drift."
else
  echo ""
  echo "  ✓  No drift detected – diagram is current."
fi

# Always advisory – never block.
exit 0
