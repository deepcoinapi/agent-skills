---
name: deepcoin-copytrade
description: "Use this skill when the user asks about: Deepcoin copy trading, becoming a leader or follower, leader settings, copy trading contracts, follower lists, leader positions, position mode for copy trading, estimated or historical copy trading profit, or managing copy trade codes. Do NOT use for regular order placement (use deepcoin-trade), account balance (use deepcoin-portfolio), or market data (use deepcoin-market)."
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

# Deepcoin Copy Trading CLI

Copy trading leader settings, supported contracts, follower lists, leader positions, position mode, estimated profit, and historical profit on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/copytrade-commands.md`](references/copytrade-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Credential Check

Authenticated commands require Deepcoin credentials in environment variables. Prefer `DEEPCOIN_API_KEY`, `DEEPCOIN_SECRET_KEY`, and `DEEPCOIN_PASSPHRASE`; `DC_*` aliases are supported.

Never ask the user to paste credentials into chat.

## Skill Routing

- Market data -> `deepcoin-market`
- Balances, positions, transfers -> `deepcoin-portfolio`
- Regular orders, triggers, TP/SL, fills -> `deepcoin-trade`
- On-chain withdrawals -> `deepcoin-withdrawal`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Copy trading settings, followers, positions, and profit -> this skill

## Quickstart

```bash
# Supported copy trading contracts
dcli copytrade support-contracts --json

# Follower list
dcli copytrade followers --status 1 --json

# Leader positions
dcli copytrade leader-positions --page 1 --size 20 --json

# Position type
dcli copytrade position-type --json
```

## Command Index

### Read Commands

| # | Command | Description |
|---|---|---|
| 1 | `dcli copytrade support-contracts [--json]` | Supported contracts |
| 2 | `dcli copytrade followers --status <1\|2> [--json]` | Current or historical followers |
| 3 | `dcli copytrade leader-positions [--page <n>] [--size <n>] [--json]` | Leader positions |
| 4 | `dcli copytrade position-type [--json]` | Current position mode |
| 5 | `dcli copytrade estimated-profit [--json]` | Estimated copy trading profit |
| 6 | `dcli copytrade history-profit [--json]` | Historical copy trading profit |

### Write Commands

Confirm with the user before running any write command.

| # | Command | Description |
|---|---|---|
| 7 | `dcli copytrade leader-settings --status <0\|1> [--home-mode <1\|3>] [--is-closed-copy-code <true\|false>] [--copy-code <code>]` | Update leader settings |
| 8 | `dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'` | Set copy trading contracts |
| 9 | `dcli copytrade set-position-type --type <1\|2>` | Update position mode |

## Operation Flow

1. Identify intent: leader settings, supported contracts, set contracts, followers, leader positions, position type, or profit.
2. Select the matching command from [`references/copytrade-commands.md`](references/copytrade-commands.md).
3. For read commands, run directly after credential preflight.
4. For write commands, summarize the exact change and wait for explicit user confirmation.
5. After a write, verify with the closest read command.
6. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## Write Confirmation Rules

Before leader settings, contract changes, or position-type changes, summarize:

- operation
- affected setting
- contract list, if applicable
- position mode, if applicable
- verification command to run afterward

Do not treat vague approval as confirmation for copy trading changes.

## Response Rules

- Use compact contract symbols such as `BTCUSDT` for `set-contracts`.
- Separate copy trading workflows from regular trading workflows.
- Use only documented `dcli` commands; do not provide low-level protocol or signing instructions.
