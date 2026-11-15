# personal-ai-assistant

My personal AI assistant configuration for [PI-Desktop](https://github.com/badlogic/pi-mono) — the coding-agent app I run daily.

This repo does **not** contain the app itself. It contains the personalization layer that turns a stock PI-Desktop install into *my* assistant:

```
├── AGENTS.md   ← agent rules: tone, context, safety, daily flow
├── skills/     ← custom skills the assistant can load on demand
├── guides/     ← longer how-to notes (setup, migration between machines)
└── LICENSE
```

## What this gives me

- **Consistent personality & rules** — my assistant behaves the same on every machine.
- **Portable setup** — clone the repo, symlink `AGENTS.md` into `~/.pi/agent/`, done.
- **Version history** — every tweak to how my assistant works is a git commit.

## Install on a new machine

```bash
git clone https://github.com/<YOUR-USERNAME>/personal-ai-assistant.git
mkdir -p ~/.pi/agent
ln -sf "$(pwd)/personal-ai-assistant/AGENTS.md" ~/.pi/agent/AGENTS.md
```

Skills in `skills/` go to `~/.pi/agent/skills/<skill-name>/SKILL.md`.

## Publishing to GitHub

```bash
git remote add origin git@github.com:<YOUR-USERNAME>/personal-ai-assistant.git
git push -u origin main
```

Create the empty repo on github.com first (no README/license — this repo supplies them).

## Notes

- Never commit secrets, tokens, or `.env` files — check `.gitignore`.
- See `guides/` for the full machine-migration walkthrough.
