---
name: deepcoin-market
description: "Use this skill when the user asks for: price of any crypto asset on Deepcoin, ticker data, order book depth, recent trades, K-line / candlestick data (regular, mark-price, index-price), funding rate, instrument metadata (tickSz, minSz, leverage tiers), step margin, book spread, system time, or market connectivity checks through dcli. Do NOT use for account balance / positions (use deepcoin-portfolio), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.2"
  homepage: "https://github.com/deepcoinapi/agent-cli"
  agent:
    requires:
      bins: ["dcli"]
    install:
      - id: shell
        kind: shell
        command: "curl -fsSL https://raw.githubusercontent.com/deepcoinapi/agent-cli/main/install.sh | sh"
        bins: ["dcli"]
        label: "Install dcli"
---

# Deepcoin Market CLI

Public market data on Deepcoin: tickers, order books, candles, trades, funding rates, instrument metadata, margin tiers, spreads, time, and connectivity checks. No API credentials are required for this skill.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/market-commands.md`](references/market-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Skill Routing

- Account balance, positions, leverage, transfers -> `deepcoin-portfolio`
- Order placement, cancellation, amendments, TP/SL, fills -> `deepcoin-trade`
- On-chain withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions -> `deepcoin-copytrade`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Prices, candles, order books, trades, funding, instruments -> this skill

## Quickstart

```bash
# Connectivity
dcli market ping

# Single instrument ticker
dcli market ticker BTC-USDT-SWAP --json

# All swap tickers
dcli market tickers --inst-type SWAP --json

# Candles
dcli market candles BTC-USDT-SWAP --bar 1H --limit 100 --json

# Order book
dcli market orderbook BTC-USDT-SWAP --sz 20 --json
```

## Command Index

| # | Command | Description |
|---|---|---|
| 1 | `dcli market instruments --inst-type <SPOT\|SWAP> [--inst-id <id>] [--json]` | Tradeable instruments and metadata |
| 2 | `dcli market tickers --inst-type <SPOT\|SWAP> [--json]` | Tickers for an instrument type |
| 3 | `dcli market ticker <INST_ID> [--json]` | Ticker for one instrument |
| 4 | `dcli market orderbook <INST_ID> [--sz <n>] [--json]` | Order book depth |
| 5 | `dcli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]` | Candlestick data |
| 6 | `dcli market trades <INST_ID> [--product-group <Spot\|Swap\|SwapU>] [--limit <n>] [--json]` | Recent trades |
| 7 | `dcli market funding-rate --inst-type <SwapU\|Swap> [--inst-id <id>] [--json]` | Current funding rates |
| 8 | `dcli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]` | Funding-rate history |
| 9 | `dcli market book-spread <INST_ID> [--value <value>] [--vtype <0\|1>]` | Bid-ask spread estimate |
| 10 | `dcli market step-margin <INST_ID> [--json]` | Margin tiers |
| 11 | `dcli market server-time` | Exchange server time |
| 12 | `dcli market ping` | Connectivity check |

## Operation Flow

1. Identify the requested data type: ticker, candles, order book, trades, funding, instruments, spread, margin tier, or time.
2. Select the matching command from [`references/market-commands.md`](references/market-commands.md).
3. Run the command directly. Add `--json` when raw output is needed.
4. If several independent reads are needed, prefer aggregate commands before looping.
5. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## Notes

- Market commands are read-only.
- Market data is raw exchange data, not financial advice.
- Streaming is currently not exposed by `dcli`. Report it as missing instead of writing a temporary client.
- Use canonical instrument IDs such as `BTC-USDT` for spot and `BTC-USDT-SWAP` for perpetual swaps.
