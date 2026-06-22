# Deepcoin Portfolio CLI Commands

All commands require API credentials. Confirm with the user before every WRITE command.

## Account Reads

```bash
deepcoin-cli account balance [--inst-type <SPOT|SWAP>] [--ccy <ccy>] [--json]
deepcoin-cli account positions [--inst-type <SPOT|SWAP>] [--inst-id <id>] [--json]
deepcoin-cli account bills --inst-type <SPOT|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]
deepcoin-cli account uid
```

## Account Writes

```bash
deepcoin-cli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross|isolated> [--mrg-position <merge|split>]
```

## Sub-Account, Asset, Internal Transfer

```bash
deepcoin-cli account sub-accounts [--json]
deepcoin-cli account sub-account-balance
deepcoin-cli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>
deepcoin-cli account sub-account-transfer-records [--coin <ccy>] [--page <n>] [--size <n>] [--json]
deepcoin-cli account deposit-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]
deepcoin-cli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]
deepcoin-cli account recharge-chains --currency-id <id> [--json]
deepcoin-cli account internal-transfer-support
deepcoin-cli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]
deepcoin-cli account internal-transfer-history [--coin <ccy>] [--status <status>] [--page <n>] [--size <n>] [--json]
```

Withdrawal create/cancel/status/config commands are intentionally in `deepcoin-cli withdrawal ...`, not this portfolio command group.
