# 🤖 pi-jarvis

> **Your AI, but with a memory, a personality, and a morning routine.**

A minimal, open-source starter kit that turns [PI-Desktop](https://github.com/badlogic/pi-mono) — the terminal coding agent — into a **personal AI assistant** that actually knows you.

No 500-line prompt. No 16-package bloat. **5 packages, 4 skills, 1 install script — plus optional NVIDIA OpenShell secure mode.**

```bash
git clone https://github.com/saikiran1201/pi-jarvis.git
cd pi-jarvis && ./install.sh
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
git clone https://github.com/saikiran1201/pi-jarvis.git
cd pi-jarvis && ./install.sh
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

---

## 🖥️ Desktop app mode (podman) — *run jarvis as its own app*

Want jarvis fully isolated from your system — own memory, own packages, own everything — launched from your **app menu**? That's the desktop mode:

```bash
git clone https://github.com/saikiran1201/pi-jarvis.git
cd pi-jarvis
./desktop/install-desktop.sh        # builds the container + installs the app menu entry
```

Then launch **"Pi Jarvis"** from your applications menu (or run `pi-jarvis-desktop`). First launch seeds the config and installs packages automatically. Provide your model key:

```bash
OPENROUTER_API_KEY=sk-or-... pi-jarvis-desktop
```

What it gives you:

| | Host install (`./install.sh`) | Desktop mode (podman) |
|---|---|---|
| Isolation | shares your `~/.pi/agent` | **fully sandboxed** (`~/.pi-jarvis-desktop/`) |
| Persistence | native | host-mounted config dir — memory survives restarts |
| Depends on | PI-Desktop / pi on host | podman only |

Files: [`desktop/Containerfile`](desktop/Containerfile) · [`desktop/entrypoint.sh`](desktop/entrypoint.sh) · [`desktop/install-desktop.sh`](desktop/install-desktop.sh)

Requires Linux with [podman](https://podman.io) (`sudo apt install podman`).

## 🪟 Desktop app — the PI-Desktop UI, running PI-Jarvis

One app, fully isolated from your coding setup:

```bash
./desktop/install-desktop.sh
```

- App-menu entry **"PI-Jarvis"** (+ desktop shortcut) launches the full PI-Desktop interface
- Opens on its own workspace (`~/Jarvis-Workspace`), own memory, own sessions
- Brain lives in `~/.pi-jarvis-desktop/`, keys in `~/.pi-jarvis-desktop.env` (never committed)
- Requires PI-Desktop installed (https://pi.dev); if a PI-Jarvis-branded copy exists it's used so the header reads **PI-Jarvis**

## 🔐 Secure Mode — NVIDIA OpenShell

PI-Jarvis can run inside [NVIDIA OpenShell](https://github.com/NVIDIA/OpenShell) — a kernel-enforced sandbox where the assistant gets real shell/file/network capability **without ever seeing your API key** (the gateway injects credentials only into requests bound for approved endpoints).

```bash
# one-time setup (needs podman + openshell CLI, see sandbox/README)
./sandbox/setup.sh

# then:
pi-jarvis-secure                  # interactive chat inside the sandbox
pi-jarvis-secure "morning brief"  # one-shot
```

What you gain: every file access, syscall, and network connection is policy-checked at the kernel level; denied actions are logged; policy changes are formally verified before activation. What it costs: the sandbox is isolated from your host — it sees only its own workspace.

Files: [`sandbox/`](sandbox/) — image build, setup script, secure launcher.
