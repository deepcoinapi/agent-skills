# Deepcoin Copy Trading CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

```bash
deepcoin-cli copytrade leader-settings --status <0|1> [--home-mode <1|3>] [--is-closed-copy-code <true|false>] [--copy-code <code>]
deepcoin-cli copytrade support-contracts [--json]
deepcoin-cli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
deepcoin-cli copytrade followers --status <1|2> [--json]
deepcoin-cli copytrade leader-positions [--page <n>] [--size <n>] [--json]
deepcoin-cli copytrade position-type [--json]
deepcoin-cli copytrade set-position-type --type <1|2>
deepcoin-cli copytrade estimated-profit [--json]
deepcoin-cli copytrade history-profit [--json]
```

Use compact contract symbols such as `BTCUSDT` for `set-contracts`.
