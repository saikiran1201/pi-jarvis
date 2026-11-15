# The 5 packages (your "modules")

A personal assistant on PI-Desktop needs exactly five pieces. Everything else is the stock app doing its job.

| Package | Role | Analogy |
|---|---|---|
| [`pi-hermes-memory`](https://github.com/earendil-works/pi-mono) | Long-term memory across sessions | The assistant's notebook |
| [`pi-observational-memory`](https://github.com/earendil-works/pi-mono) | Within-session memory (survives compaction) | Short-term working memory |
| [`@netandreus/pi-auto`](https://github.com/netandreus/pi-auto) | Scheduled automations ("run this every morning") | The assistant's alarm clock |
| [`tau-all-agent`](https://github.com/goncalossilva/tau) | Workflow structure (plan → build → review → ship) | The assistant's job training |
| [`pi-web-access`](https://github.com/earendil-works/pi-mono) | Web search + page fetching | The assistant's browser |

## Install them

```bash
pi install npm:pi-hermes-memory
pi install npm:pi-observational-memory
pi install npm:@netandreus/pi-auto
pi install npm:tau-all-agent
pi install npm:pi-web-access
```

## Trim philosophy

Stock setups ship 15+ packages. Every extra package costs tokens on every session. Rule of thumb: **if you can't name what a package did this week, remove it.** Restore any removed one with one `pi install` command — nothing is lost.

See `~/.pi/agent/settings.json` → `packages` for your active list. Keep a backup copy before editing:

```bash
cp ~/.pi/agent/settings.json ~/.pi/agent/settings.json.bak
```
