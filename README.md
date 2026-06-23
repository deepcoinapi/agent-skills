# Deepcoin Agent Skills

Plug-and-play AI agent skills for [Deepcoin](https://www.deepcoin.com), enabling XiaoD, Deepcoin's dedicated trading assistant, and other LLM agents to query market data, manage portfolios, trade, run automated strategies, and manage copy trading through `dcli`.

## Deepcoin Skills Capability Hub

All of XiaoD's capabilities are concentrated in Deepcoin skills. Through this skill set, XiaoD can:

- query market prices, tickers, orderbook depth, trades, candles, funding rates, and instrument metadata
- inspect balances, positions, leverage, sub-accounts, assets, and transfers
- pre-check, create, cancel, and query on-chain withdrawals
- place, amend, cancel, and verify orders, including trigger orders and TP/SL workflows
- manage copy trading settings, followers, contracts, positions, and profit records
- design DSL strategies, run backtests, and prepare strategy deployment

## CLI-Backed Execution Model

These skills are instruction and routing layers. Execution must go through `dcli`, not ad hoc scripts.

- Each skill provides stable command references under `skills/<skill>/references/*-commands.md`.
- Agents must run `dcli ...` commands from those references.
- Agents must not temporarily assemble Python, JavaScript, shell, signing, or custom request clients that bypass `dcli`.
- If a needed capability is missing from the CLI, report the missing CLI command instead of improvising.

Preflight and environment rules are centralized in [`skills/_shared/dcli.md`](skills/_shared/dcli.md).

## Skills

| Skill | Description | Auth Required |
|-------|-------------|:---:|
| [deepcoin-market](skills/deepcoin-market/SKILL.md) | Public market data: tickers, orderbook, K-lines, trades, funding rate, instruments | No |
| [deepcoin-trade](skills/deepcoin-trade/SKILL.md) | Order placement, cancellation, amendment, trigger orders, TP/SL, position close, trade fills | Yes |
| [deepcoin-portfolio](skills/deepcoin-portfolio/SKILL.md) | Account balance, positions, leverage, sub-accounts, asset transfers, deposits | Yes |
| [deepcoin-withdrawal](skills/deepcoin-withdrawal/SKILL.md) | On-chain withdrawal config, whitelist addresses, chains, create, cancel, status, and records | Yes |
| [deepcoin-copytrade](skills/deepcoin-copytrade/SKILL.md) | Copy trading: leader settings, follower management, positions, profit tracking | Yes |
| [deepcoin-strategy](skills/deepcoin-strategy/SKILL.md) | DSL strategy orders with technical indicators (BOLL, MA, EMA, KDJ, RSI, WR) and backtesting | Yes |

## Layout

```text
skills/
  deepcoin-market/
    SKILL.md
    references/market-commands.md
  deepcoin-trade/
    SKILL.md
    references/trade-commands.md
  deepcoin-portfolio/
    SKILL.md
    references/portfolio-commands.md
  deepcoin-withdrawal/
    SKILL.md
    references/withdrawal-commands.md
  deepcoin-copytrade/
    SKILL.md
    references/copytrade-commands.md
  deepcoin-strategy/
    SKILL.md
    references/strategy-commands.md
  _shared/
    dcli.md
```

## Skill Packages

The repository can provide one zip package per skill. Each package contains the skill's `SKILL.md`, command references, and a packaged copy of the shared `dcli` preflight rules at `references/dcli.md`.

```bash
bash scripts/package-skills.sh
ls dist/deepcoin-*.zip
```

Generated packages:

```text
dist/deepcoin-market.zip
dist/deepcoin-trade.zip
dist/deepcoin-portfolio.zip
dist/deepcoin-withdrawal.zip
dist/deepcoin-copytrade.zip
dist/deepcoin-strategy.zip
```

Example regular zip contents:

```text
SKILL.md
references/portfolio-commands.md
references/dcli.md
```

GitHub Actions also builds these packages on pull requests, pushes to `main`, manual workflow runs, and `v*` tags. Tagged releases upload the zip files as release assets.

## Versioned Releases

Use repository-level semver tags for stable skill package releases. A tag such as `v1.0.3` publishes the current `dist/deepcoin-*.zip` packages as GitHub Release assets.

Each skill also keeps its own `metadata.version` in `SKILL.md`. Bump the version only for skills changed by the release. For example, if only `deepcoin-portfolio` changes, update only `skills/deepcoin-portfolio/SKILL.md`.

Release checklist:

```bash
bash scripts/package-skills.sh
bash scripts/package-skills.sh --check
git status --short

git add skills/<skill>/SKILL.md dist/<skill>.zip README.md
git commit -m "Bump <skill> skill to <version>"

git tag v<version>
git push origin main
git push origin v<version>
```

Install stable packages from release assets instead of `main` when reproducibility matters:

```text
https://github.com/deepcoinapi/agent-skills/releases/download/v1.0.3/deepcoin-portfolio.zip
```

## Skill Routing

Each skill defines clear boundaries in its `description` field. An AI agent should use the description to route user requests to the correct skill:

- **Price / ticker / candles / orderbook / funding rate** → `deepcoin-market`
- **Place / cancel / amend orders / trigger orders / TP-SL** → `deepcoin-trade`
- **Balance / positions / leverage / transfers / sub-accounts** → `deepcoin-portfolio`
- **On-chain withdrawals / withdrawal whitelist / withdrawal status** → `deepcoin-withdrawal`
- **Copy trading setup / followers / leader positions** → `deepcoin-copytrade`
- **Automated strategies / backtesting / DSL orders** → `deepcoin-strategy`

## Authentication

Authenticated CLI commands require credentials in environment variables. Prefer the `DEEPCOIN_*` names; `DC_*` aliases are also supported by the CLI.

| Purpose | Preferred | Alias |
|---------|-----------|-------|
| API key | `DEEPCOIN_API_KEY` | `DC_API_KEY` |
| Secret key | `DEEPCOIN_SECRET_KEY` | `DC_SECRET_KEY` |
| Passphrase | `DEEPCOIN_PASSPHRASE` | `DC_PASSPHRASE` |
| Base URL | `DEEPCOIN_BASE_URL` | `DC_BASE_URL` |

## Integration

These skills work with multiple AI coding tools. See [INTEGRATION.md](INTEGRATION.md) for setup instructions:

| Platform | Skills Directory | Docs |
|----------|-----------------|------|
| [Claude Code](https://claude.ai/code) | `.claude/skills/<name>/SKILL.md` | [Setup guide](INTEGRATION.md#claude-code) |
| [Cursor](https://cursor.com) | `.cursor/skills/<name>/SKILL.md` | [Setup guide](INTEGRATION.md#cursor) |
| [Codex CLI](https://github.com/openai/codex) | `.agents/skills/<name>/SKILL.md` | [Setup guide](INTEGRATION.md#codex-cli) |
| [OpenClaw](https://openclaw.ai) | `~/.openclaw/skills/<name>/SKILL.md` | [Setup guide](INTEGRATION.md#openclaw) |

## License

MIT
