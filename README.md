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

</div>

## Install

### Copilot CLI

```bash
copilot plugin install austenstone/copilot-immortal
```

### VS Code

Run **Chat: Install Plugin From Source** from the Command Palette, enter:

```
https://github.com/austenstone/copilot-immortal
```

Or add the marketplace to your settings:

```json
"chat.plugins.marketplaces": ["austenstone/copilot-immortal"]
```

> Requires `chat.plugins.enabled: true` (preview).

You now have an `@immortal` agent that never stops.

## How it works

The [Stop hook](https://code.visualstudio.com/docs/copilot/customization/hooks) fires every time the agent tries to stop. This plugin blocks it and says "keep going." The agent works, sleeps, wakes up, repeats.

```
start → work → tries to stop → BLOCKED → work → sleep → repeat ♾️
```

## What's included

| File | Purpose |
|------|---------|
| `heartbeat.sh` | Blocks stop, injects workspace context |
| `context.sh` | Injects git branch + date at session start |
| `persist.sh` | Saves context before conversation compaction |
| `guard.sh` | Blocks `rm -rf`, `git push --force`, `git reset --hard` |
| `agents/immortal.agent.md` | Ready-to-use always-on agent |

## Configuration

Drop a `HEARTBEAT.md` in your workspace root to control what the agent does each cycle. Change it live — picks up new instructions on the next heartbeat.

## Stopping

Close the chat panel, or uninstall:

```bash
copilot plugin uninstall copilot-immortal
```

## License

MIT

## License

MIT
