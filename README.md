# 🤖 personal-ai-assistant

> **Your AI, but with a memory, a personality, and a morning routine.**

A minimal, open-source starter kit that turns [PI-Desktop](https://github.com/badlogic/pi-mono) — the terminal coding agent — into a **personal AI assistant** that actually knows you.

No 500-line prompt. No 16-package bloat. **5 packages, 4 skills, 1 install script.**

```bash
git clone https://github.com/saikiran1201/personal-ai-assistant.git
cd personal-ai-assistant && ./install.sh
```

That's it. Your assistant now remembers you.

---

## 🧠 What your assistant can do on day one

| Say this | It does |
|---|---|
| *"morning brief"* | Scans your notes + sessions → **In progress / Waiting on / Today's focus** |
| *"remember this: …"* | Saves facts, preferences, decisions to long-term memory |
| *"research X"* | Web search → 5-line answer with **cited sources** |
| *"end of day"* | Summarizes the day, commits finished work, queues tomorrow's first task |

Skills are plain Markdown — read one, and you'll know exactly how your assistant thinks. Then write your own.

## 🧩 The architecture (tiny on purpose)

```
PI-Desktop  ──────────────  the engine (already installed)
└── ~/.pi/agent/            ← everything personal lives here
     ├── AGENTS.md           personality, rules, privacy baseline
     ├── skills/             4 on-demand capabilities
     └── memory              pi-hermes: remembers you between sessions
```

Five packages do the heavy lifting:

- **`pi-hermes-memory`** — the notebook (long-term memory)
- **`pi-observational-memory`** — the working memory
- **`@netandreus/pi-auto`** — the alarm clock (scheduled automations)
- **`tau-all-agent`** — the job training (plan → build → review → ship)
- **`pi-web-access`** — the browser

Full breakdown with install commands: [`guides/pi-packages.md`](guides/pi-packages.md)

## ✨ Why "minimal" is the point

Every extra package costs **tokens on every single session**. Stock agent setups ship 15+ packages; most sit unused. This kit's rule:

> *If you can't name what a package did this week, remove it.*

Nothing is ever lost — any removed package is one `pi install` away.

## 📦 What's in the box

```
├── AGENTS.md                  the assistant's personality & rules
├── skills/
│   ├── daily-brief/           morning brief
│   ├── remember/              long-term memory capture
│   ├── web-research/          cited web research
│   └── end-of-day/            daily wrap-up + commits
├── guides/
│   ├── pi-packages.md         the 5 packages explained
│   └── machine-migration.md   move to a new laptop in 5 minutes
├── install.sh                 one command to wire it all up
├── LICENSE                    MIT
└── README.md                  you are here
```

## 🚀 Quickstart

**1. Get PI-Desktop** — follow [pi.dev](https://pi.dev).

**2. Clone and install:**
```bash
git clone https://github.com/saikiran1201/personal-ai-assistant.git
cd personal-ai-assistant && ./install.sh
```

**3. Restart PI-Desktop and say:**
```
morning brief
```

**4. (Optional) Add the 5 packages** — see [`guides/pi-packages.md`](guides/pi-packages.md).

**5. Make it *yours*** — edit `AGENTS.md` (it's just Markdown). Add your timezone, your projects, your rules. Commit the change — your assistant's growth is now version-controlled.

## 🔒 Privacy built in

`AGENTS.md` ships with a hard baseline: never touch `.env*` or credential files, never paste private-note contents into commits or issues, ask before deleting. The `.gitignore` blocks tokens and secrets from ever being committed. Your notes stay on your machine — this repo is config only.

## 🛠 Writing your own skill (2 minutes)

```bash
mkdir -p ~/.pi/agent/skills/cook-dinner
```
```markdown
---
name: cook-dinner
description: Suggest a recipe from what's in my fridge.
---
1. Ask what I have. 2. Suggest 3 options. 3. Send a shopping list for missing items.
```
Done. If it earns its keep, PR it back here.

## 🤝 Contributing

Fork it, rename it, make it weirdly yours. Good PRs: new skills, tighter `AGENTS.md` rules, migration fixes. Bad PRs: new packages without removing two first. 😉

## ⭐ If this saved you an evening of setup…

…star the repo. It's the only metric that tells me this was worth publishing.

## License

MIT — see [LICENSE](LICENSE).
