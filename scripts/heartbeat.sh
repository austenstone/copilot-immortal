#!/bin/bash
# Immortal heartbeat — makes Copilot run forever.
#
# The Stop hook fires every time the agent tries to stop. This script
# sleeps for COPILOT_HEARTBEAT_INTERVAL seconds (controlled by timeoutSec
# in hooks.json so VS Code won't kill the process), then blocks the stop
# and tells the agent to keep working. No agent tool calls wasted on sleeping.
#
# Set COPILOT_HEARTBEAT_INTERVAL (seconds) to enable. Unset = normal stop.
# Customize behavior with a HEARTBEAT.md file in your workspace root.

# If COPILOT_HEARTBEAT_INTERVAL is not set, let the agent stop normally
if [ -z "${COPILOT_HEARTBEAT_INTERVAL+x}" ]; then
  cat <<EOF
{"decision": "allow"}
EOF
  exit 0
fi

INPUT=$(cat)
WORKSPACE="$(pwd)"
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M:%S)
BRANCH=$(git -C "$WORKSPACE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# --- Cycle counter (tracks heartbeats this session) ---
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id','default'))" 2>/dev/null || echo "default")
CYCLE_FILE="/tmp/copilot-heartbeat-${SESSION_ID}"
CYCLE=0
[ -f "$CYCLE_FILE" ] && CYCLE=$(cat "$CYCLE_FILE" 2>/dev/null || echo 0)
CYCLE=$((CYCLE + 1))
echo "$CYCLE" > "$CYCLE_FILE"

# --- Interval from env (default 120s) ---
HEARTBEAT_INTERVAL="${COPILOT_HEARTBEAT_INTERVAL:-120}"

# --- Workspace signals ---
DIRTY=$(git -C "$WORKSPACE" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# --- Build context ---
CONTEXT_LINES=""
CONTEXT_LINES="${CONTEXT_LINES}\n- Time: $TODAY $NOW | Cycle: #$CYCLE"
CONTEXT_LINES="${CONTEXT_LINES}\n- Branch: $BRANCH"
[ "$DIRTY" -gt 0 ] && CONTEXT_LINES="${CONTEXT_LINES}\n- $DIRTY uncommitted file(s)"
CONTEXT_LINES="${CONTEXT_LINES}\n- Interval: ${HEARTBEAT_INTERVAL}s"

LAST_COMMIT_AGO=$(git -C "$WORKSPACE" log -1 --format="%cr" 2>/dev/null)
[ -n "$LAST_COMMIT_AGO" ] && CONTEXT_LINES="${CONTEXT_LINES}\n- Last commit: $LAST_COMMIT_AGO"

CONTEXT_ESCAPED=$(echo -e "$CONTEXT_LINES" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read())[1:-1])")

# --- Read HEARTBEAT.md if present ---
HEARTBEAT_INSTRUCTIONS=""
if [ -f "$WORKSPACE/HEARTBEAT.md" ]; then
  HEARTBEAT_INSTRUCTIONS=$(python3 -c "import sys,json; print(json.dumps(open('$WORKSPACE/HEARTBEAT.md').read())[1:-1])")
fi

# --- Build the prompt ---
if [ -n "$HEARTBEAT_INSTRUCTIONS" ]; then
  TASK_PROMPT="$HEARTBEAT_INSTRUCTIONS"
else
  TASK_PROMPT="You are in heartbeat mode. Look for useful work to do in this workspace — fix issues, run tests, clean up code, update docs."
fi

# --- Sleep in the hook so the agent doesn't have to ---
if [ "$HEARTBEAT_INTERVAL" -gt 0 ] 2>/dev/null; then
  sleep "$HEARTBEAT_INTERVAL"
fi

cat <<EOF
{
  "decision": "block",
  "reason": "Heartbeat #${CYCLE}.\n\nWorkspace:${CONTEXT_ESCAPED}\n\n${TASK_PROMPT}",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "decision": "block",
    "reason": "Heartbeat #${CYCLE}"
  }
}
EOF
