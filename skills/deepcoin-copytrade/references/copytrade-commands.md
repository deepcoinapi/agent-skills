# Deepcoin Copy Trading CLI Commands

All commands require Deepcoin credentials. Confirm with the user before every WRITE command. Use `dcli copytrade <command> --help` when a flag value is unclear.

## Reads

```bash
dcli copytrade support-contracts [--json]
dcli copytrade followers --status <1|2> [--json]
dcli copytrade leader-positions [--page <n>] [--size <n>] [--json]
dcli copytrade position-type [--json]
dcli copytrade estimated-profit [--json]
dcli copytrade history-profit [--json]
```

Notes:

- `followers --status 1` lists active followers.
- `followers --status 2` lists inactive/history followers.
- Use `--json` for structured summaries and verification.

## Writes

```bash
dcli copytrade leader-settings --status <0|1> [--home-mode <1|3>] [--is-closed-copy-code <true|false>] [--copy-code <code>]
dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
dcli copytrade set-position-type --type <1|2>
```

Notes:

- `leader-settings --status 0` disables leader status; `--status 1` enables it.
- `set-contracts` uses compact symbols such as `BTCUSDT`.
- `set-position-type --type 1` means Hedge; `--type 2` means One-way.

## Verification

```bash
dcli copytrade support-contracts --json
dcli copytrade position-type --json
dcli copytrade leader-positions --page 1 --size 20 --json
```
