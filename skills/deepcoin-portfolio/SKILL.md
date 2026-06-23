---
name: deepcoin-portfolio
description: "Use this skill when the user asks for Deepcoin account balance, total holdings, available balance, frozen balance, equity, unrealized PnL, open positions, position details, account bills / ledger history, UID, leverage settings, sub-account list or transfers, deposits, withdrawal history, asset transfers, internal transfers, rebate / affiliate data, or account trade statistics through dcli. Do NOT use for on-chain withdrawal create / cancel / status / whitelist / chain config (use deepcoin-withdrawal), public market data (use deepcoin-market), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
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

# Deepcoin Portfolio CLI

Account balances, positions, bills, deposits, withdrawals history, transfers, leverage, sub-accounts, rebates, affiliates, and trade statistics on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`references/dcli.md`](references/dcli.md).

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/portfolio-commands.md`](references/portfolio-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

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
3. Verify the CLI and command registry:
   ```bash
   dcli --version
   dcli list-tools
   ```

Compatibility aliases are supported: `DC_API_KEY`, `DC_SECRET_KEY`, `DC_PASSPHRASE`.

Security rule: never ask the user to paste credentials into chat. If credentials are missing, ask them to configure environment variables locally.

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

Do not retry credential failures in a loop. Fix configuration first, then retry the original command once.

## Deepcoin Mode

`dcli` currently uses the configured Deepcoin environment. There is no skill-level demo/live switch.

Rules:

- State that commands run against the user's configured Deepcoin environment when reporting results.
- Before write commands, confirm the command and the account scope explicitly.
- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.

## Skill Routing

- Market prices, candles, order books, trades, funding, instruments -> `deepcoin-market`
- Order placement, cancellation, amendments, TP/SL, fills, close position -> `deepcoin-trade`
- On-chain withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions, copy profit -> `deepcoin-copytrade`
- Strategy DSL drafting, backtests, live DSL trigger orders -> `deepcoin-strategy`
- Balances, positions, bills, deposits, withdrawal history, transfers, sub-accounts, rebates, affiliates, trade stats -> this skill

## Quickstart

```bash
# Current account UID
dcli account uid

# Unified balance across all account types
dcli account all-balances --json

# USDT balance across funding, spot, swap, copy trading, and other accounts
dcli account all-balances --ccy USDT --json

# Trading product balance when the user specifically asks for spot or swap
dcli account balance --inst-type SPOT --ccy USDT --json
dcli account balance --inst-type SWAP --ccy USDT --json

# Open swap positions
dcli account positions --inst-type SWAP --json

# Recent account bills
dcli account bills --inst-type SWAP --limit 20 --json

# Deposit and withdrawal history
dcli account deposit-list --coin USDT --page 1 --size 20 --json
dcli account withdraw-list --coin USDT --page 1 --size 20 --json

# Sub-account overview
dcli account sub-accounts --json
dcli account sub-account-balance
```

## Command Index

### Read Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli account uid` | READ | Current account UID |
| 2 | `dcli account all-balances [--account-type <types>] [--ccy <ccys>] [--json]` | READ | Unified balances across account types |
| 3 | `dcli account balance [--inst-type <SPOT\|SWAP>] [--ccy <ccy>] [--json]` | READ | Trading product balance by account scope and currency |
| 4 | `dcli account positions [--inst-type <SPOT\|SWAP>] [--inst-id <id>] [--json]` | READ | Open positions |
| 5 | `dcli account bills --inst-type <SPOT\|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]` | READ | Account ledger history |
| 6 | `dcli account sub-accounts [--json]` | READ | Sub-account list |
| 7 | `dcli account sub-account-balance` | READ | Total sub-account balance |
| 8 | `dcli account sub-account-transfer-records [--coin <ccy>] [--page <n>] [--size <n>] [--json]` | READ | Sub-account transfer records |
| 9 | `dcli account deposit-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]` | READ | Deposit history |
| 10 | `dcli account withdraw-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]` | READ | Withdrawal history |
| 11 | `dcli account recharge-chains --currency-id <id> [--json]` | READ | Deposit chains for a currency ID |
| 12 | `dcli account internal-transfer-support` | READ | Coins supported for internal transfer |
| 13 | `dcli account internal-transfer-history [--coin <ccy>] [--status <status>] [--page <n>] [--size <n>] [--json]` | READ | Internal transfer history |
| 14 | `dcli account rebate-summary --uid <uid> [--type <0\|1\|2>] [--start-time <ts>] [--end-time <ts>]` | READ | Rebate summary |
| 15 | `dcli account affiliates --uid <uid> [--start-time <ts>] [--end-time <ts>]` | READ | Affiliate list |
| 16 | `dcli account trade-stats-daily --uid <uid> --appid <id> [--instrument-ids <ids>] [--start-time <ts>] [--end-time <ts>]` | READ | Daily trade statistics |
| 17 | `dcli account trade-stats-total --uid <uid> --appid <id> [--start-time <ts>] [--end-time <ts>]` | READ | Total trade statistics |

### Write Commands

Confirm with the user before every write command.

| # | Command | Type | Description |
|---|---|---|---|
| 18 | `dcli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross\|isolated> [--mrg-position <merge\|split>]` | WRITE | Set leverage |
| 19 | `dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]` | WRITE | Transfer assets between account scopes |
| 20 | `dcli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>` | WRITE | Transfer between sub-accounts |
| 21 | `dcli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]` | WRITE | Internal transfer to another Deepcoin user/account |

## Cross-Skill Workflows

### Pre-trade balance check

> User: "I want to buy BTC. Do I have enough USDT?"

```text
1. deepcoin-portfolio  dcli account all-balances --account-type spot --ccy USDT --json
2. deepcoin-market     dcli market ticker BTC-USDT --json
   -> user confirms trade details
3. deepcoin-trade      dcli trade place-order ...
```

### Review open positions and PnL

> User: "Show my current positions and PnL."

```text
1. deepcoin-portfolio  dcli account positions --inst-type SWAP --json
2. deepcoin-market     dcli market ticker <INST_ID> --json, only when current price context is needed
```

### Move funds before trading

> User: "Move USDT so I can trade."

```text
1. deepcoin-portfolio  dcli account all-balances --ccy USDT --json
   -> user confirms source, destination, amount, and account codes
3. deepcoin-portfolio  dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id>
4. deepcoin-portfolio  dcli account all-balances --ccy USDT --json
```

### Deposit / withdrawal history review

> User: "Show my recent USDT deposits and withdrawals."

```text
1. deepcoin-portfolio  dcli account deposit-list --coin USDT --page 1 --size 20 --json
2. deepcoin-portfolio  dcli account withdraw-list --coin USDT --page 1 --size 20 --json
```

Creation, cancellation, whitelist, supported withdrawal chain config, and status checks belong to `deepcoin-withdrawal`.

### Affiliate or trade-stat report

> User: "Show affiliate rebates or API trade stats."

```text
1. deepcoin-portfolio  dcli account uid
2. deepcoin-portfolio  dcli account rebate-summary --uid <uid> --type 0
3. deepcoin-portfolio  dcli account trade-stats-total --uid <uid> --appid <id>
```

Ask for `appid` only when the selected trade-stat command requires it and it is not available from context.

## Operation Flow

### Step 0: Credential Check

Before any authenticated command, run the [Credential Check](#credential-check). After each result, state that it used the configured Deepcoin environment.

### Step 1: Identify account action

- Total holdings / "我的余额" / "all balances" -> `dcli account all-balances --json`.
- Specific currency balance with no account scope -> `dcli account all-balances --ccy <ccy> --json`.
- Specific account type balance -> use `all-balances --account-type <type>` for account types such as `funding`, `spot`, `swapU`, `swap`, `bonus`, `rebate`, `event`, `copyTrade`, `robot`, or `all`.
- Trading product balance for legacy spot/swap scope -> use `dcli account balance --inst-type <SPOT|SWAP>`.
- Open positions -> `dcli account positions --inst-type SWAP`.
- Position details for one instrument -> add `--inst-id <id>`.
- Account activity / ledger -> `dcli account bills --inst-type <SPOT|SWAP>`.
- Deposits -> `dcli account deposit-list`.
- Withdrawal history only -> `dcli account withdraw-list`.
- Sub-accounts -> `dcli account sub-accounts` or `dcli account sub-account-balance`.
- Transfer records -> `sub-account-transfer-records` or `internal-transfer-history`.
- Rebate / affiliate / trade stats -> use the matching read command and request required `uid` or `appid` if missing.
- Leverage or transfers -> write flow.

### Step 2: Run read commands immediately

Read commands do not need user confirmation after credentials are configured.

Rules:

- Prefer `--json` when you need to parse, compare, or combine results.
- For "my balance" with no account scope, run:
  ```bash
  dcli account all-balances --json
  ```
- For "my positions" with no instrument, run:
  ```bash
  dcli account positions --inst-type SWAP --json
  ```
- For bills, `--inst-type` is required. Ask or infer from the user's wording; if unclear, ask briefly rather than guessing for financial history.

### Step 3: Confirm before writes

Before `set-leverage`, `transfer`, `sub-account-transfer`, or `internal-transfer`, show the exact command to be run and wait for explicit confirmation.

Confirm:

- operation
- source and destination account scope, UID, or account type
- currency / currency ID and amount
- instrument, leverage, margin mode, and position mode where applicable
- verification command to run after execution

Do not treat vague approval as confirmation for account-changing operations.

### Step 4: Verify after writes

- After `set-leverage`: run `dcli account positions --inst-type SWAP --inst-id <id> --json`.
- After `transfer`: run `dcli account all-balances --ccy <ccy> --json`, adding `--account-type <type>` when the affected scope is known.
- After `sub-account-transfer`: run `dcli account sub-account-transfer-records --coin <ccy> --page 1 --size 20 --json`.
- After `internal-transfer`: run `dcli account internal-transfer-history --coin <ccy> --page 1 --size 20 --json`.

## CLI Command Reference

### Unified Balance

```bash
dcli account all-balances [--account-type <types>] [--ccy <ccys>] [--json]
```

| Param | Required | Default | Description |
|---|---|---|---|
| `--account-type` | No | - | Comma-separated account types: `funding`, `spot`, `swapU`, `swap`, `bonus`, `rebate`, `event`, `copyTrade`, `robot`, `all`. |
| `--ccy` | No | - | Currency filter; comma-separated values are supported, such as `USDT,BTC`. |
| `--json` | No | false | Raw machine-readable output. |

Returns a unified response with update time, summary fields such as total USD equity and available balance by currency, plus per-account currency details.

### Trading Product Balance

```bash
dcli account balance [--inst-type <SPOT|SWAP>] [--ccy <ccy>] [--json]
```

| Param | Required | Default | Description |
|---|---|---|---|
| `--inst-type` | No | - | Trading product scope: `SPOT` or `SWAP`. Use `all-balances` for a full account view. |
| `--ccy` | No | - | Currency filter such as `USDT`, `BTC`, `ETH`. |
| `--json` | No | false | Raw machine-readable output. |

Returns key balance fields such as currency, balance/equity, available balance, frozen balance, and unrealized profit when provided by Deepcoin.

### Positions

```bash
dcli account positions [--inst-type <SPOT|SWAP>] [--inst-id <id>] [--json]
```

| Param | Required | Default | Description |
|---|---|---|---|
| `--inst-type` | No | - | Use `SWAP` for contract positions. |
| `--inst-id` | No | - | Instrument filter, for example `BTC-USDT-SWAP`. |
| `--json` | No | false | Raw machine-readable output. |

Returns position fields such as instrument, side, size, average price, leverage, liquidation price, margin mode, unrealized PnL, and update time when present.

### Bills

```bash
dcli account bills --inst-type <SPOT|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]
```

| Param | Required | Default | Description |
|---|---|---|---|
| `--inst-type` | Yes | - | `SPOT` or `SWAP`. |
| `--ccy` | No | - | Currency filter. |
| `--type` | No | - | Bill type accepted by `dcli`; CLI help describes known values. |
| `--limit` | No | `20` | Max results, up to CLI-supported limit. |
| `--json` | No | false | Raw machine-readable output. |

### Transfers

```bash
dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]
dcli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>
dcli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]
```

Account codes are exchange-specific numeric IDs exposed by `dcli` help and Deepcoin account configuration. Do not guess them for write commands; ask the user or verify from local context before execution.

### Leverage

```bash
dcli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross|isolated> [--mrg-position <merge|split>]
```

Changing leverage affects risk. Check current positions first when the user has open exposure.

### Affiliate and Trade Statistics

```bash
dcli account rebate-summary --uid <uid> [--type <0|1|2>] [--start-time <ts>] [--end-time <ts>]
dcli account affiliates --uid <uid> [--start-time <ts>] [--end-time <ts>]
dcli account trade-stats-daily --uid <uid> --appid <id> [--instrument-ids <ids>] [--start-time <ts>] [--end-time <ts>]
dcli account trade-stats-total --uid <uid> --appid <id> [--start-time <ts>] [--end-time <ts>]
```

Use `dcli account uid` to get the current UID if the user asks for their own account and no UID is provided.

## Input / Output Examples

**"我的余额" / "How much do I have?"**

```bash
dcli account all-balances --json
# -> summarize totalEqUsd, totalAvailBalByCcy, and non-zero balances by account type
```

**"我的持仓呢" / "Show my positions."**

```bash
dcli account positions --inst-type SWAP --json
# -> summarize instrument, side, size, entry/avg price, leverage, liquidation price, and unrealized PnL
```

**"Show recent account activity."**

```bash
dcli account bills --inst-type SWAP --limit 20 --json
# -> summarize bill id/time/type/currency/balance change
```

**"Transfer 100 USDT between account scopes."**

```bash
dcli account all-balances --ccy USDT --json
# -> user confirms exact source, destination, amount, and account codes
dcli account transfer --currency-id <id> --amount 100 --from-id <from> --to-id <to>
```

## Where Can the Money Live?

Deepcoin account data is split by product/account scope.

| Scope | Used for | Check with |
|---|---|---|
| `funding` | Funding account assets | `dcli account all-balances --account-type funding` |
| `spot` | Spot account assets | `dcli account all-balances --account-type spot`; legacy trading view: `dcli account balance --inst-type SPOT` |
| `swapU` | USDT swap account | `dcli account all-balances --account-type swapU` |
| `swap` | Coin-margined swap account | `dcli account all-balances --account-type swap` |
| `bonus`, `rebate`, `event`, `copyTrade`, `robot` | Bonus, rebate, event contract, copy trading, and robot accounts | `dcli account all-balances --account-type <type>` |
| Sub-accounts | Separate UID/account structures | `dcli account sub-accounts`; `dcli account sub-account-balance` |
| Internal transfer recipients | Deepcoin internal receiver accounts | `dcli account internal-transfer-support`; transfer history commands |

Typical flow when the user says "I have USDT but cannot trade":

1. Query `dcli account all-balances --ccy USDT --json`.
2. If funds are in the wrong scope, prepare `dcli account transfer`.
3. Confirm the exact transfer with the user.
4. Re-query the target scope after transfer.

## Edge Cases

- Use `all-balances` for "all balances", "total holdings", or "我的余额"; use `balance --inst-type` only when the user specifically asks for the trading product balance.
- Empty positions usually means no open contract positions; spot holdings are shown through balance commands.
- `bills` requires `--inst-type`. Ask whether the user wants spot or swap history if not clear.
- `withdraw-list` is history only. For withdrawal creation, cancellation, whitelist, chain config, or status, switch to `deepcoin-withdrawal`.
- Account transfer commands use numeric account or currency IDs. Do not guess IDs for writes.
- Do not replay transfer or leverage commands automatically after an uncertain error. Verify state first.
- Rebate and trade-stat commands may require UID or App ID. Ask for missing required fields.

## Global Notes

- All commands in this skill require Deepcoin credentials.
- Use `--json` for aggregation, comparison, or downstream tool processing.
- Use concise result summaries by default; include raw JSON only when requested or needed for follow-up.
- For financial or account-changing operations, be explicit about what was run and what environment was configured.
- If a requested capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
