# Integration Guide

This guide explains how to use Deepcoin agent skills with popular AI coding tools.

---

## Table of Contents

- [Claude Code](#claude-code)
- [Cursor](#cursor)
- [Codex CLI](#codex-cli)
- [OpenClaw](#openclaw)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)

---

## Claude Code

### Installation

Clone skills into the project-level or user-level skills directory:

```bash
# Project-level (recommended for teams)
git clone https://github.com/deepcoinapi/agent-skills.git /tmp/deepcoin-skills
mkdir -p .claude/skills
cp -r /tmp/deepcoin-skills/skills/deepcoin-* .claude/skills/

# User-level (global, all projects)
mkdir -p ~/.claude/skills
cp -r /tmp/deepcoin-skills/skills/deepcoin-* ~/.claude/skills/
```

### Directory Structure

```
.claude/
  skills/
    deepcoin-market/SKILL.md
    deepcoin-trade/SKILL.md
    deepcoin-portfolio/SKILL.md
    deepcoin-copytrade/SKILL.md
    deepcoin-strategy/SKILL.md
```

### How It Works

- Claude Code **automatically discovers** all `SKILL.md` files in `.claude/skills/`.
- The `description` field in YAML frontmatter is used for **routing** — Claude reads it to decide which skill to activate.
- Skills can also be invoked manually as slash commands: `/deepcoin-trade`, `/deepcoin-market`, etc.
- Hot reload is supported — editing a `SKILL.md` takes effect immediately.

### Optional: CLAUDE.md Reference

You can add a note in your project's `CLAUDE.md` (not required, but helps discoverability):

```markdown
## Deepcoin Trading Skills

Available skills:
- `/deepcoin-market` — Public market data (tickers, K-lines, orderbook)
- `/deepcoin-trade` — Order management (place, cancel, amend, TP/SL)
- `/deepcoin-portfolio` — Account queries (balance, positions, leverage)
- `/deepcoin-copytrade` — Copy trading operations
- `/deepcoin-strategy` — DSL strategy orders and backtesting

Required env vars: DC_API_KEY, DC_SECRET_KEY, DC_PASSPHRASE
```

---

## Cursor

### Option A: Use as Cursor Skills (simplest)

Copy skill folders into `.cursor/skills/`:

```bash
git clone https://github.com/deepcoinapi/agent-skills.git /tmp/deepcoin-skills
mkdir -p .cursor/skills
cp -r /tmp/deepcoin-skills/skills/deepcoin-* .cursor/skills/
```

Directory structure:

```
.cursor/
  skills/
    deepcoin-market/SKILL.md
    deepcoin-trade/SKILL.md
    deepcoin-portfolio/SKILL.md
    deepcoin-copytrade/SKILL.md
    deepcoin-strategy/SKILL.md
```

Cursor's agent will read the markdown body and use it when relevant. The YAML frontmatter is harmlessly ignored.

### Option B: Convert to Cursor Rules (more control)

Create `.mdc` files in `.cursor/rules/` for explicit scoping:

```bash
mkdir -p .cursor/rules
```

Example — `.cursor/rules/deepcoin-market.mdc`:

```
---
description: "Use this rule when the user asks for Deepcoin price, ticker, orderbook, K-line, funding rate, or public market data."
globs:
alwaysApply: false
---

[paste the markdown body of deepcoin-market/SKILL.md here]
```

Cursor rule types based on frontmatter:

| Type | `alwaysApply` | `globs` | `description` | Behavior |
|------|:---:|:---:|:---:|-----------|
| Always | `true` | — | optional | Injected into every prompt |
| Auto-Attach | `false` | set | optional | Injected when matching files are open |
| Agent-Requested | `false` | — | set | Agent decides based on description |
| Manual | `false` | — | — | Only via `@rulename` |

For Deepcoin skills, **Agent-Requested** mode (description set, no globs) is the best fit — the agent activates the rule when the user's intent matches.

---

## Codex CLI

### Installation

Clone skills into the Codex skills discovery directory:

```bash
# Project-level
git clone https://github.com/deepcoinapi/agent-skills.git /tmp/deepcoin-skills
mkdir -p .agents/skills
cp -r /tmp/deepcoin-skills/skills/deepcoin-* .agents/skills/

# User-level (global)
mkdir -p ~/.agents/skills
cp -r /tmp/deepcoin-skills/skills/deepcoin-* ~/.agents/skills/
```

### Directory Structure

```
.agents/
  skills/
    deepcoin-market/SKILL.md
    deepcoin-trade/SKILL.md
    deepcoin-portfolio/SKILL.md
    deepcoin-copytrade/SKILL.md
    deepcoin-strategy/SKILL.md
```

### How It Works

- Codex scans `.agents/skills/` directories for `SKILL.md` files.
- The `description` in YAML frontmatter is **always loaded** into the context window for routing.
- The markdown body is **lazy-loaded** on demand — only when Codex decides the skill is relevant.
- Skills can be invoked explicitly via `/skills` command or implicitly by user intent.

### Discovery Locations (priority order)

1. `.agents/skills/` in current and parent directories (project-level)
2. `$HOME/.agents/skills/` (user-level)
3. `/etc/codex/skills/` (admin-level)
4. System built-in skills

### Optional: AGENTS.md Reference

Add a note in your project's `AGENTS.md`:

```markdown
## Deepcoin Trading Skills

This project includes Deepcoin API skills in `.agents/skills/`.
Skills are auto-discovered. Required environment variables:

- DC_API_KEY
- DC_SECRET_KEY
- DC_PASSPHRASE
```

---

## OpenClaw

### Installation

```bash
# Clone into OpenClaw's managed skills directory
git clone https://github.com/deepcoinapi/agent-skills.git ~/.openclaw/skills/deepcoin-agent-skills
```

Or use the `extraDirs` config in `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/path/to/agent-skills/skills"]
    }
  }
}
```

Or install from ClawHub (if published):

```bash
clawhub install deepcoin-market
clawhub install deepcoin-trade
clawhub install deepcoin-portfolio
clawhub install deepcoin-copytrade
clawhub install deepcoin-strategy
```

### Per-Skill Configuration

In `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "deepcoin-trade": {
        "enabled": true,
        "env": {
          "DC_API_KEY": "your-api-key",
          "DC_SECRET_KEY": "your-secret-key",
          "DC_PASSPHRASE": "your-passphrase"
        }
      }
    }
  }
}
```

### How It Works

- OpenClaw auto-discovers `SKILL.md` files in configured directories.
- The `description` field routes user requests to the correct skill.
- `metadata.openclaw.requires.env` declares required environment variables.
- Hot reload is enabled by default (`skills.load.watch: true`).

---

## Environment Variables

Authenticated skills (trade, portfolio, copytrade, strategy) require:

| Variable | Description |
|----------|-------------|
| `DC_API_KEY` | Your Deepcoin API Key |
| `DC_SECRET_KEY` | Your Deepcoin Secret Key |
| `DC_PASSPHRASE` | Passphrase set when creating the API key |

Set them in your shell:

```bash
export DC_API_KEY="your-api-key"
export DC_SECRET_KEY="your-secret-key"
export DC_PASSPHRASE="your-passphrase"
```

Or add to your shell profile (`~/.bashrc`, `~/.zshrc`):

```bash
echo 'export DC_API_KEY="your-api-key"' >> ~/.zshrc
echo 'export DC_SECRET_KEY="your-secret-key"' >> ~/.zshrc
echo 'export DC_PASSPHRASE="your-passphrase"' >> ~/.zshrc
```

> **Security**: Never commit credentials to version control. Use `.env` files (add to `.gitignore`) or your tool's built-in secret management.

---

## Skill Routing

All four platforms use the `description` field in YAML frontmatter for routing. The Deepcoin skills have clear boundaries:

| User Intent | Skill Activated |
|-------------|----------------|
| "What's the price of BTC?" | `deepcoin-market` |
| "Show my account balance" | `deepcoin-portfolio` |
| "Buy 1 BTC-USDT-SWAP at 60000" | `deepcoin-trade` |
| "Set up copy trading" | `deepcoin-copytrade` |
| "Backtest a Bollinger strategy on ETH" | `deepcoin-strategy` |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Skill not detected | Verify the `SKILL.md` file is in the correct directory for your tool |
| Auth errors (401) | Check `DC_API_KEY`, `DC_SECRET_KEY`, `DC_PASSPHRASE` are set |
| Wrong skill activated | Review the `description` field; use explicit skill invocation if needed |
| Rate limit errors | Market: 5 req/s per IP; Trading: 1 req/s per API key |
| Skill not routing correctly | Ensure skill names match directory names |

### Platform-Specific Paths

| Platform | Project-Level Path | User-Level Path |
|----------|-------------------|-----------------|
| Claude Code | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` |
| Cursor | `.cursor/skills/<name>/SKILL.md` | — |
| Codex CLI | `.agents/skills/<name>/SKILL.md` | `~/.agents/skills/<name>/SKILL.md` |
| OpenClaw | workspace `skills/` | `~/.openclaw/skills/<name>/SKILL.md` |
