---
name: deepcoin-trade
description: "Use this skill when the user wants to place, cancel, amend, query, or manage Deepcoin spot, margin, swap, trigger, take-profit, stop-loss, batch, copy-trading, or strategy orders. Do not use for pure market data or read-only account queries."
license: Apache-2.0
metadata:
  author: Deepcoin
  version: "0.1.0"
  homepage: "https://api.deepcoin.com"
---

# Deepcoin Trade Skill

This skill helps an AI agent generate safe and accurate code for Deepcoin trading workflows based on the documented REST and private WebSocket APIs.

## Use This Skill For

- Place spot or swap orders
- Cancel, batch cancel, replace, or query orders
- Query pending orders, order history, fills, and trigger orders
- Manage take-profit and stop-loss settings
- Close positions and batch close positions
- Strategy and copy-trading related order flows

## Do Not Use This Skill For

- Pure public market data lookups
- Balance-only or position-only questions when no trading action is requested

## Primary Deepcoin API Areas

- Request authentication and signature generation
- Place, cancel, replace, and query orders
- Pending orders, order history, and fills
- Batch orders and batch cancel/query
- Trigger orders and trigger order history
- Position TP/SL set, replace, and cancel
- Close position and batch close position
- Strategy orders and backtesting
- Copy-trading configuration, positions, and profit queries

## Safety Rules

1. Never fabricate execution results, order IDs, or live fill data.
2. Before generating order examples, reference product metadata such as `minSz`, `tickSz`, and the correct `instId`.
3. Preserve the documented Deepcoin request fields exactly, including:
   - `tdMode`
   - `side`
   - `ordType`
   - `posSide`
   - `mrgPosition`
   - `reduceOnly`
4. For swap orders, be explicit about open/close intent through `side`, `posSide`, and `mrgPosition`.
5. If the user request is ambiguous between spot and swap, or between opening and closing a position, ask for clarification before generating execution code.
6. When the user only wants code or documentation help, default to code generation and API examples, not real execution.

## Expected Output Style

- State the target endpoint first.
- Show the minimal required request body.
- If helpful, add one realistic example for spot and one for swap.
- Mention request signing requirements for every private REST call.
- Call out risk-sensitive parameters such as leverage, reduce-only, trigger price, and position side.

## Routing

- Public market data only: use `deepcoin-market`
- Balance, positions, bills, or private streams: use `deepcoin-account`
- Order and strategy workflows: use `deepcoin-trade`
