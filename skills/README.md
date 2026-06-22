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

Every skill is backed by stable `deepcoin-cli` commands.

- Shared preflight and credential rules: [`_shared/deepcoin-cli.md`](_shared/deepcoin-cli.md)
- Per-skill command references: `deepcoin-*/references/*-commands.md`
- Agents should call `deepcoin-cli ...` directly and should not write custom API request/signing scripts.
- Missing command coverage should be reported as a CLI gap.

## Available Skills

- **[deepcoin-market](deepcoin-market/SKILL.md)** — Public market data (tickers, orderbook, K-lines, trades, funding rate, instruments, WebSocket)
- **[deepcoin-trade](deepcoin-trade/SKILL.md)** — Order management (place, cancel, amend, trigger, TP/SL, close positions)
- **[deepcoin-portfolio](deepcoin-portfolio/SKILL.md)** — Account state (balance, positions, leverage, sub-accounts, assets, transfers, private WebSocket)
- **[deepcoin-withdrawal](deepcoin-withdrawal/SKILL.md)** — On-chain withdrawals (pre-check config, whitelist addresses, chains, create, cancel, status, records)
- **[deepcoin-copytrade](deepcoin-copytrade/SKILL.md)** — Copy trading (leader settings, followers, positions, profit)
- **[deepcoin-strategy](deepcoin-strategy/SKILL.md)** — Automated strategies (DSL orders with indicators, backtesting)

## Performance Principles

- Use the narrowest skill and endpoint that answers the user's request.
- Prefer aggregate and batch endpoints before looping over single-item requests.
- Use bounded concurrency for independent READ requests within documented endpoint limits.
- Avoid preflight metadata, balance, position, or backtest calls unless they are required for correctness, risk checks, or live execution.
- Keep WRITE requests serialized unless an official batch endpoint applies, and verify writes with targeted reads.

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
  homepage: "https://api.deepcoin.com"
---
```

Followed by: CLI execution rules, endpoint index (with READ/WRITE classification), operation flow, endpoint reference, safety rules, decision workflows, edge cases, scope & boundaries, and examples.

Each skill must include a `CLI Execution` section that links to `_shared/deepcoin-cli.md` and to its command reference file.

## API Base URL Convention

All Deepcoin skills should support a user-provided `base_url`.

- If `base_url` is provided, use it for request construction.
- If `base_url` is omitted, default to `https://api.deepcoin.com`.
