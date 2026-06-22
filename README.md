# Deepcoin Agent Skills

Plug-and-play AI agent skills for [Deepcoin](https://www.deepcoin.com), enabling XiaoD, Deepcoin's dedicated trading assistant, and other LLM agents to query market data, manage portfolios, trade, run automated strategies, and manage copy trading through the Deepcoin API.

## Deepcoin Skills Capability Hub

All of XiaoD's capabilities are concentrated in Deepcoin skills. Through this skill set, XiaoD can:

- query market prices, tickers, orderbook depth, trades, candles, funding rates, and instrument metadata
- inspect balances, positions, leverage, sub-accounts, assets, and transfers
- pre-check, create, cancel, and query on-chain withdrawals
- place, amend, cancel, and verify orders, including trigger orders and TP/SL workflows
- manage copy trading settings, followers, contracts, positions, and profit records
- design DSL strategies, run backtests, and prepare strategy deployment

## CLI-Backed Execution Model

These skills are instruction and routing layers. Execution must go through `deepcoin-cli`, not ad hoc scripts.

- Each skill provides stable command references under `skills/<skill>/references/*-commands.md`.
- Agents must run `deepcoin-cli ...` commands from those references.
- Agents must not temporarily assemble Python, JavaScript, shell, cURL-signing, or custom HTTP clients to call Deepcoin APIs.
- If a needed API is missing from the CLI, report the missing CLI command instead of improvising.

Preflight and environment rules are centralized in [`skills/_shared/deepcoin-cli.md`](skills/_shared/deepcoin-cli.md).

## Skills

| Skill | Description | Auth Required |
|-------|-------------|:---:|
| [deepcoin-market](skills/deepcoin-market/SKILL.md) | Public market data: tickers, orderbook, K-lines, trades, funding rate, instruments, WebSocket streams | No |
| [deepcoin-trade](skills/deepcoin-trade/SKILL.md) | Order placement, cancellation, amendment, trigger orders, TP/SL, position close, trade fills | Yes |
| [deepcoin-portfolio](skills/deepcoin-portfolio/SKILL.md) | Account balance, positions, leverage, sub-accounts, asset transfers, deposits, private WebSocket | Yes |
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
    deepcoin-cli.md
```

## Skill Routing

Each skill defines clear boundaries in its `description` field. An AI agent should use the description to route user requests to the correct skill:

- **Price / ticker / candles / orderbook / funding rate** → `deepcoin-market`
- **Place / cancel / amend orders / trigger orders / TP-SL** → `deepcoin-trade`
- **Balance / positions / leverage / transfers / sub-accounts** → `deepcoin-portfolio`
- **On-chain withdrawals / withdrawal whitelist / withdrawal status** → `deepcoin-withdrawal`
- **Copy trading setup / followers / leader positions** → `deepcoin-copytrade`
- **Automated strategies / backtesting / DSL orders** → `deepcoin-strategy`

## API Base URL

Users can pass a custom API Base URL.

- If `base_url` is provided, use that value.
- If `base_url` is not provided, default to `https://api.deepcoin.com`.

## Performance and Rate Limits

Use Deepcoin endpoint-specific limits when known, and avoid unnecessary preflight calls.

- Public market-data endpoints can use bounded concurrency up to **5 requests per second per IP** unless a stricter endpoint rule applies.
- Authenticated trading WRITE endpoints should default to **1 request per second per API key** unless an official batch endpoint is used.
- Prefer aggregate or batch endpoints instead of high fan-out single-item requests.
- For independent READ requests, use bounded concurrency within documented limits.
- Serialize WRITE requests by default.
- If a request returns `429` or another explicit rate-limit signal, back off and retry later instead of replaying the entire batch immediately.

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
