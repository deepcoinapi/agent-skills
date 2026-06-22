# Deepcoin Market CLI Commands

All commands are READ-only and do not require API credentials.

```bash
deepcoin-cli market instruments --inst-type <SPOT|SWAP> [--inst-id <id>] [--json]
deepcoin-cli market tickers --inst-type <SPOT|SWAP> [--json]
deepcoin-cli market ticker <INST_ID> [--json]
deepcoin-cli market orderbook <INST_ID> [--sz <n>] [--json]
deepcoin-cli market candles <INST_ID> [--bar <bar>] [--limit <n>] [--after <ts>] [--json]
deepcoin-cli market trades <INST_ID> [--product-group <Spot|Swap|SwapU>] [--limit <n>] [--json]
deepcoin-cli market funding-rate --inst-type <SwapU|Swap> [--inst-id <id>] [--json]
deepcoin-cli market funding-rate-history <INST_ID> [--page <n>] [--size <n>]
deepcoin-cli market book-spread <INST_ID> [--value <value>] [--vtype <0|1>]
deepcoin-cli market step-margin <INST_ID> [--json]
deepcoin-cli market server-time
deepcoin-cli market ping
```

Use `--json` when the user needs raw API data or when another tool will consume the result.
