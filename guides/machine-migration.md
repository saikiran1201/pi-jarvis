# Machine migration guide

Moving the personal assistant to a new machine:

1. Install PI-Desktop and log in (model provider keys go in the app's Settings — never in this repo).
2. `git clone https://github.com/<YOUR-USERNAME>/personal-ai-assistant.git ~/personal-ai-assistant`
3. Symlink the agent rules:
   ```bash
   mkdir -p ~/.pi/agent
   ln -sf ~/personal-ai-assistant/AGENTS.md ~/.pi/agent/AGENTS.md
   ```
4. Copy every skill: `cp -R ~/personal-ai-assistant/skills/* ~/.pi/agent/skills/`
5. Recreate `~/Notes/` from your backup (notes are **not** in this repo — they're private).
6. Smoke test: ask the assistant for a daily brief. It should use the `daily-brief` skill.
