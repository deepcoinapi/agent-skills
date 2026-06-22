---
name: deepcoin-trade
description: "Use this skill when the user wants to: place, cancel, amend, or query orders on Deepcoin (spot, swap, margin); use trigger / conditional orders; set or modify take-profit / stop-loss on positions or orders; close positions (single or batch); query pending orders, order history, or trade fills; place trace orders. Do NOT use for read-only account queries (use deepcoin-portfolio), public market data (use deepcoin-market), copy trading (use deepcoin-copytrade), or DSL strategy orders (use deepcoin-strategy)."
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

# Deepcoin Trade CLI

Order placement, cancellation, amendment, order queries, trigger orders, TP/SL, close-position workflows, fills, and trace orders on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`../_shared/dcli.md`](../_shared/dcli.md).

Use only the stable CLI commands in [`references/trade-commands.md`](references/trade-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

## Credential Check

Authenticated commands require Deepcoin credentials in environment variables. Prefer `DEEPCOIN_API_KEY`, `DEEPCOIN_SECRET_KEY`, and `DEEPCOIN_PASSPHRASE`; `DC_*` aliases are supported.

Never ask the user to paste credentials into chat.

## Skill Routing

- Market prices, candles, order books, funding, instruments -> `deepcoin-market`
- Balances, positions, leverage, transfers, sub-accounts -> `deepcoin-portfolio`
- On-chain withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions -> `deepcoin-copytrade`
- Strategy DSL and backtests -> `deepcoin-strategy`
- Orders, triggers, TP/SL, closes, fills -> this skill

## Quickstart

```bash
# Pending orders
dcli trade pending-orders --inst-id BTC-USDT-SWAP --json

# Order history
dcli trade order-history --inst-type SWAP --limit 20 --json

# Fills
dcli trade fills --inst-type SWAP --inst-id BTC-USDT-SWAP --json

# Place a limit order after explicit confirmation
dcli trade place-order --inst-id BTC-USDT-SWAP --td-mode isolated --side buy --ord-type limit --sz 1 --px 60000 --pos-side long --mrg-position merge --json
```

## Command Index

### Read Commands

| # | Command | Description |
|---|---|---|
| 1 | `dcli trade get-order --inst-id <id> --ord-id <id>` | Active or recent order |
| 2 | `dcli trade get-history-order --inst-id <id> --ord-id <id>` | Historical order |
| 3 | `dcli trade pending-orders [--inst-id <id>] [--limit <n>] [--json]` | Open orders |
| 4 | `dcli trade order-history --inst-type <SPOT\|SWAP> [--inst-id <id>] [--state <canceled\|filled>] [--ord-type <type>] [--limit <n>] [--json]` | Order history |
| 5 | `dcli trade batch-query --orders '<json-array>'` | Query several orders |
| 6 | `dcli trade fills --inst-type <SPOT\|SWAP> [--inst-id <id>] [--ord-id <id>] [--limit <n>] [--json]` | Trade fills |
| 7 | `dcli trade trigger-pending --inst-type <SPOT\|SWAP> [--inst-id <id>] [--limit <n>] [--json]` | Pending trigger orders |
| 8 | `dcli trade trigger-history --inst-type <SPOT\|SWAP> [--inst-id <id>] [--limit <n>] [--json]` | Trigger order history |
| 9 | `dcli trade trace-orders [--json]` | Pending trace orders |

### Write Commands

Confirm with the user before running any write command.

| # | Command | Description |
|---|---|---|
| 10 | `dcli trade place-order --inst-id <id> --td-mode <mode> --side <buy\|sell> --ord-type <type> --sz <size> [flags] [--json]` | Place order |
| 11 | `dcli trade batch-orders --orders '<json-array>'` | Place up to 5 orders |
| 12 | `dcli trade cancel-order --inst-id <id> --ord-id <id> [--json]` | Cancel order |
| 13 | `dcli trade batch-cancel --order-ids '<id,id>'` | Cancel several orders |
| 14 | `dcli trade cancel-all --product-group <Swap\|SwapU> [--inst-id <id>] [--cross-margin <0\|1>] [--merge-mode <0\|1>]` | Cancel all matching orders |
| 15 | `dcli trade amend-order --order-id <id> [--price <px>] [--volume <size>]` | Amend order |
| 16 | `dcli trade amend-order-sltp --order-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]` | Amend order TP/SL |
| 17 | `dcli trade trigger-order --inst-id <id> --product-group <Swap\|SwapU> --side <buy\|sell> --sz <size> --trigger-price <px> [flags]` | Place trigger order |
| 18 | `dcli trade cancel-trigger --inst-id <id> --ord-id <id>` | Cancel trigger order |
| 19 | `dcli trade cancel-all-triggers --product-group <Swap\|SwapU> [flags]` | Cancel all matching trigger orders |
| 20 | `dcli trade set-position-sltp --inst-type <SPOT\|SWAP> --inst-id <id> --pos-side <long\|short> [flags]` | Set position TP/SL |
| 21 | `dcli trade modify-position-sltp --ord-id <id> --inst-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]` | Modify position TP/SL |
| 22 | `dcli trade cancel-position-sltp --ord-id <id>` | Cancel position TP/SL |
| 23 | `dcli trade close-position --inst-id <id> --product-group <Swap\|SwapU> --position-ids '<id,id>'` | Close positions by ID |
| 24 | `dcli trade batch-close-position --inst-id <id> --product-group <Swap\|SwapU>` | Close all positions for an instrument |
| 25 | `dcli trade trace-order --inst-id <id> --retrace-point <value> --trigger-price <px> --pos-side <long\|short>` | Place trace order |

## Operation Flow

1. Identify intent: query, place, cancel, amend, trigger, TP/SL, close, fills, or trace.
2. Select the matching command from [`references/trade-commands.md`](references/trade-commands.md).
3. For read commands, run directly after credential preflight.
4. For write commands, summarize the exact action and wait for explicit user confirmation.
5. After a write, verify with the closest read command.
6. If the requested capability is not available in `dcli`, report the missing CLI command instead of improvising an API call.

## Write Confirmation Rules

Before any write command, summarize:

- operation
- instrument
- side and size, when applicable
- order type and price, when applicable
- margin mode, position side, and position mode, when applicable
- affected order or position IDs, when applicable
- verification command to run afterward

Do not treat vague approval as confirmation for live trading operations.

## Response Rules

- Return the command result first.
- Keep risk notes concrete and proportional.
- Use `--json` for machine-readable follow-up work.
- Use only documented `dcli` commands; do not provide low-level protocol or signing instructions.
