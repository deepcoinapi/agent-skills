---
name: deepcoin-strategy
description: "Use this skill when the user asks about Deepcoin DSL strategy drafting, reviewing, validating, backtesting, or deploying DSL-driven trigger orders through dcli; automated trading strategies using indicators such as BOLL, MA, EMA, KDJ, RSI, or WR; strategy condition operators; or backtest result interpretation. Do NOT use for regular manual orders (use deepcoin-trade), account queries (use deepcoin-portfolio), market data alone (use deepcoin-market), copy trading (use deepcoin-copytrade), or withdrawals (use deepcoin-withdrawal)."
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

# Deepcoin Strategy CLI

DSL strategy drafting, backtesting, and live DSL trigger-order preparation on Deepcoin. Requires Deepcoin credentials for `dcli strategy` commands.

## Preflight

Before running any command, follow [`references/dcli.md`](references/dcli.md).

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/strategy-commands.md`](references/strategy-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts. Creating or editing a strategy DSL JSON file is allowed when the user asks for a strategy artifact.

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
   dcli strategy backtest --help
   ```

Compatibility aliases are supported: `DC_API_KEY`, `DC_SECRET_KEY`, `DC_PASSPHRASE`.

Security rule: never ask the user to paste credentials into chat.

## Credential Check

Run this before any authenticated `dcli strategy` command:

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

- Backtests are validation reads; live DSL trigger orders are writes.
- Live deployment requires explicit confirmation immediately before execution.
- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.

## Skill Routing

- Market data and candles used as inputs -> `deepcoin-market`
- Account balance and positions -> `deepcoin-portfolio`
- Manual orders, triggers, TP/SL, fills, closes -> `deepcoin-trade`
- Copy trading -> `deepcoin-copytrade`
- Withdrawals -> `deepcoin-withdrawal`
- Strategy DSL drafting, validation, backtests, live DSL trigger orders -> this skill

## Quickstart

```bash
# Backtest a DSL JSON file
dcli strategy backtest --symbol BTC-USDT-SWAP --from-ts 2025-01-01T00:00:00Z --to-ts 2025-03-01T00:00:00Z --dsl @strategy.json --json

# Deploy a live DSL trigger order only after explicit confirmation
dcli strategy dsl-trigger-order --symbol BTC-USDT-SWAP --trade-mode isolated --mrg-position merge --dsl @strategy.json
```

## Command Index

### Read / Validation Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json [--json]` | READ | Run a strategy backtest |

### Write Commands

Confirm with the user before every live deployment command.

| # | Command | Type | Description |
|---|---|---|---|
| 2 | `dcli strategy dsl-trigger-order --symbol <INST_ID> --trade-mode <cross\|isolated> --mrg-position <merge\|split> --dsl @strategy.json` | WRITE | Place live DSL trigger order |

## Cross-Skill Workflows

### Draft and backtest

> User: "Create and backtest an RSI strategy for BTC."

```text
1. deepcoin-market    dcli market candles BTC-USDT-SWAP --bar 1H --limit 100 --json, if recent data context is requested
2. deepcoin-strategy  create or edit strategy.json
3. deepcoin-strategy  dcli strategy backtest --symbol BTC-USDT-SWAP --from-ts <ts> --to-ts <ts> --dsl @strategy.json --json
```

### Deploy after validation

> User: "Deploy this strategy live."

```text
1. deepcoin-strategy  dcli strategy backtest ... --dsl @strategy.json --json, unless the user explicitly accepts skipping it
2. deepcoin-portfolio dcli account balance --inst-type SWAP --ccy USDT --json, if margin/funds context is needed
   -> user confirms strategy, symbol, trade mode, position mode, and exact command
3. deepcoin-strategy  dcli strategy dsl-trigger-order --symbol <id> --trade-mode <cross|isolated> --mrg-position <merge|split> --dsl @strategy.json
```

### Strategy vs manual trigger

Use `deepcoin-trade` when the user wants a single manual trigger order without DSL logic. Use this skill when the order behavior is defined by a DSL strategy.

## Operation Flow

### Step 0: Credential Check

Before any `dcli strategy` command, run the [Credential Check](#credential-check). Drafting or editing a local DSL file does not require credentials until a command is run.

### Step 1: Identify strategy action

- Draft DSL -> create or edit `strategy.json`; no command required unless validation is requested.
- Review DSL -> inspect JSON structure and explain behavior.
- Backtest -> `dcli strategy backtest`.
- Compare strategy variants -> use separate DSL files and backtest each.
- Deploy live DSL trigger order -> write flow with `dsl-trigger-order`.

### Step 2: DSL artifact rules

- Prefer `@strategy.json` for non-trivial payloads instead of long inline JSON.
- Keep DSL files in the user's workspace when asked to create artifacts.
- Ensure JSON is valid before running `dcli strategy`.
- Do not create helper scripts that bypass `dcli` for strategy execution; editing the DSL JSON artifact is allowed.

### Step 3: Run validation reads

Backtests do not need write confirmation, but they do require credentials.

```bash
dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json --json
```

Use ISO 8601 timestamps. Ask for missing symbol or time range if not inferable.

### Step 4: Confirm before live deployment

Before `dsl-trigger-order`, show the exact command and wait for explicit confirmation.

Confirm:

- strategy file path
- symbol
- trade mode
- position mode
- whether a backtest was run and the key result
- that this is a live configured-environment action
- verification or follow-up command

Do not treat general approval of a strategy idea as approval to deploy.

## DSL Notes

Supported concepts from `dcli strategy backtest --help`:

- indicators: `BOLL`, `MA`, `EMA`, `KDJ`, `RSI`, `WR`
- condition operators: `>=`, `<=`, `>`, `<`, `==`, `cross_above`, `cross_below`
- entry and exit logic
- risk controls such as stop loss and take profit, when supported by the DSL
- execution settings such as fees, when supported by the DSL

## CLI Command Reference

### Backtest

```bash
dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json [--json]
```

`--dsl` accepts inline JSON or `@filepath`; prefer `@filepath`.

### Live DSL Trigger Order

```bash
dcli strategy dsl-trigger-order --symbol <INST_ID> --trade-mode <cross|isolated> --mrg-position <merge|split> --dsl @strategy.json
```

This is a write command. Confirm immediately before execution.

## Input / Output Examples

**"Backtest this strategy file."**

```bash
dcli strategy backtest --symbol BTC-USDT-SWAP --from-ts 2025-01-01T00:00:00Z --to-ts 2025-03-01T00:00:00Z --dsl @strategy.json --json
# -> summarize return, drawdown, trade count, win rate, and errors when present
```

**"Deploy the DSL trigger order."**

```bash
dcli strategy backtest --symbol BTC-USDT-SWAP --from-ts <ts> --to-ts <ts> --dsl @strategy.json --json
# -> user confirms exact deployment command
dcli strategy dsl-trigger-order --symbol BTC-USDT-SWAP --trade-mode isolated --mrg-position merge --dsl @strategy.json
```

## Edge Cases

- Missing or invalid JSON should be fixed before running `dcli strategy`.
- Missing symbol or time range blocks backtesting; ask for the missing input.
- A profitable backtest is not approval to deploy live.
- Live deployment without a backtest is allowed only after the user explicitly chooses to skip validation.
- If the user wants a manual trigger order, use `deepcoin-trade`, not this skill.

## Global Notes

- `dcli strategy` commands require Deepcoin credentials.
- Drafting or editing local DSL JSON does not require credentials.
- Use `@strategy.json` for non-trivial DSL payloads.
- If a requested strategy capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
