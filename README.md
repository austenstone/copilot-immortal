<div align="center">

```
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║   ♾️  copilot-immortal                ║
    ║                                       ║
    ║   Make GitHub Copilot run forever.    ║
    ║                                       ║
    ╚═══════════════════════════════════════╝

         work → sleep → work → sleep → ∞
```

**One env var. Four shell scripts. Copilot never stops.**

[How it works](#how-it-works) · [Setup](#setup) · [Configuration](#configuration)

</div>

---

## How it works

[VS Code Copilot hooks](https://code.visualstudio.com/docs/copilot/customization/hooks) let you intercept agent lifecycle events. The **Stop** hook fires every time the agent tries to stop. This repo blocks that event and tells the agent to keep working.

```
start → agent works → tries to stop → BLOCKED → works more → sleeps → repeats ♾️
```

That's it. The agent loops forever. You control what it does each cycle with a `HEARTBEAT.md` file.

## Setup

Copy the hook scripts into your project:

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

Then pick where to wire them up:

| Scope | Location | Effect |
|-------|----------|--------|
| **Custom agent** | `hooks` in [`.agent.md`](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents) frontmatter | Only that agent loops (recommended) |
| **Workspace** | `.github/hooks/hooks.json` | All agents in this workspace loop |
| **User** | `~/.copilot/hooks/hooks.json` | All agents everywhere loop |

### Custom agent (recommended)

Requires `"chat.useCustomAgentHooks": true` in VS Code settings.

Create `.github/agents/immortal.agent.md`:

```yaml
---
name: immortal
description: "An always-on assistant that never stops"
hooks:
  SessionStart:
    - type: command
      command: ".github/hooks/context.sh"
  Stop:
    - type: command
      command: ".github/hooks/heartbeat.sh"
      env:
        COPILOT_HEARTBEAT_INTERVAL: "120"
  PreCompact:
    - type: command
      command: ".github/hooks/persist.sh"
  PreToolUse:
    - type: command
      command: ".github/hooks/guard.sh"
---

You are an always-on assistant. Follow the instructions in HEARTBEAT.md each cycle.
```

The `env` field sets `COPILOT_HEARTBEAT_INTERVAL` per-agent. Your normal Copilot stays normal.

### `HEARTBEAT.md` (optional)

Drop one in your workspace root to control what the agent does each cycle:

```markdown
# Heartbeat

Each cycle:
1. Run tests, fix failures
2. Address TODO/FIXME comments
3. Clean up code
4. Update docs
```

## Hooks

| Hook | Script | Purpose |
|------|--------|---------|
| **Stop** | `heartbeat.sh` | Blocks stop, injects context, reads `HEARTBEAT.md` |
| **SessionStart** | `context.sh` | Injects git branch + date + dirty files |
| **PreCompact** | `persist.sh` | Saves context before conversation compaction |
| **PreToolUse** | `guard.sh` | Blocks `rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE` |

## Stopping

- Close the chat panel
- Remove the `COPILOT_HEARTBEAT_INTERVAL` env from the agent/hooks config

## Requirements

- VS Code + GitHub Copilot (agent mode)
- `bash`, `python3`, `git`

## License

MIT
