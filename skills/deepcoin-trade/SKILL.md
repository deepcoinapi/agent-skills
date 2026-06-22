---
name: deepcoin-trade
description: "Use this skill when the user wants to place, cancel, amend, query, or manage Deepcoin spot/swap orders through dcli; use trigger / conditional orders; set, modify, or cancel take-profit / stop-loss on positions or orders; close positions; query pending orders, historical orders, trade fills, trigger history, or trace orders. Do NOT use for read-only balances / positions (use deepcoin-portfolio), public market data (use deepcoin-market), withdrawals (use deepcoin-withdrawal), copy trading (use deepcoin-copytrade), or DSL strategy orders (use deepcoin-strategy)."
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

Order placement, cancellation, amendments, order queries, trigger orders, TP/SL, close-position workflows, fills, and trace orders on Deepcoin. Requires Deepcoin credentials.

## Preflight

Before running any command, follow [`references/dcli.md`](references/dcli.md).

Use `metadata.version` from this file's frontmatter as the expected skill version. Use only stable CLI commands from [`references/trade-commands.md`](references/trade-commands.md). Do not bypass `dcli` with temporary Python, JavaScript, shell, signing, or request scripts.

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

Do not retry credential failures in a loop. Fix configuration first, then retry the original command once.

## Deepcoin Mode

`dcli` currently uses the configured Deepcoin environment. There is no skill-level demo/live switch.

Rules:

- State that commands run against the user's configured Deepcoin environment.
- Every write command requires explicit user confirmation immediately before execution.
- Do not invent `--demo`, `--profile`, or mode flags unless `dcli --help` shows them.

## Skill Routing

- Market prices, candles, order books, funding, instruments -> `deepcoin-market`
- Balances, positions, leverage, transfers, sub-accounts -> `deepcoin-portfolio`
- Withdrawal config, whitelist, create/cancel/status -> `deepcoin-withdrawal`
- Copy trading settings, followers, leader positions -> `deepcoin-copytrade`
- DSL strategy drafting, backtests, live DSL trigger orders -> `deepcoin-strategy`
- Manual orders, trigger orders, TP/SL, order queries, fills, closes, trace orders -> this skill

## Quickstart

```bash
# Pending orders
dcli trade pending-orders --inst-id BTC-USDT-SWAP --json

# Order history and fills
dcli trade order-history --inst-type SWAP --inst-id BTC-USDT-SWAP --limit 20 --json
dcli trade fills --inst-type SWAP --inst-id BTC-USDT-SWAP --limit 20 --json

# Place a limit order only after explicit confirmation
dcli trade place-order --inst-id BTC-USDT-SWAP --td-mode isolated --side buy --ord-type limit --sz 1 --px 60000 --pos-side long --mrg-position merge --json

# Cancel an order only after explicit confirmation
dcli trade cancel-order --inst-id BTC-USDT-SWAP --ord-id <id> --json
```

## Command Index

### Read Commands

| # | Command | Type | Description |
|---|---|---|---|
| 1 | `dcli trade get-order --inst-id <id> --ord-id <id>` | READ | Active or recent order |
| 2 | `dcli trade get-history-order --inst-id <id> --ord-id <id>` | READ | Historical order |
| 3 | `dcli trade pending-orders [--inst-id <id>] [--limit <n>] [--json]` | READ | Open orders |
| 4 | `dcli trade order-history --inst-type <SPOT\|SWAP> [--inst-id <id>] [--state <canceled\|filled>] [--ord-type <type>] [--limit <n>] [--json]` | READ | Order history |
| 5 | `dcli trade batch-query --orders '<json-array>'` | READ | Query up to 5 orders |
| 6 | `dcli trade fills --inst-type <SPOT\|SWAP> [--inst-id <id>] [--ord-id <id>] [--limit <n>] [--json]` | READ | Trade fills |
| 7 | `dcli trade trigger-pending --inst-type <SPOT\|SWAP> [--inst-id <id>] [--limit <n>] [--json]` | READ | Pending trigger orders |
| 8 | `dcli trade trigger-history --inst-type <SPOT\|SWAP> [--inst-id <id>] [--limit <n>] [--json]` | READ | Trigger order history |
| 9 | `dcli trade trace-orders [--json]` | READ | Pending trace orders |

### Write Commands

Confirm with the user before every write command.

| # | Command | Type | Description |
|---|---|---|---|
| 10 | `dcli trade place-order --inst-id <id> --td-mode <mode> --side <buy\|sell> --ord-type <type> --sz <size> [flags] [--json]` | WRITE | Place order |
| 11 | `dcli trade batch-orders --orders '<json-array>'` | WRITE | Place up to 5 orders |
| 12 | `dcli trade cancel-order --inst-id <id> --ord-id <id> [--json]` | WRITE | Cancel order |
| 13 | `dcli trade batch-cancel --order-ids '<id,id>'` | WRITE | Cancel up to 50 orders |
| 14 | `dcli trade cancel-all --product-group <Swap\|SwapU> [--inst-id <id>] [--cross-margin <0\|1>] [--merge-mode <0\|1>]` | WRITE | Cancel all matching orders |
| 15 | `dcli trade amend-order --order-id <id> [--price <px>] [--volume <size>]` | WRITE | Amend order |
| 16 | `dcli trade amend-order-sltp --order-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]` | WRITE | Amend order TP/SL |
| 17 | `dcli trade trigger-order --inst-id <id> --product-group <Swap\|SwapU> --side <buy\|sell> --sz <size> --trigger-price <px> [flags]` | WRITE | Place trigger order |
| 18 | `dcli trade cancel-trigger --inst-id <id> --ord-id <id>` | WRITE | Cancel trigger order |
| 19 | `dcli trade cancel-all-triggers --product-group <Swap\|SwapU> [flags]` | WRITE | Cancel all matching trigger orders |
| 20 | `dcli trade set-position-sltp --inst-type <SPOT\|SWAP> --inst-id <id> --pos-side <long\|short> [flags]` | WRITE | Set position TP/SL |
| 21 | `dcli trade modify-position-sltp --ord-id <id> --inst-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]` | WRITE | Modify position TP/SL |
| 22 | `dcli trade cancel-position-sltp --ord-id <id>` | WRITE | Cancel position TP/SL |
| 23 | `dcli trade close-position --inst-id <id> --product-group <Swap\|SwapU> --position-ids '<id,id>'` | WRITE | Close positions by ID |
| 24 | `dcli trade batch-close-position --inst-id <id> --product-group <Swap\|SwapU>` | WRITE | Close all positions for an instrument |
| 25 | `dcli trade trace-order --inst-id <id> --retrace-point <value> --trigger-price <px> --pos-side <long\|short>` | WRITE | Place trace order |

## Cross-Skill Workflows

### Pre-order check

> User: "Buy 0.1 BTC if I have enough USDT."

```text
1. deepcoin-market     dcli market ticker BTC-USDT --json or BTC-USDT-SWAP for swaps
2. deepcoin-portfolio  dcli account balance --inst-type <SPOT|SWAP> --ccy USDT --json
   -> user confirms exact order
3. deepcoin-trade      dcli trade place-order ...
4. deepcoin-trade      dcli trade get-order or pending-orders to verify
```

### Cancel stale orders

> User: "Cancel my open BTC swap orders."

```text
1. deepcoin-trade      dcli trade pending-orders --inst-id BTC-USDT-SWAP --json
   -> user confirms the order IDs or cancel-all scope
2. deepcoin-trade      dcli trade batch-cancel --order-ids '<id,id>' or cancel-all ...
3. deepcoin-trade      dcli trade pending-orders --inst-id BTC-USDT-SWAP --json
```

### Close or protect a position

> User: "Close my BTC long" or "Set stop loss."

```text
1. deepcoin-portfolio  dcli account positions --inst-type SWAP --inst-id BTC-USDT-SWAP --json
2. deepcoin-market     dcli market ticker BTC-USDT-SWAP --json, if price context is needed
   -> user confirms exact position IDs, side, size, and trigger/close action
3. deepcoin-trade      dcli trade close-position ... or set-position-sltp ...
4. deepcoin-portfolio  dcli account positions --inst-type SWAP --inst-id BTC-USDT-SWAP --json
```

## Operation Flow

### Step 0: Credential Check

Before any authenticated command, run the [Credential Check](#credential-check). After results, state that the configured Deepcoin environment was used.

### Step 1: Identify trade action

- Query one order -> `get-order` or `get-history-order`.
- Query open orders -> `pending-orders`.
- Query history -> `order-history`.
- Query fills -> `fills`.
- Place manual order -> `place-order` or `batch-orders`.
- Cancel -> `cancel-order`, `batch-cancel`, or `cancel-all`.
- Amend -> `amend-order` or `amend-order-sltp`.
- Trigger order -> `trigger-order`, `trigger-pending`, `trigger-history`, `cancel-trigger`, `cancel-all-triggers`.
- Position TP/SL -> `set-position-sltp`, `modify-position-sltp`, `cancel-position-sltp`.
- Close position -> `close-position` or `batch-close-position`.
- Trace / trailing order -> `trace-order` or `trace-orders`.

### Step 2: Run read commands immediately

Read commands do not need user confirmation after credentials are configured.

Rules:

- Prefer `--json` when selecting IDs, verifying status, or combining with account/market output.
- Bound history with `--limit`; default to 20 if the user gives no size.
- Use `--inst-type SWAP` for swap order/fill history and `--inst-type SPOT` for spot order/fill history.

### Step 3: Confirm before writes

Before any write command, show the exact command and wait for explicit confirmation.

Confirm:

- instrument
- side and size
- order type, price, trigger price, TP/SL price, or trace parameters
- trade mode, margin mode, position side, and position mode for swap workflows
- affected order IDs or position IDs
- whether it can increase exposure, reduce exposure, or close exposure
- verification command

Do not treat vague approval as confirmation for live trading operations.

### Step 4: Verify after writes

- After placing an order: run `dcli trade get-order --inst-id <id> --ord-id <id>` if an order ID is returned; otherwise run `pending-orders`.
- After canceling or amending: run `pending-orders` or the closest specific order query.
- After trigger writes: run `trigger-pending` or `trigger-history`.
- After TP/SL writes: run `trigger-pending`, `trigger-history`, or position query depending on returned IDs.
- After close-position writes: run `dcli account positions --inst-type SWAP --inst-id <id> --json`.

## CLI Command Reference

### Place Orders

```bash
dcli trade place-order --inst-id <id> --td-mode <isolated|cross|cash> --side <buy|sell> --ord-type <market|limit|post_only|ioc> --sz <size> [--px <price>] [--pos-side <long|short>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--cl-ord-id <id>] [--reduce-only] [--tgt-ccy <base_ccy|quote_ccy>] [--json]
dcli trade batch-orders --orders '<json-array>'
```

`--px` is required for limit and post-only orders. `batch-orders` supports up to 5 orders.

### Cancel and Amend Orders

```bash
dcli trade cancel-order --inst-id <id> --ord-id <id> [--json]
dcli trade batch-cancel --order-ids '<id,id>'
dcli trade cancel-all --product-group <Swap|SwapU> [--inst-id <id>] [--cross-margin <0|1>] [--merge-mode <0|1>]
dcli trade amend-order --order-id <id> [--price <px>] [--volume <size>]
dcli trade amend-order-sltp --order-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
```

`cancel-all` is broad. Always confirm scope and filters.

### Query Orders and Fills

```bash
dcli trade get-order --inst-id <id> --ord-id <id>
dcli trade get-history-order --inst-id <id> --ord-id <id>
dcli trade pending-orders [--inst-id <id>] [--limit <n>] [--json]
dcli trade order-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--state <canceled|filled>] [--ord-type <type>] [--limit <n>] [--json]
dcli trade batch-query --orders '<json-array>'
dcli trade fills --inst-type <SPOT|SWAP> [--inst-id <id>] [--ord-id <id>] [--limit <n>] [--json]
```

### Trigger, TP/SL, Close, Trace

```bash
dcli trade trigger-order --inst-id <id> --product-group <Swap|SwapU> --side <buy|sell> --sz <size> --trigger-price <px> [--trigger-px-type <last|index|mark>] [--order-type <market|limit>] [--price <px>] [--pos-side <long|short>] [--td-mode <isolated|cross>] [--cross-margin <0|1>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--sl-trigger-px <px>] [--json]
dcli trade cancel-trigger --inst-id <id> --ord-id <id>
dcli trade cancel-all-triggers --product-group <Swap|SwapU> [--inst-id <id>] [--cross-margin <-1|0|1>] [--merge-mode <-1|0|1>]
dcli trade trigger-pending --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
dcli trade trigger-history --inst-type <SPOT|SWAP> [--inst-id <id>] [--limit <n>] [--json]
dcli trade set-position-sltp --inst-type <SPOT|SWAP> --inst-id <id> --pos-side <long|short> [--pos-id <id>] [--td-mode <isolated|cross>] [--mrg-position <merge|split>] [--tp-trigger-px <px>] [--tp-trigger-px-type <type>] [--tp-ord-px <px|-1>] [--sl-trigger-px <px>] [--sl-trigger-px-type <type>] [--sl-ord-px <px|-1>] [--sz <size>]
dcli trade modify-position-sltp --ord-id <id> --inst-id <id> [--tp-trigger-px <px>] [--sl-trigger-px <px>]
dcli trade cancel-position-sltp --ord-id <id>
dcli trade close-position --inst-id <id> --product-group <Swap|SwapU> --position-ids '<id,id>'
dcli trade batch-close-position --inst-id <id> --product-group <Swap|SwapU>
dcli trade trace-order --inst-id <id> --retrace-point <value> --trigger-price <px> --pos-side <long|short>
dcli trade trace-orders [--json]
```

## Input / Output Examples

**"Show my open BTC swap orders."**

```bash
dcli trade pending-orders --inst-id BTC-USDT-SWAP --json
# -> summarize order ID, side, size, price, state, and creation time
```

**"Cancel this order."**

```bash
dcli trade get-order --inst-id BTC-USDT-SWAP --ord-id <id>
# -> user confirms cancellation
dcli trade cancel-order --inst-id BTC-USDT-SWAP --ord-id <id> --json
```

**"Place a BTC swap limit buy."**

```bash
dcli market ticker BTC-USDT-SWAP --json
dcli account balance --inst-type SWAP --ccy USDT --json
# -> user confirms exact command
dcli trade place-order --inst-id BTC-USDT-SWAP --td-mode isolated --side buy --ord-type limit --sz 1 --px 60000 --pos-side long --mrg-position merge --json
```

## Edge Cases

- Missing `--px` for a limit/post-only order will fail; ask for price or use a market order only when explicitly requested.
- `batch-orders` accepts at most 5 orders; `batch-cancel` accepts up to 50 IDs.
- `cancel-all` and `cancel-all-triggers` can affect many orders; always confirm filters.
- `close-position` needs position IDs; load positions from `deepcoin-portfolio` first if IDs are unknown.
- `batch-close-position` closes all positions for an instrument; confirm the blast radius.
- Do not replay order writes automatically after uncertain errors. Query state first.

## Global Notes

- All commands in this skill require Deepcoin credentials.
- Every write command requires explicit confirmation.
- Use `--json` for ID extraction, verification, and follow-up workflows.
- Keep result summaries concise: order ID, instrument, side, size, price, status, and timestamps.
- If a requested trade capability is not available in `dcli`, report the missing CLI command instead of improvising another client.
