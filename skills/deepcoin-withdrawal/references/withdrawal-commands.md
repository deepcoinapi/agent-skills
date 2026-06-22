# Deepcoin Withdrawal CLI Commands

All commands require API credentials. Confirm with the user before `create` or `cancel`.

## Read / Pre-Check

```bash
deepcoin-cli withdrawal config [--ccy <ccy>] [--include-addresses true]
deepcoin-cli withdrawal assets [--ccy <ccy>]
deepcoin-cli withdrawal chains --ccy <ccy>
deepcoin-cli withdrawal addresses --ccy <ccy>
deepcoin-cli withdrawal records [--coin <ccy>] [--ccy <ccy>] [--chain <chain>] [--tx-hash <hash>] [--tx-id <id>] [--wd-id <id>] [--state <state>] [--start-time <ms>] [--end-time <ms>] [--page <n>] [--size <n>]
deepcoin-cli withdrawal status --wd-id <id> [--ccy <ccy>]
```

## Writes

```bash
deepcoin-cli withdrawal create --ccy <ccy> --chain <chain> --amt <amount> --address-id <id> [--to-addr <address>] [--memo <memo>] [--account-types <funding|spot|swap>] [--client-id <id>] [--remark <text>]
deepcoin-cli withdrawal cancel --wd-id <id> [--ccy <ccy>] [--client-id <id>]
```

Before `create`, run `config --ccy <ccy> --include-addresses true` unless equivalent validated config is already available in context.
