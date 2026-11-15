# personal-ai-assistant

> A minimal, open-source starter template for building your own personal AI assistant on [PI-Desktop](https://github.com/badlogic/pi-mono). Fork it, rename it, make it yours.

Most AI-agent setups are either bloated (dozens of packages) or undocumented. This repo is the opposite: a **5-package minimal config**, one example skill, and a migration guide — everything you need to turn a stock PI-Desktop install into an assistant that knows *you*.

This repo does **not** contain the app itself. It contains the personalization layer:

```
├── AGENTS.md   ← agent rules: tone, context, safety, daily flow
├── skills/     ← custom skills the assistant can load on demand
├── guides/     ← longer how-to notes (setup, migration between machines)
└── LICENSE
```

## The minimal setup (what this repo documents)

Turn any stock PI-Desktop install into a personal assistant with just:

| Piece | Where it goes | What it does |
|---|---|---|
| `AGENTS.md` | `~/.pi/agent/AGENTS.md` | Personality, rules, privacy/safety baseline |
| Skills | `~/.pi/agent/skills/` | On-demand capabilities (e.g. daily-brief) |
| Model keys | App Settings UI | Provider access — **never** in this repo |

That's the whole personalization layer; everything else is the stock app.

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
