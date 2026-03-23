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

[How it works](#how-it-works) · [Quick start](#quick-start) · [Configuration](#configuration)

</div>

---

## How it works

[VS Code Copilot hooks](https://code.visualstudio.com/docs/copilot/copilot-extensibility-overview#_agent-hooks) let you intercept agent lifecycle events. The **Stop** hook fires every time the agent tries to stop. This repo blocks that event and tells the agent to keep working.

```
start → agent works → tries to stop → BLOCKED → works more → sleeps → repeats ♾️
```

That's it. The agent loops forever. You control what it does each cycle with a `HEARTBEAT.md` file.

## Quick start

**1. Copy the hooks**

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

**2. Set the env var**

```bash
# Add to .zshrc / .bashrc
export COPILOT_HEARTBEAT_INTERVAL=120  # seconds between cycles
```

No env var = normal Copilot. Set it = immortal mode.

**3. (Optional) Add a `HEARTBEAT.md`**

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
