---
name: deepcoin-withdrawal
description: "Use this skill when the user wants to create, cancel, pre-check, configure, or query Deepcoin on-chain withdrawals through dcli, including withdrawal records, status, withdrawable assets, supported chains, whitelist addresses, withdrawal config, memo/tag requirements, fees, limits, debit account selection, address ID validation, or withdrawal history by tx hash / withdrawal ID. Do NOT use for generic balances, positions, deposits, internal transfers, sub-account transfers, trading orders, copy trading, or strategy orders."
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

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/withdrawal-commands.md`](references/withdrawal-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Prerequisites

1. Install `dcli` if it is not already available:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/deepcoinapi/agent-cli/main/install.sh | sh
   export PATH="$HOME/.local/bin:$PATH"
   ```
2. Configure credentials in the local shell environment:
   ```bash
   export DEEPCOIN_API_KEY=...
   export DEEPCOIN_SECRET_KEY=...
   export DEEPCOIN_PASSPHRASE=...
   ```
3. Verify CLI and command registry:
   ```bash
   dcli --version
   dcli list-tools
   ```

Compatibility aliases are supported: `DC_API_KEY`, `DC_SECRET_KEY`, `DC_PASSPHRASE`.

Security rule: never ask the user to paste credentials, private keys, seed phrases, or raw withdrawal secrets into chat.

## Credential Check

Run this before any authenticated command:

```bash
test -n "${DEEPCOIN_API_KEY:-${DC_API_KEY:-}}" &&
test -n "${DEEPCOIN_SECRET_KEY:-${DC_SECRET_KEY:-}}" &&
test -n "${DEEPCOIN_PASSPHRASE:-${DC_PASSPHRASE:-}}"
dcli account uid
```

Branch in this order:

- All three credential variables exist and `dcli account uid` succeeds -> proceed.
- Variables exist but `dcli account uid` fails -> stop, report authentication failed, and ask the user to verify key permissions, passphrase, and system clock.
- Any variable is missing -> stop and ask the user to set local environment variables.

Do not retry credential failures in a loop.

## Deepcoin Mode

`dcli` currently uses the configured Deepcoin environment. There is no skill-level demo/live switch.

Rules:

- State that commands run against the user's configured Deepcoin environment.
- Withdrawal create/cancel always requires explicit confirmation.
- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.

## Skill Routing

- Balances, positions, deposits, internal transfers, sub-account transfers -> `deepcoin-portfolio`
- Orders, triggers, TP/SL, closes, fills -> `deepcoin-trade`
- Market prices and chains' market context -> `deepcoin-market`
- Copy trading -> `deepcoin-copytrade`
- Strategy DSL and backtests -> `deepcoin-strategy`
- On-chain withdrawal config, whitelist, records, create/cancel/status -> this skill

## Quickstart

```bash
# Withdrawal config and whitelist
dcli withdrawal config --ccy USDT --include-addresses true

# Withdrawable assets and supported chains
dcli withdrawal assets --ccy USDT
dcli withdrawal chains --ccy USDT
dcli withdrawal addresses --ccy USDT

# Records and status
dcli withdrawal records --coin USDT --page 1 --size 20
dcli withdrawal status --wd-id <id> --ccy USDT

# Create only after explicit confirmation
dcli withdrawal create --ccy USDT --chain USDT-TRC20 --amt 100 --address-id <id> --account-types funding --client-id <id>
```

## Command Index

### Read / Pre-Check Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli withdrawal config [--ccy <ccy>] [--include-addresses true]` | READ | Aggregated withdrawal config |
| 2 | `dcli withdrawal assets [--ccy <ccy>]` | READ | Withdrawable assets |
| 3 | `dcli withdrawal chains --ccy <ccy>` | READ | Supported withdrawal chains |
| 4 | `dcli withdrawal addresses --ccy <ccy>` | READ | Whitelist addresses |
| 5 | `dcli withdrawal records [--coin <ccy>] [--ccy <ccy>] [--chain <chain>] [--tx-hash <hash>] [--tx-id <id>] [--wd-id <id>] [--state <state>] [--start-time <ms>] [--end-time <ms>] [--page <n>] [--size <n>]` | READ | Withdrawal records |
| 6 | `dcli withdrawal status --wd-id <id> [--ccy <ccy>]` | READ | Single withdrawal status |

### Write Commands

Confirm with the user before every write command.

| # | Command | Type | Description |
|---|---|---|---|
| 7 | `dcli withdrawal create --ccy <ccy> --chain <chain> --amt <amount> --address-id <id> [--to-addr <address>] [--memo <memo>] [--account-types <funding\|spot\|swap>] [--client-id <id>] [--remark <text>]` | WRITE | Create withdrawal |
| 8 | `dcli withdrawal cancel --wd-id <id> [--ccy <ccy>] [--client-id <id>]` | WRITE | Cancel withdrawal |

## Cross-Skill Workflows

### Pre-check before withdrawal

> User: "Can I withdraw 100 USDT on TRC20?"

```text
1. deepcoin-portfolio   dcli account balance --inst-type SPOT --ccy USDT --json, if balance context is needed
2. deepcoin-withdrawal  dcli withdrawal config --ccy USDT --include-addresses true
3. deepcoin-withdrawal  dcli withdrawal chains --ccy USDT
4. deepcoin-withdrawal  dcli withdrawal addresses --ccy USDT
```

### Create withdrawal

> User: "Withdraw 100 USDT to my whitelisted TRC20 address."

```text
1. deepcoin-withdrawal  dcli withdrawal config --ccy USDT --include-addresses true
2. deepcoin-withdrawal  dcli withdrawal addresses --ccy USDT
   -> user confirms coin, chain, amount, address ID, memo/tag, debit account, and exact command
3. deepcoin-withdrawal  dcli withdrawal create ...
4. deepcoin-withdrawal  dcli withdrawal status --wd-id <id> --ccy USDT, or records if ID is not returned
```

### Cancel withdrawal

> User: "Cancel withdrawal 123."

```text
1. deepcoin-withdrawal  dcli withdrawal status --wd-id 123 --ccy <ccy>, if ccy is known
   -> user confirms cancellation
2. deepcoin-withdrawal  dcli withdrawal cancel --wd-id 123 --ccy <ccy>
3. deepcoin-withdrawal  dcli withdrawal status --wd-id 123 --ccy <ccy>
```

## Operation Flow

### Step 0: Credential Check

Before any authenticated command, run the [Credential Check](#credential-check). After results, state that the configured Deepcoin environment was used.

### Step 1: Identify withdrawal intent

- Config / all pre-check info -> `config`.
- Withdrawable assets -> `assets`.
- Supported chains -> `chains`.
- Whitelist addresses -> `addresses`.
- History / filtering -> `records`.
- One withdrawal status -> `status`.
- Create on-chain withdrawal -> write flow.
- Cancel withdrawal -> write flow.

### Step 2: Run read commands immediately

Read commands do not need user confirmation after credentials are configured.

Rules:

- Before create, run `dcli withdrawal config --ccy <ccy> --include-addresses true` unless equivalent validated data is already in context.
- Use `addresses --ccy <ccy>` to identify whitelist address IDs.
- Use `records` for history and filtering by tx hash, tx ID, withdrawal ID, state, or time range.

### Step 3: Confirm before writes

Before create or cancel, show the exact command and wait for explicit confirmation.

For create, confirm:

- coin
- amount
- chain
- debit account type
- whitelist address ID
- destination address consistency check, if `--to-addr` is used
- memo/tag/payment ID status
- client ID, if provided
- verification command

For cancel, confirm:

- withdrawal ID
- coin, if known
- client ID, if provided
- verification command

### Step 4: Verify after writes

- After create: run `dcli withdrawal status --wd-id <id> --ccy <ccy>` if an ID is returned; otherwise run `records` with coin and latest page.
- After cancel: run `dcli withdrawal status --wd-id <id> --ccy <ccy>` or `records --wd-id <id>`.

Never replay withdrawal writes automatically after an uncertain error. Query state first.

## CLI Command Reference

### Config and Whitelist

```bash
dcli withdrawal config [--ccy <ccy>] [--include-addresses true]
dcli withdrawal assets [--ccy <ccy>]
dcli withdrawal chains --ccy <ccy>
dcli withdrawal addresses --ccy <ccy>
```

Use config plus addresses before create to validate chain, address ID, memo/tag needs, fees, limits, and account scope.

### Records and Status

```bash
dcli withdrawal records [--coin <ccy>] [--ccy <ccy>] [--chain <chain>] [--tx-hash <hash>] [--tx-id <id>] [--wd-id <id>] [--state <state>] [--start-time <ms>] [--end-time <ms>] [--page <n>] [--size <n>]
dcli withdrawal status --wd-id <id> [--ccy <ccy>]
```

Use `records` for history and filters; use `status` when the withdrawal ID is known.

### Create and Cancel

```bash
dcli withdrawal create --ccy <ccy> --chain <chain> --amt <amount> --address-id <id> [--to-addr <address>] [--memo <memo>] [--account-types <funding|spot|swap>] [--client-id <id>] [--remark <text>]
dcli withdrawal cancel --wd-id <id> [--ccy <ccy>] [--client-id <id>]
```

`--address-id` is required for create. `--account-types` accepts at most one account type.

## Input / Output Examples

**"Show USDT withdrawal config."**

```bash
dcli withdrawal config --ccy USDT --include-addresses true
# -> summarize supported chains, limits, fees, memo requirements, and whitelist address IDs
```

**"Check withdrawal status."**

```bash
dcli withdrawal status --wd-id <id> --ccy USDT
# -> summarize state, amount, chain, tx hash, and timestamps when present
```

**"Withdraw 100 USDT on TRC20."**

```bash
dcli withdrawal config --ccy USDT --include-addresses true
# -> user confirms exact create command
dcli withdrawal create --ccy USDT --chain USDT-TRC20 --amt 100 --address-id <id> --account-types funding --client-id <id>
```

## Edge Cases

- Withdrawal creation requires a whitelist address ID; do not accept an arbitrary raw address as sufficient.
- Memo/tag/payment ID may be required for some chains; confirm before create.
- Chain names must match `dcli withdrawal chains --ccy <ccy>` output.
- `--account-types` accepts at most one debit account type.
- Cancellation may fail if the withdrawal is already processed; verify status before and after cancel.
- Do not print full destination addresses unless needed; prefer address labels/IDs and truncated addresses.

## Global Notes

- All commands in this skill require Deepcoin credentials.
- Create and cancel are high-risk writes and require explicit confirmation.
- Prefer pre-checks before create.
- If a requested withdrawal capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
