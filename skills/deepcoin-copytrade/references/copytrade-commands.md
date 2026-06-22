# Deepcoin Copy Trading CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

```bash
dcli copytrade leader-settings --status <0|1> [--home-mode <1|3>] [--is-closed-copy-code <true|false>] [--copy-code <code>]
dcli copytrade support-contracts [--json]
dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
dcli copytrade followers --status <1|2> [--json]
dcli copytrade leader-positions [--page <n>] [--size <n>] [--json]
dcli copytrade position-type [--json]
dcli copytrade set-position-type --type <1|2>
dcli copytrade estimated-profit [--json]
dcli copytrade history-profit [--json]
```

Use compact contract symbols such as `BTCUSDT` for `set-contracts`.
