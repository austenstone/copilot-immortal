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

Hooks can be installed in [several locations](https://code.visualstudio.com/docs/copilot/customization/hooks) depending on what scope you want:

| Scope | Location |
|-------|----------|
| **Workspace** | `.github/hooks/hooks.json` |
| **User** | `~/.copilot/hooks/hooks.json` |
| **Custom agent** | `hooks` field in `.agent.md` frontmatter |

### Option A: Workspace hooks (most common)

Copy the hooks into your project so they apply to all agents in that workspace:

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

### Option B: Custom agent hooks

Wire hooks directly into a [custom agent](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents) `.agent.md` file. This lets you make a specific agent immortal while others behave normally:

```yaml
---
name: my-immortal-agent
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
---

You are an always-on assistant. Follow the instructions in HEARTBEAT.md each cycle.
```

Note: when hooks are defined in the agent frontmatter, the `COPILOT_HEARTBEAT_INTERVAL` env var is set per-agent via the `env` field — no shell profile needed.

### Option C: User-level hooks

Install globally so they apply across all workspaces:

```bash
mkdir -p ~/.copilot/hooks
cp .github/hooks/* ~/.copilot/hooks/
chmod +x ~/.copilot/hooks/*.sh
```

### Enable immortal mode

Set the env var (unless using agent-scoped `env`):

```bash
# Add to .zshrc / .bashrc
export COPILOT_HEARTBEAT_INTERVAL=120  # seconds between cycles
```

No env var = normal Copilot. Set it = immortal mode.

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
