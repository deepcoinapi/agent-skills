---
name: deepcoin-portfolio
description: "Use this skill when the user asks for: Deepcoin account balance, equity, available margin, frozen balance, unrealized PnL, open positions, position details (leverage, liquidation price, margin), account bills / transaction history, UID, leverage settings, sub-account management, sub-account transfers, internal transfers between users, asset deposits / withdrawals / chain info, or private WebSocket streams for account and position updates. Do NOT use for public market data (use deepcoin-market), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
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

# Deepcoin Portfolio Skill

Query account state, positions, balances, leverage, sub-accounts, assets, and transfers on Deepcoin. All endpoints are **authenticated** unless noted otherwise.

## Default Rate Limit

Unless Deepcoin documents a stricter rule for a specific portfolio endpoint, default to **1 request per second** for each endpoint group in this skill.

- If a read-only workflow needs several account queries, queue them instead of sending an unchecked burst.
- When the user does not specify spot vs swap and both balances must be queried, run the two requests sequentially under the default pacing.
- Serialize WRITE operations such as leverage changes or transfers.
- On HTTP `429` or equivalent rate-limit errors, pause and retry with backoff rather than hammering the same endpoint.

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
2. For balance queries:
   - If user explicitly says spot / 现货 → query `GET /deepcoin/account/balances` with `instType=SPOT`
   - If user explicitly says swap / contract / 合约 → query `GET /deepcoin/account/balances` with `instType=SWAP`
   - If user does **not** specify spot vs swap → query both `instType=SPOT` and `instType=SWAP`, then present both results clearly
3. Select the correct endpoint from the index
4. For WRITE operations (leverage, transfers) → present summary → confirm with user
5. Build authenticated request
6. Execute and present results at the default 1 request per second pace unless stricter docs say otherwise
7. After WRITE → verify with a corresponding READ
```

---

## Endpoint Reference

### 1. Account Balance

```
GET /deepcoin/account/balances
```

| Param | Required | Values |
|-------|----------|--------|
| instType | Yes | `SPOT`, `SWAP` (`SPOT` = 现货, `SWAP` = 合约) |
| ccy | No | e.g. `USDT` |

Response: `ccy`, `bal`, `frozenBal`, `availBal`, `unrealizedProfit`, `equity`.

Observed behavior: omitting `instType` may return an empty list without an explicit error.
Balance-query rule: when the user asks to "check balance" but does not specify spot vs swap, run this endpoint twice with `instType=SPOT` and `instType=SWAP`, then report both sections.

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
| instType | Yes | `SWAP`, `SPOT` (`SWAP` = 合约, `SPOT` = 现货) |
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
| mrgPosition | Yes | `merge`, `split` |

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
| page | Yes | Pagination page number (minimum `1`) |
| size | Yes | Pagination size (minimum `1`, maximum `100`) |

Response format note: this endpoint uses `retCode`, `retMsg`, `retData` rather than the more common `code`, `msg`, `data`.

### 9. Sub-Account Total Balance

```
GET /deepcoin/sub-account/sub-account-balance-total
```

Official docs include this endpoint, but observed behavior is `404 Not Found`. Treat it as unavailable unless the upstream service is restored.

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
| lang | Yes |

Response: `chain`, `state`, `address`, `hasMemo`, `estimatedTime`.

### 14–16. Internal Transfer

```
GET  /deepcoin/internal-transfer/support
    → Returns nested data under `data.data[]`; each item contains coin/min/max style fields

POST /deepcoin/internal-transfer
    Params: amount, coin, receiverAccount, accountType, receiverUID
    → WRITE: confirm before executing

GET  /deepcoin/internal-transfer/history-order
    Params: account, coin, status (1=pending, 2=success, 3=failed),
            receiverUID, orderId, startTime, endTime, page, size
```

`internal-transfer` request params:

| Param | Required | Values / Description |
|-------|----------|----------------------|
| amount | Yes | Transfer amount |
| coin | Yes | Coin symbol, e.g. `USDT` |
| receiverAccount | Yes | Recipient email or phone value |
| accountType | Yes | `email`, `phone` |
| receiverUID | Yes | Recipient UID |

### 17–19. Rebate / Affiliate

```
GET /deepcoin/agents/users/rebates
    Params: uid, type (0=normal rebate, 1=abnormal frozen, 2=total), startTime, endTime

GET /deepcoin/agents/users
    Params: uid, startTime, endTime

GET /deepcoin/agents/users/rebate-list
    Params: uid, type (0=normal rebate, 1=abnormal frozen, 2=total), startTime, endTime, pageNum, pageSize
```

### 20–22. Trade Statistics

```
GET /deepcoin/apiUserTradeStats/daily
GET /deepcoin/apiUserTradeStats/total
GET /deepcoin/apiUserTradeStats/instrument
```

Common params:
- `appid` (required): AppID such as `FMZ`, `CCXT`, `Hummingbot`
- `uid` (optional)
- `startTime` (required, seconds)
- `endTime` (required, seconds)
- `instrumentIds`:
  - optional for `/daily` and `/total`
  - required for `/instrument`

Access note: these endpoints may return `403` with code `51028` until Deepcoin support enables the required whitelist permission.

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
