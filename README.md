# copilot-immortal

Make GitHub Copilot run forever.

A set of [VS Code Copilot hooks](https://code.visualstudio.com/docs/copilot/copilot-extensibility-overview#_agent-hooks) that turn your AI agent into an always-on assistant. The agent never stops — it works, sleeps, wakes up, and works again in a continuous loop.

## How it works

The **Stop hook** is the core trick. Every time Copilot tries to stop, the hook blocks it and says "keep going." The agent does useful work, sleeps for a configurable interval, then wakes up to the next cycle.

```
You ──► Start Copilot ──► Agent works ──► Agent tries to stop
                                                    │
                                          Stop hook blocks it
                                                    │
                                          "Do more work, then sleep"
                                                    │
                                          Agent works ──► sleep N ──► repeat ♾️
```

## Quick start

### 1. Copy hooks into your project

```bash
cp -r .github/hooks/ <your-project>/.github/hooks/
chmod +x <your-project>/.github/hooks/*.sh
```

### 2. Set the environment variable

Add to your shell profile (`.zshrc`, `.bashrc`, etc.):

```bash
export COPILOT_HEARTBEAT_INTERVAL=120  # seconds between cycles
```

Without this variable set, the hooks are dormant — Copilot behaves normally.

### 3. (Optional) Add a HEARTBEAT.md

Drop a `HEARTBEAT.md` in your workspace root to control what the agent does each cycle:

```markdown
# Heartbeat

You are an always-on assistant for this project.

## Each cycle

1. Check for failing tests and fix them
2. Look for TODO comments and address them
3. Review open issues and suggest fixes
4. Clean up code style issues
5. Update documentation if code changed
```

Without a `HEARTBEAT.md`, the agent uses a generic "find useful work" prompt.

## Hooks included

| Hook | File | What it does |
|------|------|-------------|
| **Stop** | `heartbeat.sh` | Blocks the agent from stopping. Injects workspace context (git branch, dirty files, cycle count) and instructions from `HEARTBEAT.md`. This is what makes Copilot immortal. |
| **SessionStart** | `context.sh` | Injects git branch, date, and uncommitted file count at session start. |
| **PreCompact** | `persist.sh` | Prompts the agent to save important context to memory before VS Code compacts the conversation. |
| **PreToolUse** | `guard.sh` | Blocks dangerous terminal commands: `rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE`. |

## Configuration

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COPILOT_HEARTBEAT_INTERVAL` | _(unset)_ | Seconds between heartbeat cycles. **Must be set to enable immortal mode.** When unset, all hooks pass through normally. |

### HEARTBEAT.md

The `HEARTBEAT.md` file in your workspace root is your control surface. Write instructions in natural language — the agent reads it every cycle. You can change it while the agent is running and it'll pick up the new instructions on the next cycle.

See [HEARTBEAT.md](HEARTBEAT.md) for an example.

## How to stop

Three ways:

1. **Unset the env var** — remove `COPILOT_HEARTBEAT_INTERVAL` from your environment and restart VS Code
2. **Close the chat** — closing the Copilot chat panel kills the session
3. **Temporarily** — the agent will naturally pause during its sleep interval; you can interact normally during that window

## Requirements

- VS Code with GitHub Copilot (agent mode)
- `bash`, `python3`, `git` on PATH
- Copilot hooks support (VS Code Insiders or latest stable)

## License

MIT
