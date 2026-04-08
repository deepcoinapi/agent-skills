---
name: deepcoin-portfolio
description: "Use this skill when the user asks for: Deepcoin account balance, equity, available margin, frozen balance, unrealized PnL, open positions, position details (leverage, liquidation price, margin), account bills / transaction history, UID, leverage settings, sub-account management, sub-account transfers, internal transfers between users, asset deposits / withdrawals / chain info, or private WebSocket streams for account and position updates. Do NOT use for public market data (use deepcoin-market), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.0"
  homepage: "https://api.deepcoin.com"
  openclaw:
    primaryEnv: DC_API_KEY
    requires:
      env: ["DC_API_KEY", "DC_SECRET_KEY", "DC_PASSPHRASE"]
---

# Deepcoin Portfolio Skill

Query account state, positions, balances, leverage, sub-accounts, assets, and transfers on Deepcoin. All endpoints are **authenticated** unless noted otherwise.

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

### Account

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 1 | Account balance | GET | `/deepcoin/account/balances` | READ |
| 2 | Account bills | GET | `/deepcoin/account/bills` | READ |
| 3 | Positions | GET | `/deepcoin/account/positions` | READ |
| 4 | Set leverage | POST | `/deepcoin/account/set-leverage` | **WRITE** |
| 5 | Get UID | GET | `/deepcoin/account/uid` | READ |

### Sub-Account

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 6 | Sub-account list | GET | `/deepcoin/sub-account/sub-account-list` | READ |
| 7 | Sub-account transfer | POST | `/deepcoin/sub-account/sub-account-transfer` | **WRITE** |
| 8 | Sub-account transfer records | GET | `/deepcoin/sub-account/sub-account-transfer-record` | READ |
| 9 | Sub-account total balance | GET | `/deepcoin/sub-account/sub-account-balance-total` | READ |

### Assets

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 10 | Deposit list | GET | `/deepcoin/asset/deposit-list` | READ |
| 11 | Withdrawal list | GET | `/deepcoin/asset/withdraw-list` | READ |
| 12 | Asset transfer | POST | `/deepcoin/asset/transfer` | **WRITE** |
| 13 | Recharge chain list | GET | `/deepcoin/asset/recharge-chain-list` | READ |

### Internal Transfer

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 14 | Supported coins | GET | `/deepcoin/internal-transfer/support` | READ |
| 15 | Make internal transfer | POST | `/deepcoin/internal-transfer` | **WRITE** |
| 16 | Transfer history | GET | `/deepcoin/internal-transfer/history-order` | READ |

### Rebate / Affiliate

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 17 | Rebate summary | GET | `/deepcoin/agents/users/rebates` | READ |
| 18 | Affiliate list | GET | `/deepcoin/agents/users` | READ |
| 19 | Rebate details | GET | `/deepcoin/agents/users/rebate-list` | READ |

### Trade Statistics

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 20 | Daily trade stats | GET | `/deepcoin/apiUserTradeStats/daily` | READ |
| 21 | Total trade stats | GET | `/deepcoin/apiUserTradeStats/total` | READ |
| 22 | Instrument trade stats | GET | `/deepcoin/apiUserTradeStats/instrument` | READ |

---

## Operation Flow

```
1. Identify intent: balance? positions? leverage? transfer? deposit history?
2. Select the correct endpoint from the index
3. For WRITE operations (leverage, transfers) → present summary → confirm with user
4. Build authenticated request
5. Execute and present results
6. After WRITE → verify with a corresponding READ
```

---

## Endpoint Reference

### 1. Account Balance

```
GET /deepcoin/account/balances
```

| Param | Required | Values |
|-------|----------|--------|
| instType | No | `SPOT`, `SWAP` (`SPOT` = 现货, `SWAP` = 合约) |
| ccy | No | e.g. `USDT` |

Response: `ccy`, `bal`, `frozenBal`, `availBal`, `unrealizedProfit`, `equity`.

### 2. Account Bills

```
GET /deepcoin/account/bills
```

| Param | Required | Values |
|-------|----------|--------|
| instType | Yes | `SPOT`, `SWAP` (`SPOT` = 现货, `SWAP` = 合约) |
| ccy | No | e.g. `USDT` |
| type | No | `2` (transfer), `3` (trade), `4` (fee rebate), `5` (funding) |
| after / before | No | Pagination |
| limit | No | Max 100 |

Response: `billId`, `ccy`, `balChg`, `bal`, `type`, `ts`.

### 3. Positions

```
GET /deepcoin/account/positions
```

| Param | Required | Values |
|-------|----------|--------|
| instType | No | `SWAP`, `SPOT` (`SWAP` = 合约, `SPOT` = 现货) |
| instId | No | e.g. `BTC-USDT-SWAP` |

Response: `instId`, `posId`, `posSide`, `pos`, `avgPx`, `lever`, `liqPx`, `useMargin`, `unrealizedProfit`, `lastPx`, `tpTriggerPx`, `slTriggerPx`, `mrgPosition` (merge/split), `mgnMode` (cross/isolated), `ccy`, `uTime`, `cTime`.

### 4. Set Leverage

```
POST /deepcoin/account/set-leverage
```

| Param | Required | Values |
|-------|----------|--------|
| instId | Yes | e.g. `BTC-USDT-SWAP` |
| lever | Yes | e.g. `10` |
| mgnMode | Yes | `cross`, `isolated` |
| mrgPosition | No | `merge`, `split` |

> **WRITE operation** — confirm with user before executing.

### 5. Get UID

```
GET /deepcoin/account/uid
```

No parameters. Returns: `uid`.

### 6. Sub-Account List

```
GET /deepcoin/sub-account/sub-account-list
```

No parameters. Returns array: `subUid`, `subNickname`, `subAccount`.

### 7. Sub-Account Transfer

```
POST /deepcoin/sub-account/sub-account-transfer
```

| Param | Required | Description |
|-------|----------|-------------|
| fromUid | Yes | Source UID |
| toUid | Yes | Target UID |
| fromId | Yes | Account type: `1` (spot), `2` (contract), `5` (fund), `7` (copy trade) |
| toId | Yes | Same as fromId values |
| amount | Yes | Transfer amount |
| coin | Yes | e.g. `USDT` |

> **WRITE operation** — confirm with user before executing.

### 8. Sub-Account Transfer Records

```
GET /deepcoin/sub-account/sub-account-transfer-record
```

| Param | Required | Values |
|-------|----------|--------|
| coin | No | e.g. `USDT` |
| fromId / toId | No | Account type filter |
| relationType | No | `1` (main→sub), `2` (sub→main), `3` (sub→sub) |
| page / size | No | Pagination (max 100) |

### 9. Sub-Account Total Balance

```
GET /deepcoin/sub-account/sub-account-balance-total
```

No parameters. Returns: `balance`.

### 10–11. Deposit / Withdrawal Lists

```
GET /deepcoin/asset/deposit-list
GET /deepcoin/asset/withdraw-list
```

| Param | Required |
|-------|----------|
| coin | No |
| txHash | No |
| startTime / endTime | No |
| page / size | No |

### 12. Asset Transfer

```
POST /deepcoin/asset/transfer
```

| Param | Required | Description |
|-------|----------|-------------|
| currency_id | Yes | e.g. `USDT` |
| amount | Yes | Amount |
| from_id | Yes | `1`=spot, `2`=contract, `3`=OTC, `5`=fund, `7`=copy trade, `10`=earn |
| to_id | Yes | Same values as from_id |
| uid | No | Target UID |

> **WRITE operation** — confirm with user before executing.

### 13. Recharge Chain List

```
GET /deepcoin/asset/recharge-chain-list
```

| Param | Required |
|-------|----------|
| currency_id | Yes |
| lang | No |

Response: `chain`, `state`, `address`, `hasMemo`, `estimatedTime`.

### 14–16. Internal Transfer

```
GET  /deepcoin/internal-transfer/support
    → Returns: array of [coin, min, max]

POST /deepcoin/internal-transfer
    Params: amount, coin, receiverAccount, accountType, receiverUID
    → WRITE: confirm before executing

GET  /deepcoin/internal-transfer/history-order
    Params: account, coin, status (1=pending, 2=success, 3=failed),
            receiverUID, orderId, startTime, endTime, page, size
```

### 17–19. Rebate / Affiliate

```
GET /deepcoin/agents/users/rebates
    Params: uid, type (0=all, 1=spot, 2=swap), startTime, endTime

GET /deepcoin/agents/users
    Params: uid, startTime, endTime

GET /deepcoin/agents/users/rebate-list
    Params: uid, type, startTime, endTime, pageNum, pageSize
```

### 20–22. Trade Statistics

```
GET /deepcoin/apiUserTradeStats/daily
GET /deepcoin/apiUserTradeStats/total
GET /deepcoin/apiUserTradeStats/instrument
```

Common params: `appid`, `uid`, `startTime`, `endTime`, `instrumentIds`.

---

## Private WebSocket

### Setup

1. Get listen key: `GET /deepcoin/listenkey/acquire` → returns `listenkey`, `expire_time`
2. Connect: `wss://stream.deepcoin.com/v1/private?listenKey={listenKey}`
3. Extend key before expiry: `GET /deepcoin/listenkey/extend?listenkey={key}` (extends 1 hour)

### Push Message Types

| Message Type | Description |
|-------------|-------------|
| `PushAccountDetail` | Account detail changes |
| `PushPosition` | Position updates |
| `PushOrder` | Order status changes |
| `PushTrade` | Trade execution notifications |
| `PushTriggerOrder` | Trigger order notifications |
| `PushAccount` | Asset / balance changes |

---

## Safety Rules

1. **WRITE operations (leverage, transfers) require user confirmation.** Present a clear summary before executing.
2. **Never expose or log** API keys, secrets, or passphrases.
3. **Transfer operations are irreversible** — double-check amounts, UIDs, and account types.
4. **Sub-account transfers**: verify `fromId`/`toId` account type codes carefully.
5. **Internal transfers to other users** require correct `receiverAccount` / `receiverUID`.
6. For read-only queries, prefer code generation over live execution.

---

## Edge Cases & Gotchas

1. **Account type IDs** differ across endpoints:
   - Sub-account: `1`=spot, `2`=contract, `5`=fund, `7`=copy trade
   - Asset transfer: adds `3`=OTC, `10`=earn
2. **Bill types**: `2`=transfer, `3`=trade, `4`=fee rebate, `5`=funding
3. **Position `mrgPosition`**: `merge` = combined position, `split` = separate long/short
4. **Listen key expires** — must call extend endpoint before expiry or reconnect
5. **Trade stats** require `appid` parameter

---

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| Balance, positions, leverage, assets, transfers, sub-accounts, stats | **deepcoin-portfolio** (this skill) |
| Price, ticker, orderbook, candles, funding rate | `deepcoin-market` |
| Place / cancel / amend orders, trigger orders, TP/SL | `deepcoin-trade` |
| Copy trading settings, followers, leader positions | `deepcoin-copytrade` |
| DSL strategy orders, backtesting | `deepcoin-strategy` |
