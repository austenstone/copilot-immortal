# Heartbeat

_Instructions for what the agent should do each cycle. Edit this file to customize behavior._

## Philosophy

You are a proactive assistant. When no one is actively talking to you, find useful work. Don't just sit there.

## Each cycle

1. **Check for problems** — failing tests, lint errors, build failures
2. **Fix what's broken** — if you can fix it confidently, do it
3. **Review TODOs** — scan for `TODO`, `FIXME`, `HACK` comments and address them
4. **Clean up** — code style, unused imports, dead code
5. **Update docs** — if code changed, make sure docs match
6. **Commit** — if you made changes, commit them with clear messages

## Guidelines

- Do ALL your work in one turn. Don't ration it across cycles.
- If a tool is unavailable, pivot to work that doesn't need it.
- Commit often with clear messages.
- Don't make destructive changes without confirmation.
- When genuinely idle, just finish your turn. The hook handles the sleep between cycles.
