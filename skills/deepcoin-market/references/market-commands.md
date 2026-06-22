# Deepcoin Market CLI Commands

All commands are READ-only and do not require API credentials.

```bash
dcli market instruments --inst-type <SPOT|SWAP> [--inst-id <id>] [--json]
dcli market tickers --inst-type <SPOT|SWAP> [--json]
dcli market ticker <INST_ID> [--json]
dcli market orderbook <INST_ID> [--sz <n>] [--json]
dcli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]
dcli market trades <INST_ID> [--product-group <Spot|Swap|SwapU>] [--limit <n>] [--json]
dcli market funding-rate --inst-type <SwapU|Swap> [--inst-id <id>] [--json]
dcli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]
dcli market book-spread <INST_ID> [--value <value>] [--vtype <0|1>]
dcli market step-margin <INST_ID> [--json]
dcli market server-time
dcli market ping
```

Use `--json` when the user needs raw API data or when another tool will consume the result.
