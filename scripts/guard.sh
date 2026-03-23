#!/bin/bash
# PreToolUse hook — block dangerous terminal commands.
#
# Checks run_in_terminal invocations for destructive patterns:
# - rm -rf (recursive force delete)
# - git push --force / git push -f
# - git reset --hard
# - DROP TABLE / DROP DATABASE

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

# Only check terminal commands
if [ "$TOOL_NAME" != "run_in_terminal" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    print(ti.get('command', ''))
except:
    print('')
" 2>/dev/null)

BLOCKED=""

if echo "$COMMAND" | grep -qiE 'rm\s+(-[a-z]*r[a-z]*f|--recursive.*--force|-[a-z]*f[a-z]*r)'; then
  BLOCKED="Recursive force delete (rm -rf) blocked by safety hook"
fi

if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*(-f|--force)'; then
  BLOCKED="Force push (git push --force) blocked by safety hook"
fi

if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard'; then
  BLOCKED="Hard reset (git reset --hard) blocked by safety hook"
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE)'; then
  BLOCKED="DROP statement blocked by safety hook"
fi

if [ -n "$BLOCKED" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$BLOCKED"
  }
}
EOF
  exit 0
fi

# Safe — let it through
exit 0
