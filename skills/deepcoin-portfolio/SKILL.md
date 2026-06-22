---
name: deepcoin-portfolio
description: "Use this skill when the user asks for: Deepcoin account balance, equity, available margin, frozen balance, unrealized PnL, open positions, position details (leverage, liquidation price, margin), account bills / transaction history, UID, leverage settings, sub-account management, sub-account transfers, internal transfers between users, asset deposits, or asset transfers through dcli. Do NOT use for on-chain withdrawal create / cancel / status / whitelist / chain config (use deepcoin-withdrawal), public market data (use deepcoin-market), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
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

Account balance, positions, bills, leverage, sub-accounts, deposits, transfers, and internal transfers on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/portfolio-commands.md`](references/portfolio-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Credential Check

Authenticated commands require Deepcoin credentials in environment variables. Prefer:

```bash
export DEEPCOIN_API_KEY=...
export DEEPCOIN_SECRET_KEY=...
export DEEPCOIN_PASSPHRASE=...
```

Compatibility aliases are also supported: `DC_API_KEY`, `DC_SECRET_KEY`, `DC_PASSPHRASE`.

Never ask the user to paste credentials into chat. If authentication is missing, ask the user to configure environment variables locally.

## Skill Routing

- Market data, tickers, candles, funding, instrument metadata -> `deepcoin-market`
- Order placement, cancellation, amendments, TP/SL, fills -> `deepcoin-trade`
- On-chain withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions -> `deepcoin-copytrade`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Balance, positions, bills, leverage, transfers, sub-accounts -> this skill

## Quickstart

```bash
# Current account UID
dcli account uid

# Spot and swap balances
dcli account balance --inst-type SPOT --json
dcli account balance --inst-type SWAP --json

# Open swap positions
dcli account positions --inst-type SWAP --json

# Recent account bills
dcli account bills --inst-type SWAP --limit 20 --json

# Sub-account list
dcli account sub-accounts --json
```

## Command Index

### Read Commands

| # | Command | Description |
|---|---|---|
| 1 | `dcli account uid` | Current account UID |
| 2 | `dcli account balance [--inst-type <SPOT\|SWAP>] [--ccy <ccy>] [--json]` | Account balance |
| 3 | `dcli account positions [--inst-type <SPOT\|SWAP>] [--inst-id <id>] [--json]` | Open positions |
| 4 | `dcli account bills --inst-type <SPOT\|SWAP> [--ccy <ccy>] [--type <type>] [--limit <n>] [--json]` | Account bill history |
| 5 | `dcli account sub-accounts [--json]` | Sub-account list |
| 6 | `dcli account sub-account-balance` | Total sub-account balance |
| 7 | `dcli account sub-account-transfer-records [--coin <ccy>] [--page <n>] [--size <n>] [--json]` | Sub-account transfer records |
| 8 | `dcli account deposit-list [--coin <ccy>] [--page <n>] [--size <n>] [--json]` | Deposit history |
| 9 | `dcli account recharge-chains --currency-id <id> [--json]` | Deposit chains |
| 10 | `dcli account internal-transfer-support` | Coins supported for internal transfer |
| 11 | `dcli account internal-transfer-history [--coin <ccy>] [--status <status>] [--page <n>] [--size <n>] [--json]` | Internal transfer history |

### Write Commands

Confirm with the user before running any write command.

| # | Command | Description |
|---|---|---|
| 12 | `dcli account set-leverage --inst-id <id> --lever <n> --mgn-mode <cross\|isolated> [--mrg-position <merge\|split>]` | Set leverage |
| 13 | `dcli account sub-account-transfer --from-uid <uid> --to-uid <uid> --from-id <id> --to-id <id> --amount <amount> --coin <ccy>` | Transfer between sub-accounts |
| 14 | `dcli account transfer --currency-id <id> --amount <amount> --from-id <id> --to-id <id> [--uid <uid>]` | Transfer assets between accounts |
| 15 | `dcli account internal-transfer --amount <amount> --coin <ccy> --receiver-account <account> --account-type <type> [--receiver-uid <uid>]` | Internal transfer |

## Operation Flow

1. Identify the portfolio action: balance, position, bills, leverage, transfer, sub-account, deposit, or internal transfer.
2. Select the matching command from [`references/portfolio-commands.md`](references/portfolio-commands.md).
3. For read commands, run the command directly after credential preflight.
4. For write commands, summarize the action and wait for explicit user confirmation.
5. After a write, verify with the closest read command.
6. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## Write Confirmation Rules

Before `set-leverage`, transfers, or internal transfers, summarize:

- operation
- source and destination account scope, when applicable
- currency and amount, when applicable
- instrument, leverage, and margin mode, when applicable
- verification command to run after execution

Do not treat vague approval as confirmation for account-changing operations.

## Response Rules

- Report the command result first.
- Keep balances and positions concise, with key fields only unless the user asks for raw JSON.
- Use `--json` when another tool or follow-up command will consume the output.
- Use only documented `dcli` commands; do not provide low-level protocol or signing instructions.
