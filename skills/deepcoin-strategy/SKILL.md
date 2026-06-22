---
name: deepcoin-strategy
description: "Use this skill when the user asks about: Deepcoin DSL strategy orders, automated trading strategies with indicators (BOLL, MA, EMA, KDJ, RSI, WR), strategy backtesting, or DSL-based trigger orders. Do NOT use for regular manual orders (use deepcoin-trade), account queries (use deepcoin-portfolio), market data (use deepcoin-market), or copy trading (use deepcoin-copytrade)."
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

DSL strategy drafting, backtesting, and live DSL trigger-order preparation on Deepcoin. Requires Deepcoin credentials for `dcli` strategy commands.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/strategy-commands.md`](references/strategy-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts. Creating or editing a strategy DSL JSON file is allowed when the user asks for a strategy artifact.

## Credential Check

Authenticated commands require Deepcoin credentials in environment variables. Prefer `DEEPCOIN_API_KEY`, `DEEPCOIN_SECRET_KEY`, and `DEEPCOIN_PASSPHRASE`; `DC_*` aliases are supported.

Never ask the user to paste credentials into chat.

## Skill Routing

- Market data and indicators from exchange market data -> `deepcoin-market`
- Account balance and positions -> `deepcoin-portfolio`
- Manual orders, triggers, TP/SL, fills -> `deepcoin-trade`
- Copy trading -> `deepcoin-copytrade`
- Strategy DSL drafting, backtests, live DSL trigger orders -> this skill

## Quickstart

```bash
# Backtest a DSL JSON file
dcli strategy backtest --symbol BTC-USDT-SWAP --from-ts 2025-01-01T00:00:00Z --to-ts 2025-03-01T00:00:00Z --dsl @strategy.json --json

# Deploy a live DSL trigger order after explicit confirmation
dcli strategy dsl-trigger-order --symbol BTC-USDT-SWAP --trade-mode isolated --mrg-position merge --dsl @strategy.json
```

## Command Index

### Read / Validation Commands

| # | Command | Description |
|---|---|---|
| 1 | `dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json [--json]` | Run a backtest |

### Write Commands

Confirm with the user before running any live deployment command.

| # | Command | Description |
|---|---|---|
| 2 | `dcli strategy dsl-trigger-order --symbol <INST_ID> --trade-mode <cross\|isolated> --mrg-position <merge\|split> --dsl @strategy.json` | Place live DSL trigger order |

## Operation Flow

1. Identify intent: draft DSL, review DSL, backtest, compare results, or deploy live.
2. For pure drafting or explanation, create or edit only the DSL JSON artifact; do not run commands unless needed.
3. For validation, run `dcli strategy backtest`.
4. For live deployment, require a prior backtest or explicit user decision to proceed without one.
5. Before `dcli strategy dsl-trigger-order`, summarize the strategy, symbol, trade mode, position mode, and risks, then wait for explicit confirmation.
6. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## DSL Notes

Supported strategy concepts include:

- indicators: `BOLL`, `MA`, `EMA`, `KDJ`, `RSI`, `WR`
- entry and exit logic
- risk controls such as stop loss and take profit
- execution settings such as fees

Use `@strategy.json` for non-trivial DSL payloads instead of long inline JSON.

## Response Rules

- Separate strategy design from live deployment.
- Do not deploy live strategies without explicit confirmation.
- Use only documented `dcli` commands; do not provide low-level protocol or signing instructions.
