---
name: deepcoin-market
description: "Use this skill when the user wants Deepcoin public market data, including tickers, order book, trades, K-line/candlestick data, mark/index prices, funding rate, instrument info, or public WebSocket subscriptions. Do not use for authenticated account queries or order placement."
license: Apache-2.0
metadata:
  author: Deepcoin
  version: "0.1.0"
  homepage: "https://api.deepcoin.com"
---

# Deepcoin Market Skill

This skill helps an AI agent answer questions and generate code for Deepcoin public market data APIs and public WebSocket channels.

## Use This Skill For

- Latest ticker and book spread
- Order book depth and recent public trades
- K-line, mark price K-line, and index K-line queries
- Instrument metadata such as `instId`, `tickSz`, and `minSz`
- Funding rate and funding rate history
- Public WebSocket subscriptions for market data streams

## Do Not Use This Skill For

- Private account balance, bills, or positions
- Placing, cancelling, or modifying orders
- Private WebSocket login or account/order push streams

## Primary Deepcoin API Areas

- Market tickers
- Order book and book spread
- Public trades
- K-line, mark K-line, and index K-line
- Product info and trading rules
- Current funding rate and funding rate history
- Public WebSocket channels for tickers, books, K-lines, and trades

## Working Rules

1. Prefer REST for one-shot lookups and historical pulls.
2. Prefer public WebSocket when the user asks for streaming or real-time subscriptions.
3. Always keep `instId` exactly as documented, for example `BTC-USDT` or `BTC-USDT-SWAP`.
4. When generating trading-related examples, fetch or reference `tickSz` and `minSz` from product info first.
5. If the user asks for "latest" data, explain that the result depends on live API responses and provide runnable code instead of fabricating values.

## Expected Output Style

- Summarize which endpoint or channel is being used and why.
- Provide minimal runnable code in the user's requested language when possible.
- For WebSocket examples, show subscribe payload and message handling.
- For historical data, document key parameters such as symbol, interval, start time, and limit.

## Routing

- Public market data or market stream requests: use `deepcoin-market`
- Authenticated balance/position/bill requests: use `deepcoin-account`
- Order placement/cancel/modify/trigger order requests: use `deepcoin-trade`
