# Deepcoin Market CLI Commands

All commands are READ-only and do not require Deepcoin credentials. Use `dcli market <command> --help` when a flag value is unclear.

## Connectivity and Time

```bash
dcli market ping
dcli market server-time
```

## Instruments and Tickers

```bash
dcli market instruments --inst-type <SPOT|SWAP> [--inst-id <id>] [--json]
dcli market tickers --inst-type <SPOT|SWAP> [--json]
dcli market ticker <INST_ID> [--json]
```

Notes:

- Use `BTC-USDT` for spot examples.
- Use `BTC-USDT-SWAP` for swap examples.
- Query `instruments` before trading or strategy work when the symbol or precision is uncertain.

## Order Book, Trades, and Spread

```bash
dcli market orderbook <INST_ID> [--sz <n>] [--json]
dcli market trades <INST_ID> [--product-group <Spot|Swap|SwapU>] [--limit <n>] [--json]
dcli market book-spread <INST_ID> [--value <value>] [--vtype <0|1>]
```

Use bounded depth and trade limits unless the user explicitly asks for a larger sample.

## Candles

```bash
dcli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]
```

Use `--json` for backtests, charting, or calculations.

## Funding and Margin Metadata

```bash
dcli market funding-rate --inst-type <SwapU|Swap> [--inst-id <id>] [--json]
dcli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]
dcli market step-margin <INST_ID> [--json]
```

Funding and margin metadata are derivative-market concepts.
