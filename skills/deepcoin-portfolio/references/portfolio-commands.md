# Deepcoin Portfolio CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

## Account Reads

```bash
dcli account balance [--inst-type <SPOT|SWAP>] [--ccy <ccy>] [--json]
dcli account positions [--inst-type <SPOT|SWAP>] [--inst-id <id>] [--json]
dcli account bills --inst-type <SPOT|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]
dcli account uid
```

## Account Writes

```bash
dcli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross|isolated> [--mrg-position <merge|split>]
```

## Sub-Account, Asset, Internal Transfer

```bash
dcli account sub-accounts [--json]
dcli account sub-account-balance
dcli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>
dcli account sub-account-transfer-records [--coin <ccy>] [--page <n>] [--size <n>] [--json]
dcli account deposit-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]
dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]
dcli account recharge-chains --currency-id <id> [--json]
dcli account internal-transfer-support
dcli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]
dcli account internal-transfer-history [--coin <ccy>] [--status <status>] [--page <n>] [--size <n>] [--json]
```

Withdrawal create/cancel/status/config commands are intentionally in `dcli withdrawal ...`, not this portfolio command group.
