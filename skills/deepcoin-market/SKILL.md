---
name: deepcoin-market
description: "Use this skill when the user asks for Deepcoin crypto prices, ticker data, order book depth, recent trades, K-line / candlestick data, funding rate, funding history, instrument metadata, tick size, minimum size, leverage tiers, step margin, book spread, server time, or market connectivity checks through dcli. Do NOT use for account balance / positions (use deepcoin-portfolio), order placement / cancellation (use deepcoin-trade), withdrawals (use deepcoin-withdrawal), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
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

Public market data on Deepcoin: tickers, order books, candles, trades, funding rates, instrument metadata, margin tiers, spreads, server time, and connectivity checks. No Deepcoin credentials are required.

## Preflight

Before running any command, follow [`references/dcli.md`](references/dcli.md).

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/market-commands.md`](references/market-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Prerequisites

1. Install `dcli` if it is not already available:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/deepcoinapi/agent-cli/main/install.sh | sh
   export PATH="$HOME/.local/bin:$PATH"
   ```
2. Verify the CLI and market command registry:
   ```bash
   dcli --version
   dcli list-tools
   dcli market ping
   ```

## Credential Check

Market commands are public reads. Do not ask for Deepcoin credentials for this skill.

If a market command fails because of local CLI installation, network, or exchange availability, report that failure and stop. Do not switch to a custom client.

## Deepcoin Mode

Market data is public exchange data. There is no demo/live switch for market reads in `dcli`.

Rules:

- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.
- Market output is not account-specific and should not be described as the user's holdings.

## Skill Routing

- Account balances, positions, deposits, transfers -> `deepcoin-portfolio`
- Order placement, cancellation, amendments, TP/SL, fills, closes -> `deepcoin-trade`
- Withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions -> `deepcoin-copytrade`
- Strategy DSL drafting, backtests, live DSL trigger orders -> `deepcoin-strategy`
- Prices, candles, order books, trades, funding, instruments, spread, margin tiers, server time -> this skill

## Quickstart

```bash
# Connectivity and server time
dcli market ping
dcli market server-time

# Instruments and ticker
dcli market instruments --inst-type SWAP --json
dcli market ticker BTC-USDT-SWAP --json
dcli market tickers --inst-type SWAP --json

# Candles, order book, trades
dcli market candles BTC-USDT-SWAP --bar 1H --limit 100 --json
dcli market orderbook BTC-USDT-SWAP --sz 20 --json
dcli market trades BTC-USDT-SWAP --product-group SwapU --limit 20 --json

# Funding and margin metadata
dcli market funding-rate --inst-type SwapU --inst-id BTC-USDT-SWAP --json
dcli market funding-rate-history BTC-USDT-SWAP --page 1 --size 20
dcli market step-margin BTC-USDT-SWAP --json
```

## Command Index

### Read Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli market instruments --inst-type <SPOT\|SWAP> [--inst-id <id>] [--json]` | READ | Tradeable instruments and metadata |
| 2 | `dcli market tickers --inst-type <SPOT\|SWAP> [--json]` | READ | Tickers for an instrument type |
| 3 | `dcli market ticker <INST_ID> [--json]` | READ | Ticker for one instrument |
| 4 | `dcli market orderbook <INST_ID> [--sz <n>] [--json]` | READ | Order book depth |
| 5 | `dcli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]` | READ | Candlestick data |
| 6 | `dcli market trades <INST_ID> [--product-group <Spot\|Swap\|SwapU>] [--limit <n>] [--json]` | READ | Recent trades |
| 7 | `dcli market funding-rate --inst-type <SwapU\|Swap> [--inst-id <id>] [--json]` | READ | Current funding rates |
| 8 | `dcli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]` | READ | Funding-rate history |
| 9 | `dcli market book-spread <INST_ID> [--value <value>] [--vtype <0\|1>]` | READ | Bid-ask spread estimate |
| 10 | `dcli market step-margin <INST_ID> [--json]` | READ | Margin tiers |
| 11 | `dcli market server-time` | READ | Exchange server time |
| 12 | `dcli market ping` | READ | Connectivity check |

## Cross-Skill Workflows

### Pre-trade price check

> User: "I want to buy BTC. What's the price?"

```text
1. deepcoin-market     dcli market ticker BTC-USDT --json
2. deepcoin-portfolio  dcli account balance --inst-type SPOT --ccy USDT --json, only if user asks affordability
   -> user confirms order details
3. deepcoin-trade      dcli trade place-order ...
```

### Position context

> User: "How is my BTC swap position doing?"

```text
1. deepcoin-portfolio  dcli account positions --inst-type SWAP --inst-id BTC-USDT-SWAP --json
2. deepcoin-market     dcli market ticker BTC-USDT-SWAP --json
3. deepcoin-market     dcli market funding-rate --inst-type SwapU --inst-id BTC-USDT-SWAP --json, if funding context is requested
```

### Strategy input data

> User: "Backtest a BTC strategy using recent candles."

```text
1. deepcoin-market     dcli market candles BTC-USDT-SWAP --bar 1H --limit 100 --json
2. deepcoin-strategy   draft or backtest DSL using dcli strategy ...
```

## Operation Flow

### Step 1: Identify market data type

- Single price / "BTC price" -> `dcli market ticker <INST_ID>`.
- All prices for a product type -> `dcli market tickers --inst-type <SPOT|SWAP>`.
- Tradable contracts or symbol metadata -> `dcli market instruments`.
- Order book / spread / liquidity -> `orderbook` or `book-spread`.
- K-line / candles -> `candles`.
- Recent transactions -> `trades`.
- Funding -> `funding-rate` or `funding-rate-history`.
- Margin tier / leverage metadata -> `step-margin`.
- Connectivity / time -> `ping` or `server-time`.

### Step 2: Choose instrument and product group

- Use canonical spot IDs such as `BTC-USDT`.
- Use canonical perpetual swap IDs such as `BTC-USDT-SWAP`.
- For `trades`, use product group `Spot`, `Swap`, or `SwapU` when the user or instrument implies it.
- If the symbol is ambiguous, query `dcli market instruments --inst-type <SPOT|SWAP> --json` before guessing.

### Step 3: Run read commands immediately

Market commands are read-only and need no confirmation.

Rules:

- Prefer `--json` when comparing, summarizing multiple symbols, or feeding another skill.
- For human-only one-off price checks, table output is acceptable.
- Use bounded `--limit` / `--size`; do not loop all symbols unless the user asks for a broad scan.

## CLI Command Reference

### Instruments

```bash
dcli market instruments --inst-type <SPOT|SWAP> [--inst-id <id>] [--json]
```

Use this to validate symbol spelling, tick size, minimum size, and instrument metadata before trading or strategy work.

### Tickers

```bash
dcli market ticker <INST_ID> [--json]
dcli market tickers --inst-type <SPOT|SWAP> [--json]
```

Use `ticker` for one instrument and `tickers` for a broad product-type snapshot.

### Order Book and Trades

```bash
dcli market orderbook <INST_ID> [--sz <n>] [--json]
dcli market trades <INST_ID> [--product-group <Spot|Swap|SwapU>] [--limit <n>] [--json]
dcli market book-spread <INST_ID> [--value <value>] [--vtype <0|1>]
```

Use order book for current depth, trades for recent executed prints, and book spread for spread estimates.

### Candles

```bash
dcli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]
```

Use exchange-supported bar values. If the user does not specify a timeframe, choose a common interval for the task and state it.

### Funding and Margin Metadata

```bash
dcli market funding-rate --inst-type <SwapU|Swap> [--inst-id <id>] [--json]
dcli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]
dcli market step-margin <INST_ID> [--json]
```

Funding and margin tier data apply to derivative instruments, not spot pairs.

## Input / Output Examples

**"BTC price on Deepcoin"**

```bash
dcli market ticker BTC-USDT-SWAP --json
# -> summarize last price, bid/ask, 24h high/low, and timestamp when present
```

**"Show BTC order book depth"**

```bash
dcli market orderbook BTC-USDT-SWAP --sz 20 --json
# -> summarize best bid/ask and top levels
```

**"Get 1H candles for BTC"**

```bash
dcli market candles BTC-USDT-SWAP --bar 1H --limit 100 --json
# -> return or summarize OHLCV rows
```

**"What are funding rates?"**

```bash
dcli market funding-rate --inst-type SwapU --inst-id BTC-USDT-SWAP --json
# -> summarize funding rate and next funding time when present
```

## Edge Cases

- Empty ticker or candle output often means the instrument ID is wrong; validate with `dcli market instruments`.
- Spot instruments use IDs like `BTC-USDT`; swaps commonly use `BTC-USDT-SWAP`.
- Funding and step margin are derivative concepts; do not run them for spot unless `dcli` supports it.
- Streaming is not exposed by `dcli`. Report it as a CLI gap instead of writing a temporary streaming client.
- Market data is raw exchange data, not investment advice.

## Global Notes

- All commands in this skill are read-only.
- No credentials are required for market reads.
- Use `--json` for aggregation, comparison, charting, or downstream skills.
- If a requested market capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
