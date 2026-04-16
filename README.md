# Deepcoin Agent Skills

Plug-and-play AI agent skills for [Deepcoin](https://www.deepcoin.com), enabling any LLM agent to query market data, manage portfolios, trade, run automated strategies, and manage copy trading through the Deepcoin API.

## Skills

| Skill | Description | Auth Required |
|-------|-------------|:---:|
| [deepcoin-market](skills/deepcoin-market/SKILL.md) | Public market data: tickers, orderbook, K-lines, trades, funding rate, instruments, WebSocket streams | No |
| [deepcoin-trade](skills/deepcoin-trade/SKILL.md) | Order placement, cancellation, amendment, trigger orders, TP/SL, position close, trade fills | Yes |
| [deepcoin-portfolio](skills/deepcoin-portfolio/SKILL.md) | Account balance, positions, leverage, sub-accounts, asset transfers, deposits/withdrawals, private WebSocket | Yes |
| [deepcoin-copytrade](skills/deepcoin-copytrade/SKILL.md) | Copy trading: leader settings, follower management, positions, profit tracking | Yes |
| [deepcoin-strategy](skills/deepcoin-strategy/SKILL.md) | DSL strategy orders with technical indicators (BOLL, MA, EMA, KDJ, RSI, WR) and backtesting | Yes |

## Layout

```text
skills/
  deepcoin-market/
    SKILL.md
  deepcoin-trade/
    SKILL.md
  deepcoin-portfolio/
    SKILL.md
  deepcoin-copytrade/
    SKILL.md
  deepcoin-strategy/
    SKILL.md
```

## Skill Routing

Each skill defines clear boundaries in its `description` field. An AI agent should use the description to route user requests to the correct skill:

- **Price / ticker / candles / orderbook / funding rate** → `deepcoin-market`
- **Place / cancel / amend orders / trigger orders / TP-SL** → `deepcoin-trade`
- **Balance / positions / leverage / transfers / sub-accounts** → `deepcoin-portfolio`
- **Copy trading setup / followers / leader positions** → `deepcoin-copytrade`
- **Automated strategies / backtesting / DSL orders** → `deepcoin-strategy`

## API Base URL

Users can pass a custom API Base URL.

- If `base_url` is provided, use that value.
- If `base_url` is not provided, default to `https://api.deepcoin.com`.

## Default Rate Limit

Unless an endpoint-specific exchange limit is documented separately, these skills should assume a conservative default of **1 request per second**.

- Apply the default to each endpoint group being called.
- Prefer aggregate or batch endpoints instead of high fan-out parallel requests.
- Serialize WRITE requests by default.
- If a request returns `429` or another explicit rate-limit signal, back off and retry later instead of replaying the entire batch immediately.

## Authentication

Authenticated endpoints require four headers:

| Header | Value |
|--------|-------|
| `DC-ACCESS-KEY` | API Key |
| `DC-ACCESS-SIGN` | `Base64(HMAC-SHA256(timestamp + method + requestPath + body, secretKey))` |
| `DC-ACCESS-TIMESTAMP` | ISO 8601 timestamp |
| `DC-ACCESS-PASSPHRASE` | Passphrase from API key creation |

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
