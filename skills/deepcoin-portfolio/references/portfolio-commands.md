# Deepcoin Portfolio CLI Commands

All commands require Deepcoin credentials. Confirm with the user before every WRITE command. Use `dcli account <command> --help` when a flag value is unclear.

## Account Reads

```bash
dcli account uid
dcli account all-balances [--account-type <types>] [--ccy <ccys>] [--json]
dcli account balance [--inst-type <SPOT|SWAP>] [--ccy <ccy>] [--json]
dcli account positions [--inst-type <SPOT|SWAP>] [--inst-id <id>] [--json]
dcli account bills --inst-type <SPOT|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]
```

Notes:

- For a complete balance view, use `dcli account all-balances --json`.
- `all-balances --account-type` accepts comma-separated account types: `funding`, `spot`, `swapU`, `swap`, `bonus`, `rebate`, `event`, `copyTrade`, `robot`, `all`.
- `all-balances --ccy` accepts comma-separated currencies, for example `USDT,BTC`.
- Use `balance --inst-type` only when the user specifically asks for the trading product balance.
- `bills` requires `--inst-type`.
- Use `--json` for parsing, aggregation, or follow-up commands.

## Account Writes

```bash
dcli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross|isolated> [--mrg-position <merge|split>]
```

Verify after write:

```bash
dcli account positions --inst-type SWAP --inst-id <id> --json
```

## Sub-Accounts

```bash
dcli account sub-accounts [--json]
dcli account sub-account-balance
dcli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>
dcli account sub-account-transfer-records [--coin <ccy>] [--page <n>] [--size <n>] [--json]
```

Verify after transfer:

```bash
dcli account sub-account-transfer-records --coin <ccy> --page 1 --size 20 --json
```

## Assets, Deposits, Withdrawal History

```bash
dcli account deposit-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]
dcli account withdraw-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]
dcli account recharge-chains --currency-id <id> [--json]
dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]
```

`withdraw-list` is history only. Withdrawal creation, cancellation, whitelist, status, and chain config are in `dcli withdrawal ...`.

Verify after account-scope transfer:

```bash
dcli account all-balances --ccy <ccy> --json
```

## Internal Transfers

```bash
dcli account internal-transfer-support
dcli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]
dcli account internal-transfer-history [--coin <ccy>] [--status <status>] [--page <n>] [--size <n>] [--json]
```

Verify after write:

```bash
dcli account internal-transfer-history --coin <ccy> --page 1 --size 20 --json
```

## Rebate and Affiliate Reads

```bash
dcli account rebate-summary --uid <uid> [--type <0|1|2>] [--start-time <ts>] [--end-time <ts>]
dcli account affiliates --uid <uid> [--start-time <ts>] [--end-time <ts>]
```

Use `dcli account uid` when the user asks for their own account and no UID is provided.

## Trade Statistics Reads

```bash
dcli account trade-stats-daily --uid <uid> --appid <id> [--instrument-ids <ids>] [--start-time <ts>] [--end-time <ts>]
dcli account trade-stats-total --uid <uid> --appid <id> [--start-time <ts>] [--end-time <ts>]
```

Ask for `appid` when it is required and not available from context.
