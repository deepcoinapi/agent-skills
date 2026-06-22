---
name: deepcoin-copytrade
description: "Use this skill when the user asks about Deepcoin copy trading through dcli: becoming or managing a leader, leader settings, copy trade codes, supported copy trading contracts, setting leader contracts, follower lists, leader positions, copy trading position mode, estimated profit, or historical profit. Do NOT use for regular manual orders (use deepcoin-trade), account balances or transfers (use deepcoin-portfolio), market data (use deepcoin-market), withdrawals (use deepcoin-withdrawal), or DSL strategy orders (use deepcoin-strategy)."
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

Before running any command, follow [`references/dcli.md`](references/dcli.md).

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/copytrade-commands.md`](references/copytrade-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

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

Security rule: never ask the user to paste credentials into chat.

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

## Deepcoin Mode

`dcli` currently uses the configured Deepcoin environment. There is no skill-level demo/live switch.

Rules:

- State that commands run against the user's configured Deepcoin environment.
- Copy trading setting changes require explicit confirmation.
- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.

## Skill Routing

- Market data -> `deepcoin-market`
- Balances, positions, deposits, transfers -> `deepcoin-portfolio`
- Regular orders, triggers, TP/SL, fills, closes -> `deepcoin-trade`
- On-chain withdrawals -> `deepcoin-withdrawal`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Copy trading leader settings, followers, contracts, leader positions, position mode, profit -> this skill

## Quickstart

```bash
# Supported copy trading contracts
dcli copytrade support-contracts --json

# Follower list
dcli copytrade followers --status 1 --json

# Leader positions
dcli copytrade leader-positions --page 1 --size 20 --json

# Position type and profit
dcli copytrade position-type --json
dcli copytrade estimated-profit --json
dcli copytrade history-profit --json
```

## Command Index

### Read Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli copytrade support-contracts [--json]` | READ | Supported copy trading contracts |
| 2 | `dcli copytrade followers --status <1\|2> [--json]` | READ | Active or inactive followers |
| 3 | `dcli copytrade leader-positions [--page <n>] [--size <n>] [--json]` | READ | Leader positions |
| 4 | `dcli copytrade position-type [--json]` | READ | Current position mode |
| 5 | `dcli copytrade estimated-profit [--json]` | READ | Estimated copy trading profit |
| 6 | `dcli copytrade history-profit [--json]` | READ | Historical copy trading profit |

### Write Commands

Confirm with the user before every write command.

| # | Command | Type | Description |
|---|---|---|---|
| 7 | `dcli copytrade leader-settings --status <0\|1> [--home-mode <1\|3>] [--is-closed-copy-code <true\|false>] [--copy-code <code>]` | WRITE | Update leader settings |
| 8 | `dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'` | WRITE | Set leader copy trading contracts |
| 9 | `dcli copytrade set-position-type --type <1\|2>` | WRITE | Update copy trading position mode |

## Cross-Skill Workflows

### Configure leader contracts

> User: "Enable BTC and ETH for copy trading."

```text
1. deepcoin-copytrade  dcli copytrade support-contracts --json
   -> user confirms contract list
2. deepcoin-copytrade  dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
3. deepcoin-copytrade  dcli copytrade support-contracts --json
```

### Review leader performance

> User: "How is my copy trading doing?"

```text
1. deepcoin-copytrade  dcli copytrade leader-positions --page 1 --size 20 --json
2. deepcoin-copytrade  dcli copytrade estimated-profit --json
3. deepcoin-copytrade  dcli copytrade history-profit --json
```

### Inspect followers

> User: "Show my active followers."

```text
1. deepcoin-copytrade  dcli copytrade followers --status 1 --json
2. deepcoin-copytrade  dcli copytrade followers --status 2 --json, only if inactive/history is requested
```

## Operation Flow

### Step 0: Credential Check

Before any authenticated command, run the [Credential Check](#credential-check). After results, state that the configured Deepcoin environment was used.

### Step 1: Identify copy trading action

- Supported contracts -> `support-contracts`.
- Set contract list -> write flow with `set-contracts`.
- Followers -> `followers --status 1` for active, `--status 2` for inactive/history.
- Leader positions -> `leader-positions`.
- Position mode -> `position-type` or write flow with `set-position-type`.
- Estimated or historical profit -> `estimated-profit` / `history-profit`.
- Enable/disable leader or copy code settings -> write flow with `leader-settings`.

### Step 2: Run read commands immediately

Read commands do not need user confirmation after credentials are configured.

Rules:

- Prefer `--json` when summarizing positions, followers, or profit.
- Use bounded pagination for `leader-positions`.
- Keep copy trading results separate from regular trading account results.

### Step 3: Confirm before writes

Before `leader-settings`, `set-contracts`, or `set-position-type`, show the exact command and wait for explicit confirmation.

Confirm:

- operation
- affected status or setting
- contract list, if applicable
- position type, if applicable
- copy code visibility/change, if applicable
- verification command

### Step 4: Verify after writes

- After `leader-settings`: run the closest read command available and report the command result. If no read command exposes the changed field, say verification is limited by current `dcli`.
- After `set-contracts`: run `dcli copytrade support-contracts --json`.
- After `set-position-type`: run `dcli copytrade position-type --json`.

## CLI Command Reference

### Reads

```bash
dcli copytrade support-contracts [--json]
dcli copytrade followers --status <1|2> [--json]
dcli copytrade leader-positions [--page <n>] [--size <n>] [--json]
dcli copytrade position-type [--json]
dcli copytrade estimated-profit [--json]
dcli copytrade history-profit [--json]
```

### Writes

```bash
dcli copytrade leader-settings --status <0|1> [--home-mode <1|3>] [--is-closed-copy-code <true|false>] [--copy-code <code>]
dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
dcli copytrade set-position-type --type <1|2>
```

Contract symbols for `set-contracts` are compact symbols such as `BTCUSDT`, not `BTC-USDT-SWAP`.

## Input / Output Examples

**"Show supported copy contracts."**

```bash
dcli copytrade support-contracts --json
# -> summarize supported contract symbols
```

**"Show my active followers."**

```bash
dcli copytrade followers --status 1 --json
# -> summarize follower count and key follower stats
```

**"Set copy contracts to BTC and ETH."**

```bash
dcli copytrade support-contracts --json
# -> user confirms exact contract list
dcli copytrade set-contracts --contracts '<BTCUSDT,ETHUSDT>'
```

## Edge Cases

- `followers --status` is required: use `1` for active and `2` for inactive/history.
- `set-contracts` uses compact symbols such as `BTCUSDT`.
- `set-position-type --type 1` means Hedge; `--type 2` means One-way.
- Leader settings can affect followers. Confirm status and copy-code changes explicitly.
- Do not use regular `dcli trade` commands for copy trading settings.

## Global Notes

- All commands in this skill require Deepcoin credentials.
- Every write command requires explicit confirmation.
- Use `--json` for structured summaries and verification.
- If a requested copy trading capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
