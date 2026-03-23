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

The recommended approach is **agent-scoped hooks** — this makes a specific [custom agent](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents) immortal while your normal Copilot usage stays normal. Workspace or user-level hooks will make *all* Copilot agents loop forever, which is probably not what you want.

| Scope | Location | Effect |
|-------|----------|--------|
| **Custom agent** (recommended) | `hooks` field in `.agent.md` frontmatter | Only that agent runs forever |
| **Workspace** | `.github/hooks/hooks.json` | All agents in this workspace run forever |
| **User** | `~/.copilot/hooks/hooks.json` | All agents everywhere run forever |

### Option A: Custom agent hooks (recommended)

Create a [custom agent](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents) `.agent.md` file with hooks in the YAML frontmatter. The agent runs forever; your default Copilot stays normal.

First, enable agent-scoped hooks in VS Code settings:

```json
"chat.useCustomAgentHooks": true
```

Then create `.github/agents/immortal.agent.md`:

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

The `COPILOT_HEARTBEAT_INTERVAL` is set via the `env` field in the frontmatter — no shell profile needed. Agent-scoped hooks run *in addition to* any workspace or user-level hooks for the same event.

Copy the hook scripts into your project:

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

### Option B: Workspace hooks

Apply to all agents in a workspace. Every Copilot session will loop forever.

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

Set the env var in your shell profile:

```bash
export COPILOT_HEARTBEAT_INTERVAL=120  # seconds between cycles
```

### Option C: User-level hooks

Apply across all workspaces globally:

```bash
mkdir -p ~/.copilot/hooks
cp .github/hooks/* ~/.copilot/hooks/
chmod +x ~/.copilot/hooks/*.sh
```

### (Optional) Add a `HEARTBEAT.md`

Drop one in your workspace root. The agent reads it every cycle:

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

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `COPILOT_HEARTBEAT_INTERVAL` | _(unset)_ | Seconds between cycles. Must be set to enable. |

### `HEARTBEAT.md`

Your control surface. Natural language instructions read every cycle. Change it live — the agent picks up new instructions on the next heartbeat.

See [HEARTBEAT.md](HEARTBEAT.md) for an example.

## Stopping

- **Unset the env var** and restart VS Code
- **Close the chat panel**
- **Wait for sleep** — interact normally during the pause

## Requirements

- VS Code + GitHub Copilot (agent mode)
- `bash`, `python3`, `git`

## License

MIT
