# Deepcoin Withdrawal CLI Commands

All commands require Deepcoin credentials. Confirm with the user before `create` or `cancel`. Use `dcli withdrawal <command> --help` when a flag value is unclear.

## Read / Pre-Check

```bash
dcli withdrawal config [--ccy <ccy>] [--include-addresses true]
dcli withdrawal assets [--ccy <ccy>]
dcli withdrawal chains --ccy <ccy>
dcli withdrawal addresses --ccy <ccy>
dcli withdrawal records [--coin <ccy>] [--ccy <ccy>] [--chain <chain>] [--tx-hash <hash>] [--tx-id <id>] [--wd-id <id>] [--state <state>] [--start-time <ms>] [--end-time <ms>] [--page <n>] [--size <n>]
dcli withdrawal status --wd-id <id> [--ccy <ccy>]
```

Before create, run:

```bash
dcli withdrawal config --ccy <ccy> --include-addresses true
dcli withdrawal addresses --ccy <ccy>
dcli withdrawal chains --ccy <ccy>
```

## Writes

```bash
dcli withdrawal create --ccy <ccy> --chain <chain> --amt <amount> --address-id <id> [--to-addr <address>] [--memo <memo>] [--account-types <funding|spot|swap>] [--client-id <id>] [--remark <text>]
dcli withdrawal cancel --wd-id <id> [--ccy <ccy>] [--client-id <id>]
```

Notes:

- `--address-id` is required for create.
- `--account-types` accepts at most one of `funding`, `spot`, or `swap`.
- Confirm memo/tag requirements from config before create.
- Never replay create/cancel automatically after uncertain errors.

## Verification

```bash
dcli withdrawal status --wd-id <id> --ccy <ccy>
dcli withdrawal records --coin <ccy> --page 1 --size 20
dcli withdrawal records --wd-id <id> [--ccy <ccy>]
```
