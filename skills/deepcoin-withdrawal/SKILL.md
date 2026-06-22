---
name: deepcoin-withdrawal
description: "Use this skill when the user wants to create, cancel, pre-check, configure, or query Deepcoin on-chain withdrawals, including withdrawal records, withdrawal status, withdrawable assets, supported withdrawal chains, whitelist withdrawal addresses, withdrawal config, memo/tag requirements, fees, limits, and debit account selection. Do NOT use for generic balances, positions, deposits, internal transfers, sub-account transfers, trading orders, copy trading, or strategy orders."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.2"
  homepage: "https://github.com/deepcoinapi/agent-cli"
  agent:
    requires:
      bins: ["dcli"]
    install:
      - id: shell
        kind: shell
        command: "curl -fsSL https://raw.githubusercontent.com/deepcoinapi/agent-cli/main/install.sh | sh"
        bins: ["dcli"]
        label: "Install dcli"
  openclaw:
    primaryEnv: DC_API_KEY
    requires:
      env: ["DC_API_KEY", "DC_SECRET_KEY", "DC_PASSPHRASE"]
---

# Deepcoin Withdrawal CLI

On-chain withdrawal pre-checks, supported assets, chains, whitelist addresses, records, status, create, and cancel workflows on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/withdrawal-commands.md`](references/withdrawal-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Credential Check

Authenticated commands require Deepcoin credentials in environment variables. Prefer `DEEPCOIN_API_KEY`, `DEEPCOIN_SECRET_KEY`, and `DEEPCOIN_PASSPHRASE`; `DC_*` aliases are supported.

Never ask the user to paste credentials into chat.

## Skill Routing

- Balances, positions, deposits, transfers, sub-accounts -> `deepcoin-portfolio`
- Orders, triggers, TP/SL, closes, fills -> `deepcoin-trade`
- Market data -> `deepcoin-market`
- Copy trading -> `deepcoin-copytrade`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Withdrawal config, whitelist, records, create/cancel/status -> this skill

## Quickstart

```bash
# Withdrawal config and whitelist
dcli withdrawal config --ccy USDT --include-addresses true

# Supported chains
dcli withdrawal chains --ccy USDT

# Recent withdrawal records
dcli withdrawal records --coin USDT --page 1 --size 20

# Single withdrawal status
dcli withdrawal status --wd-id <id> --ccy USDT
```

## Command Index

### Read Commands

| # | Command | Description |
|---|---|---|
| 1 | `dcli withdrawal config [--ccy <ccy>] [--include-addresses true]` | Aggregated withdrawal config |
| 2 | `dcli withdrawal assets [--ccy <ccy>]` | Withdrawable assets |
| 3 | `dcli withdrawal chains --ccy <ccy>` | Supported withdrawal chains |
| 4 | `dcli withdrawal addresses --ccy <ccy>` | Whitelist addresses |
| 5 | `dcli withdrawal records [--coin <ccy>] [--ccy <ccy>] [--chain <chain>] [--tx-hash <hash>] [--tx-id <id>] [--wd-id <id>] [--state <state>] [--start-time <ms>] [--end-time <ms>] [--page <n>] [--size <n>]` | Withdrawal records |
| 6 | `dcli withdrawal status --wd-id <id> [--ccy <ccy>]` | Single withdrawal status |

### Write Commands

Confirm with the user before running any write command.

| # | Command | Description |
|---|---|---|
| 7 | `dcli withdrawal create --ccy <ccy> --chain <chain> --amt <amount> --address-id <id> [--to-addr <address>] [--memo <memo>] [--account-types <funding\|spot\|swap>] [--client-id <id>] [--remark <text>]` | Create withdrawal |
| 8 | `dcli withdrawal cancel --wd-id <id> [--ccy <ccy>] [--client-id <id>]` | Cancel withdrawal |

## Operation Flow

1. Identify intent: pre-check, list config, list records, check status, create, or cancel.
2. Select the matching command from [`references/withdrawal-commands.md`](references/withdrawal-commands.md).
3. For read commands, run directly after credential preflight.
4. Before create, run `dcli withdrawal config --ccy <ccy> --include-addresses true` unless validated config is already available.
5. For create or cancel, summarize the action and wait for explicit user confirmation.
6. Run the selected `dcli withdrawal ...` command once.
7. Verify create/cancel with `dcli withdrawal status` or `dcli withdrawal records`.
8. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## Write Confirmation Rules

Before create or cancel, summarize:

- operation
- coin, amount, chain, and debit account for create
- whitelist address ID and memo/tag status for create
- withdrawal ID for cancel
- verification command to run afterward

Do not treat vague approval as confirmation for withdrawal operations.

## Response Rules

- Prefer pre-checks before create.
- Never replay withdrawal writes automatically after an uncertain error.
- Keep withdrawal addresses and IDs concise; avoid printing unnecessary sensitive details.
- Use only documented `dcli` commands; do not provide low-level protocol or signing instructions.
