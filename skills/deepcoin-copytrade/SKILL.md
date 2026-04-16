---
name: deepcoin-copytrade
description: "Use this skill when the user asks about: Deepcoin copy trading, becoming a leader or follower, leader settings, copy trading contracts, follower lists, leader positions, position mode for copy trading, estimated or historical copy trading profit, or managing copy trade codes. Do NOT use for regular order placement (use deepcoin-trade), account balance (use deepcoin-portfolio), or market data (use deepcoin-market)."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.1"
  homepage: "https://api.deepcoin.com"
  openclaw:
    primaryEnv: DC_API_KEY
    requires:
      env: ["DC_API_KEY", "DC_SECRET_KEY", "DC_PASSPHRASE"]
---

# Deepcoin Copy Trade Skill

Manage copy trading features on Deepcoin — leader settings, follower management, supported contracts, positions, and profit tracking. All endpoints are **authenticated**.

## Default Rate Limit

Unless Deepcoin documents a stricter rule for a specific copy-trading endpoint, default to **1 request per second** for each endpoint group in this skill.

- Queue follower, position, and profit queries instead of firing parallel bursts.
- Serialize WRITE operations such as leader settings, contract updates, and position-type changes.
- On HTTP `429` or equivalent rate-limit errors, pause and retry with backoff rather than replaying the whole batch immediately.

---

## Authentication

Every request must include these headers:

| Header | Value |
|--------|-------|
| `DC-ACCESS-KEY` | Your API Key |
| `DC-ACCESS-SIGN` | `Base64(HMAC-SHA256(timestamp + method + requestPath + body, secretKey))` |
| `DC-ACCESS-TIMESTAMP` | ISO 8601 (e.g. `2020-12-08T09:08:57.715Z`) |
| `DC-ACCESS-PASSPHRASE` | Passphrase set when creating the API key |

**NEVER** accept API credentials in chat. Use environment variables or config files.

---

## API Endpoint Index

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 1 | Leader settings | POST | `/deepcoin/copytrading/leader-settings` | **WRITE** |
| 2 | Supported contracts | GET | `/deepcoin/copytrading/support-contracts` | READ |
| 3 | Set contracts | POST | `/deepcoin/copytrading/set-contracts` | **WRITE** |
| 4 | Follower list | GET | `/deepcoin/copytrading/follower-rank` | READ |
| 5 | Leader positions | GET | `/deepcoin/copytrading/leader-position` | READ |
| 6 | Get position type | GET | `/deepcoin/copytrading/position-type` | READ |
| 7 | Update position type | POST | `/deepcoin/copytrading/position-type` | **WRITE** |
| 8 | Estimated profit | GET | `/deepcoin/copytrading/estimate-profit` | READ |
| 9 | Historical profit | GET | `/deepcoin/copytrading/history-profit` | READ |

---

## Operation Flow

```
1. Identify intent: configure leader? check followers? view positions? profit?
2. For WRITE operations → present summary → confirm with user
3. Build authenticated request
4. Execute and present results at the default 1 request per second pace unless stricter docs say otherwise
5. After WRITE → verify with corresponding READ
```

---

## Endpoint Reference

### 1. Leader Settings

```
POST /deepcoin/copytrading/leader-settings
```

| Param | Required | Values | Description |
|-------|----------|--------|-------------|
| status | No | `0` (disable), `1` (enable) | Official docs mark this required, but observed behavior allows omission and still returns `code=0` |
| homeMode | No | `1`, `3` | Display mode |
| isClosedCopyCode | No | `true`, `false` | Default `true`; `false` means set a copy code |
| copyCode | Conditional | | Required when `isClosedCopyCode=false` |

> **WRITE** — confirm with user. Enabling leader mode makes positions visible to followers.

### 2. Supported Contracts

```
GET /deepcoin/copytrading/support-contracts
```

No parameters. Returns: `List` array of supported contract symbols.

### 3. Set Contracts

```
POST /deepcoin/copytrading/set-contracts
```

| Param | Required | Description |
|-------|----------|-------------|
| contracts | Yes | Array of compact contract symbols such as `BTCUSDT`; do not use `BTC-USDT-SWAP` |

> **WRITE** — confirm the contract list with user.

### 4. Follower List

```
GET /deepcoin/copytrading/follower-rank
```

| Param | Required | Values |
|-------|----------|--------|
| status | No | `1` (current followers, default), `2` (historical) |

Response: `followerNum`, `maxFollowerNum`, `list` (each: `userId`, `nickName`, `totalProfit`).

### 5. Leader Positions

```
GET /deepcoin/copytrading/leader-position
```

| Param | Required | Description |
|-------|----------|-------------|
| pageNum | No | Page number |
| pageSize | No | Items per page |

Response: `tradeUnitID`, `accountId`, `instrumentId`, `leverage`, `position`, `availablePosition`, `openPrice`, `useMargin`, `updateTime`, `isMergeMode`, `isCrossMargin`, `positionDirection`, `forceClosePrice`, `positionId`.

### 6. Get Position Type

```
GET /deepcoin/copytrading/position-type
```

No parameters. Returns: `positionType` — `1` (Hedge / two-way), `2` (One-way).

### 7. Update Position Type

```
POST /deepcoin/copytrading/position-type
```

| Param | Required | Values |
|-------|----------|--------|
| positionType | Yes | `1` (Hedge), `2` (One-way) |

> **WRITE** — changing position type may affect existing copy trade positions.

### 8. Estimated Profit

```
GET /deepcoin/copytrading/estimate-profit
```

No parameters. Returns: `list` (each: `userID`, `nickName`, `estimateProfit`).

### 9. Historical Profit

```
GET /deepcoin/copytrading/history-profit
```

No parameters. Returns: `list` (each: `settlementTime`, `profit`).

---

## Safety Rules

1. **Leader settings are high-impact.** Enabling leader mode exposes positions publicly. Always confirm.
2. **Contract selection** affects which instruments followers can copy. Verify the list.
3. **Position type changes** can affect open positions. Warn the user if they have active copy trades.
4. Copy trading is separate from regular trading — orders placed via copy trade use the copy trade account (`accountType=7`).

---

## Decision Workflow

### "I want to set up copy trading"

```
→ Leader or Follower?
  ├── Leader setup:
  │   1. Check supported contracts (endpoint #2)
  │   2. Set contracts to trade (endpoint #3)
  │   3. Set position type (endpoint #7)
  │   4. Enable leader mode (endpoint #1)
  │   5. Verify with follower list (endpoint #4)
  └── Follower queries:
      → View leader positions (endpoint #5)
      → Check profit (endpoints #8, #9)
```

---

## Edge Cases & Gotchas

1. **Copy trade account** is account type `7` in asset transfers. To fund it, use `deepcoin-portfolio` asset transfer endpoint.
2. **Position type `1` (Hedge)** = separate long/short positions; **`2` (One-way)** = net position.
3. **`follower-rank` status `2`** returns historical followers who have unfollowed.
4. Leader settings changes take effect immediately.

---

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| Copy trading setup, followers, leader positions, profit | **deepcoin-copytrade** (this skill) |
| Price, ticker, orderbook, candles | `deepcoin-market` |
| Place / cancel regular orders | `deepcoin-trade` |
| Account balance, positions, leverage, transfers | `deepcoin-portfolio` |
| DSL strategy orders, backtesting | `deepcoin-strategy` |
