---
name: deepcoin-account
description: "Use this skill when the user wants Deepcoin authenticated account data, including balance, positions, bills, UID, leverage settings, sub-account assets, internal transfer history, or private WebSocket account/position/order subscriptions. Do not use for public market data or order execution requests."
license: Apache-2.0
metadata:
  author: Deepcoin
  version: "0.1.0"
  homepage: "https://api.deepcoin.com"
---

# Deepcoin Account Skill

This skill helps an AI agent work with Deepcoin authenticated account APIs and private account state streams.

## Use This Skill For

- Account balance, positions, bills, and UID
- Leverage configuration and account-level settings
- Sub-account asset queries and transfers
- Internal transfer records
- Private WebSocket subscriptions for assets, positions, orders, trades, and account details

## Do Not Use This Skill For

- Public market snapshots or historical candles
- Placing, cancelling, or replacing orders

## Primary Deepcoin API Areas

- Request authentication and signature generation
- Account balance, positions, bills, UID, and leverage settings
- Sub-account list, balance summary, transfers, and transfer records
- Internal transfer supported coins, transfer execution, and transfer history
- Private WebSocket subscribe flow
- Private WebSocket assets, positions, orders, trades, and account details channels

## Working Rules

1. For any private REST example, include the required headers:
   - `DC-ACCESS-KEY`
   - `DC-ACCESS-SIGN`
   - `DC-ACCESS-TIMESTAMP`
   - `DC-ACCESS-PASSPHRASE`
2. Use the documented signature formula: `timestamp + method + requestPath + body`.
3. Never ask the user to paste real API secrets into chat if local environment variables or config files can be used.
4. Distinguish one-shot REST queries from private WebSocket subscriptions.
5. If the user asks to inspect balances or positions "now", state that live authenticated API access is required and provide code or request examples instead of inventing results.

## Expected Output Style

- Start from the exact account use case: balance, position, bill, transfer, or stream.
- Show the signing flow when giving raw REST code.
- Keep examples conservative and read-only unless the user clearly asks for a state-changing action.

## Routing

- Public market data: use `deepcoin-market`
- Authenticated account state: use `deepcoin-account`
- Trading and strategy orders: use `deepcoin-trade`
