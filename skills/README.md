# Deepcoin Skills

This directory contains AI agent skills for the Deepcoin trading platform. Each skill is a self-contained `SKILL.md` file with YAML frontmatter for routing metadata and a comprehensive Markdown body that serves as the complete instruction set for an LLM agent.

## Capability Hub

Deepcoin skills are the capability hub for XiaoD. All of XiaoD's trading abilities are concentrated here, including:

- market data and instrument lookup
- account, balance, and position inspection
- order execution and verification
- copy trading workflows
- strategy design and backtesting

## CLI Execution Boundary

Every skill is backed by stable `dcli` commands.

- Shared preflight and credential rules: [`_shared/dcli.md`](_shared/dcli.md)
- Per-skill command references: `deepcoin-*/references/*-commands.md`
- Agents should call `dcli ...` directly and should not write scripts that bypass `dcli`.
- Missing command coverage should be reported as a CLI gap.

## Available Skills

- **[deepcoin-market](deepcoin-market/SKILL.md)** — Public market data (tickers, orderbook, K-lines, trades, funding rate, instruments)
- **[deepcoin-trade](deepcoin-trade/SKILL.md)** — Order management (place, cancel, amend, trigger, TP/SL, close positions)
- **[deepcoin-portfolio](deepcoin-portfolio/SKILL.md)** — Account state (balance, positions, leverage, sub-accounts, assets, transfers)
- **[deepcoin-withdrawal](deepcoin-withdrawal/SKILL.md)** — On-chain withdrawals (pre-check config, whitelist addresses, chains, create, cancel, status, records)
- **[deepcoin-copytrade](deepcoin-copytrade/SKILL.md)** — Copy trading (leader settings, followers, positions, profit)
- **[deepcoin-strategy](deepcoin-strategy/SKILL.md)** — Automated strategies (DSL orders with indicators, backtesting)

## Performance Principles

- Use the narrowest skill and `dcli` command that answers the user's request.
- Prefer aggregate and batch CLI commands before looping over single-item reads.
- Avoid preflight metadata, balance, position, or backtest calls unless they are required for correctness, risk checks, or live execution.
- Keep WRITE commands serialized unless a documented batch command applies, and verify writes with targeted reads.

## Skill Zip Packages

Generate one zip file per skill from the repository root:

```bash
bash scripts/package-skills.sh
```

Each zip contains only that skill's `SKILL.md` and `references/` directory. For example, `dist/deepcoin-portfolio.zip` contains:

```text
SKILL.md
references/portfolio-commands.md
```

## Skill Format

Each `SKILL.md` follows this structure:

```yaml
---
name: skill-identifier
description: "Routing description for AI agent..."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.2"
  homepage: "https://github.com/deepcoinapi/agent-cli"
---
```

Followed by: CLI execution rules, command index with READ/WRITE classification, operation flow, command reference, safety rules, decision workflows, edge cases, scope boundaries, and examples.

Each skill must include a `CLI Execution` section that links to `_shared/dcli.md` and to its command reference file.
