#!/bin/bash
# PreCompact hook — prompt the agent to save context before compaction.
#
# When VS Code compacts the conversation, important context can be lost.
# This hook tells the agent to persist anything important first.

INPUT=$(cat)
TODAY=$(date +%Y-%m-%d)

cat <<EOF
{
  "systemMessage": "Context compaction is imminent. Before the conversation is truncated, save any important findings or task state using the memory tool:\n\n1. Save important discoveries to /memories/repo/ (patterns, insights, gotchas)\n2. Update /memories/session/ with current task state\n3. Note any in-progress work that needs to survive compaction\n\nIf nothing worth saving, skip silently."
}
EOF
