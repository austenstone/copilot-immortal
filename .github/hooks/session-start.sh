#!/bin/bash
# SessionStart hook — inject live workspace context at session start.
# Outputs git branch, date, and dirty file count.

WORKSPACE="$(pwd)"
PARTS=()

BRANCH=$(git -C "$WORKSPACE" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$BRANCH" ] && PARTS+=("Branch: $BRANCH")

TODAY=$(date +%Y-%m-%d)
PARTS+=("Date: $TODAY")

DIRTY=$(git -C "$WORKSPACE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "$DIRTY" -gt 0 ] && PARTS+=("Uncommitted changes: $DIRTY files")

CONTEXT="${PARTS[0]}"
for ((i=1; i<${#PARTS[@]}; i++)); do
  CONTEXT="$CONTEXT | ${PARTS[$i]}"
done

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
