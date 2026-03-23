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

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Plugin-0098FF?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://insiders.vscode.dev/redirect?url=vscode%3Achat-plugin%2Finstall%3Furl%3Dhttps%3A%2F%2Fgithub.com%2Faustenstone%2Fcopilot-immortal)
[![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install_Plugin-24bfa5?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://insiders.vscode.dev/redirect?url=vscode-insiders%3Achat-plugin%2Finstall%3Furl%3Dhttps%3A%2F%2Fgithub.com%2Faustenstone%2Fcopilot-immortal)

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

The [Stop hook](https://code.visualstudio.com/docs/copilot/customization/hooks) fires every time the agent tries to stop. The hook script sleeps for the configured interval (using `timeoutSec` so VS Code doesn't kill it), then blocks the stop and tells the agent to keep working. The sleep happens in the hook itself — zero agent tool calls wasted.

```
start → work → tries to stop → hook sleeps → BLOCKED → work → repeat ♾️
```

## What's included

| File | Purpose |
|------|---------|
| `scripts/heartbeat.sh` | Blocks stop, injects workspace context |
| `scripts/context.sh` | Injects git branch + date at session start |
| `scripts/persist.sh` | Saves context before conversation compaction |
| `scripts/guard.sh` | Blocks `rm -rf`, `git push --force`, `git reset --hard` |
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
