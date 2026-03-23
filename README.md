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

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Agent-0098FF?style=for-the-badge&logo=visualstudiocode&logoColor=white)](vscode:chat-agent/install?url=https://raw.githubusercontent.com/austenstone/copilot-immortal/main/agents/immortal.agent.md)
[![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install_Agent-24bfa5?style=for-the-badge&logo=visualstudiocode&logoColor=white)](vscode-insiders:chat-agent/install?url=https://raw.githubusercontent.com/austenstone/copilot-immortal/main/agents/immortal.agent.md)

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
