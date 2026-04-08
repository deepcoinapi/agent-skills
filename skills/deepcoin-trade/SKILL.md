---
name: deepcoin-trade
description: "Use this skill when the user wants to: place, cancel, amend, or query orders on Deepcoin (spot, swap, margin); use trigger / conditional orders; set or modify take-profit / stop-loss on positions or orders; close positions (single or batch); query pending orders, order history, or trade fills; place trace orders. Do NOT use for read-only account queries (use deepcoin-portfolio), public market data (use deepcoin-market), copy trading (use deepcoin-copytrade), or DSL strategy orders (use deepcoin-strategy)."
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

# Deepcoin Trade Skill

Place, manage, and query orders on Deepcoin. All endpoints in this skill are **authenticated** and require request signing.

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
| 1 | Place order | POST | `/deepcoin/trade/order` | **WRITE** |
| 2 | Batch place orders | POST | `/deepcoin/trade/batch-orders` | **WRITE** |
| 3 | Cancel order | POST | `/deepcoin/trade/cancel-order` | **WRITE** |
| 4 | Batch cancel orders | POST | `/deepcoin/trade/batch-cancel-order` | **WRITE** |
| 5 | Cancel all orders | POST | `/deepcoin/trade/swap/cancel-all` | **WRITE** |
| 6 | Amend order | POST | `/deepcoin/trade/replace-order` | **WRITE** |
| 7 | Amend order TP/SL | POST | `/deepcoin/trade/replace-order-sltp` | **WRITE** |
| 8 | Get order by ID | GET | `/deepcoin/trade/orderByID` | READ |
| 9 | Get historical order by ID | GET | `/deepcoin/trade/finishOrderByID` | READ |
| 10 | Pending orders | GET | `/deepcoin/trade/v2/orders-pending` | READ |
| 11 | Order history | GET | `/deepcoin/trade/orders-history` | READ |
| 12 | Batch order query | POST | `/deepcoin/trade/batch-order-query` | READ |
| 13 | Trade fills | GET | `/deepcoin/trade/fills` | READ |
| 14 | Trigger order | POST | `/deepcoin/trade/trigger-order` | **WRITE** |
| 15 | Cancel trigger order | POST | `/deepcoin/trade/cancel-trigger-order` | **WRITE** |
| 16 | Cancel all trigger orders | POST | `/deepcoin/trade/swap/cancel-trigger-all` | **WRITE** |
| 17 | Pending trigger orders | GET | `/deepcoin/trade/trigger-orders-pending` | READ |
| 18 | Trigger order history | GET | `/deepcoin/trade/trigger-orders-history` | READ |
| 19 | Set position TP/SL | POST | `/deepcoin/trade/set-position-sltp` | **WRITE** |
| 20 | Modify position TP/SL | POST | `/deepcoin/trade/modify-position-sltp` | **WRITE** |
| 21 | Cancel position TP/SL | POST | `/deepcoin/trade/cancel-position-sltp` | **WRITE** |
| 22 | Close position by IDs | POST | `/deepcoin/trade/close-position-by-ids` | **WRITE** |
| 23 | Batch close position | POST | `/deepcoin/trade/batch-close-position` | **WRITE** |
| 24 | Trace order | POST | `/deepcoin/trade/trace-order` | **WRITE** |
| 25 | Pending trace orders | GET | `/deepcoin/trade/trace-order-list` | READ |

---

## Operation Flow

```
1. Identify intent: place / cancel / amend / query / TP-SL / close
2. For WRITE operations → build confirmation summary → ask user to confirm
3. For order placement → fetch instrument info first (tickSz, minSz, lotSz)
4. Build authenticated request with correct signing
5. Execute the request
6. After any WRITE → verify with a READ (e.g. query order status)
```

---

## Endpoint Reference

### 1. Place Order

```
POST /deepcoin/trade/order
```

| Param | Required | Values | Description |
|-------|----------|--------|-------------|
| instId | Yes | e.g. `BTC-USDT-SWAP` | Instrument ID |
| tdMode | Yes | `isolated`, `cross`, `cash` | Trade mode (`cash` for spot) |
| side | Yes | `buy`, `sell` | Order side |
| ordType | Yes | `market`, `limit`, `post_only`, `ioc` | Order type |
| sz | Yes | e.g. `1` | Size (contracts for swap, base currency for spot) |
| px | Conditional | e.g. `30000` | Price (required for limit orders) |
| posSide | Conditional | `long`, `short` | Required for SWAP in split position mode |
| mrgPosition | No | `merge`, `split` | Position mode |
| tpTriggerPx | No | | Take-profit trigger price |
| slTriggerPx | No | | Stop-loss trigger price |
| clOrdId | No | | Client order ID |

Response: `ordId`, `clOrdId`, `sCode`, `sMsg`.

### 2. Batch Place Orders

```
POST /deepcoin/trade/batch-orders
```

Body: `orders` array (max **5** items), each with the same fields as place order.

### 3. Cancel Order

```
POST /deepcoin/trade/cancel-order
```

| Param | Required |
|-------|----------|
| instId | Yes |
| ordId | Yes |

### 4. Batch Cancel Orders

```
POST /deepcoin/trade/batch-cancel-order
```

Body: `orderSysIDs` array (max **50** order IDs).

### 5. Cancel All Orders

```
POST /deepcoin/trade/swap/cancel-all
```

| Param | Required | Values |
|-------|----------|--------|
| InstrumentID | Yes | e.g. `BTC-USDT-SWAP` |
| ProductGroup | Yes | `Swap`, `SwapU` |
| IsCrossMargin | Yes | `0` (isolated), `1` (cross) |
| IsMergeMode | Yes | `0` (split), `1` (merge) |

### 6. Amend Order

```
POST /deepcoin/trade/replace-order
```

| Param | Required | Description |
|-------|----------|-------------|
| OrderSysID | Yes | Order ID to amend |
| price | No | New price |
| volume | No | New size |

### 7. Amend Order TP/SL

```
POST /deepcoin/trade/replace-order-sltp
```

| Param | Required |
|-------|----------|
| orderSysID | Yes |
| tpTriggerPx | No |
| slTriggerPx | No |

### 8–9. Query Order

```
GET /deepcoin/trade/orderByID          → active or recent order
GET /deepcoin/trade/finishOrderByID    → historical / completed order
```

Params: `instId`, `ordId`.

### 10. Pending Orders

```
GET /deepcoin/trade/v2/orders-pending
```

| Param | Required | Description |
|-------|----------|-------------|
| instId | No | Filter by instrument |
| index | No | Pagination index |
| limit | No | Max 100, default 30 |
| ordId | No | Specific order |

### 11. Order History

```
GET /deepcoin/trade/orders-history
```

| Param | Required | Values |
|-------|----------|--------|
| instType | Yes | `SPOT`, `SWAP` (`SPOT` = 现货, `SWAP` = 合约) |
| instId | No | Filter |
| ordType | No | Filter |
| state | No | `canceled`, `filled` |
| after / before | No | Pagination |
| limit | No | Max 100 |

### 12. Batch Order Query

```
POST /deepcoin/trade/batch-order-query
```

Body: `orders` array (max 5), each with `instId` and `ordId` or `clOrdId`.

### 13. Trade Fills

```
GET /deepcoin/trade/fills
```

| Param | Required |
|-------|----------|
| instType | Yes | `SPOT` or `SWAP` (`SPOT` = 现货, `SWAP` = 合约) |
| instId | No |
| ordId | No |
| begin / end | No |
| limit | No (max 100) |

Response: `tradeId`, `fillPx`, `fillSz`, `side`, `posSide`, `execType`, `fee`, `ts`.

### 14. Trigger Order

```
POST /deepcoin/trade/trigger-order
```

| Param | Required | Values |
|-------|----------|--------|
| instId | Yes | e.g. `BTC-USDT-SWAP` |
| productGroup | Yes | `Spot`, `Swap` |
| sz | Yes | Order size |
| side | Yes | `buy`, `sell` |
| triggerPrice | Yes | Trigger price |
| triggerPxType | No | `last`, `index`, `mark` (default `last`) |
| orderType | Yes | `limit`, `market` |
| price | Conditional | Required for limit |
| posSide | Conditional | `long`, `short` (SWAP only) |
| tdMode | Yes | `cash`, `cross`, `isolated` |
| isCrossMargin | No | `0`, `1` |
| mrgPosition | No | `merge`, `split` |
| tpTriggerPx | No | TP trigger price |
| slTriggerPx | No | SL trigger price |
| closePosId | No | Position ID to close |

### 15–16. Cancel Trigger Orders

```
POST /deepcoin/trade/cancel-trigger-order
    Params: instId, ordId, clOrdId

POST /deepcoin/trade/swap/cancel-trigger-all
    Params: ProductGroup, InstrumentID, IsCrossMargin (-1/0/1), IsMergeMode (-1/0/1)
```

### 17–18. Query Trigger Orders

```
GET /deepcoin/trade/trigger-orders-pending
GET /deepcoin/trade/trigger-orders-history
```

Params: `instType`, `instId`, `orderType`, `limit` (max 100).

### 19–21. Position TP/SL

```
POST /deepcoin/trade/set-position-sltp      → create new TP/SL
POST /deepcoin/trade/modify-position-sltp    → modify existing (requires ordId)
POST /deepcoin/trade/cancel-position-sltp    → cancel (requires ordId)
```

Common params: `instType`, `instId`, `posSide`, `mrgPosition`, `tdMode`, `posId`, `tpTriggerPx`, `tpTriggerPxType`, `tpOrdPx`, `slTriggerPx`, `slTriggerPxType`, `slOrdPx`, `sz`.

Trigger price types: `last`, `index`, `mark`.

### 22–23. Close Positions

```
POST /deepcoin/trade/close-position-by-ids
    Params: productGroup (Spot/Swap/SwapU), instId, positionIds (array)

POST /deepcoin/trade/batch-close-position
    Params: productGroup (Spot/Swap/SwapU), instId
```

### 24–25. Trace Orders

```
POST /deepcoin/trade/trace-order
    Params: instId, retracePoint, triggerPrice, posSide (long/short)

GET /deepcoin/trade/trace-order-list
    Returns: array with retracePoint, triggerPrice, breakPrice, isTriggered, createTime
```

---

## Safety Rules

1. **WRITE operations require user confirmation.** Before executing any WRITE endpoint, present a summary:
   - Instrument, side, size, price, order type, leverage, TP/SL if set
   - Ask the user to confirm before proceeding.

2. **Never fabricate** order IDs, fill data, or execution results.

3. **Always fetch instrument metadata first** (`/deepcoin/market/instruments`) to validate `tickSz`, `minSz`, `lotSz` before generating order parameters.

4. **Preserve field values exactly** as documented: `tdMode`, `side`, `ordType`, `posSide`, `mrgPosition`.

5. **Swap order intent must be explicit.** If the user request is ambiguous between:
   - Spot vs. Swap → ask for clarification
   - Open vs. Close → ask for clarification
   - Long vs. Short → ask for clarification

6. **After every WRITE** → verify with a READ (query order status, check pending orders).

7. **Batch limits**: place orders max 5, cancel orders max 50.

---

## Decision Workflows

### "I want to buy BTC"

```
→ Spot or Swap?
  ├── Spot → tdMode=cash, side=buy, no posSide needed
  └── Swap → tdMode=cross/isolated
      ├── Open long → side=buy, posSide=long
      └── Close short → side=buy, posSide=short
→ Market or Limit?
  ├── Market → ordType=market, no px
  └── Limit → ordType=limit, px required
→ Any TP/SL? → add tpTriggerPx / slTriggerPx
→ Confirm with user → execute
```

### "Set a stop loss on my position"

```
→ Does user have posId? 
  ├── Yes → use set-position-sltp with posId
  └── No → query positions first (deepcoin-portfolio)
→ Trigger price type? (last/index/mark, default last)
→ Limit or market SL? → slOrdPx for limit, omit for market
→ Confirm → execute
```

### "Cancel my orders"

```
→ Specific order? → cancel-order with ordId
→ All orders for an instrument? → cancel-all
→ All trigger orders? → cancel-trigger-all
→ Multiple specific orders? → batch-cancel-order
```

---

## Edge Cases & Gotchas

1. **Position mode matters**: In `merge` mode, `posSide` is not used. In `split` mode, `posSide` (long/short) is required for SWAP orders.
2. **`cancel-all` and `cancel-trigger-all`** require `ProductGroup` (`Swap` vs `SwapU`) and margin/position mode flags.
3. **Trigger order `triggerPxType`**: defaults to `last` but can be `index` or `mark` — clarify with user for precision.
4. **`closePosId`** in trigger orders: used to attach a trigger order to close a specific position.
5. **Rate limits**: Most trading endpoints are 1 req/s per API key.
6. **Response `sCode`**: `"0"` means success. Non-zero means error — always check `sMsg`.

---

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| Place / cancel / amend orders, trigger orders, TP/SL, close positions | **deepcoin-trade** (this skill) |
| Price, ticker, orderbook, candles, funding rate | `deepcoin-market` |
| Account balance, positions, leverage, assets, transfers | `deepcoin-portfolio` |
| Copy trading settings, followers, leader positions | `deepcoin-copytrade` |
| DSL strategy orders, backtesting | `deepcoin-strategy` |

---

## Example Requests

### Place a limit buy order on BTC-USDT-SWAP (Python)

```python
import os
import requests, hmac, hashlib, base64, json
from datetime import datetime, timezone

API_KEY = os.environ["DC_API_KEY"]
SECRET_KEY = os.environ["DC_SECRET_KEY"]
PASSPHRASE = os.environ["DC_PASSPHRASE"]
BASE = os.environ.get("DC_API_BASE_URL", "https://api.deepcoin.com")

timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
method = "POST"
path = "/deepcoin/trade/order"
body = json.dumps({
    "instId": "BTC-USDT-SWAP",
    "tdMode": "cross",
    "side": "buy",
    "posSide": "long",
    "ordType": "limit",
    "sz": "1",
    "px": "60000"
})

sign_str = timestamp + method + path + body
signature = base64.b64encode(
    hmac.new(SECRET_KEY.encode(), sign_str.encode(), hashlib.sha256).digest()
).decode()

resp = requests.post(BASE + path, json=json.loads(body), headers={
    "DC-ACCESS-KEY": API_KEY,
    "DC-ACCESS-SIGN": signature,
    "DC-ACCESS-TIMESTAMP": timestamp,
    "DC-ACCESS-PASSPHRASE": PASSPHRASE,
    "Content-Type": "application/json"
})
print(resp.json())
```

### Cancel an order (cURL)

```bash
BASE_URL="${DC_API_BASE_URL:-https://api.deepcoin.com}"

curl -X POST "$BASE_URL/deepcoin/trade/cancel-order" \
  -H "Content-Type: application/json" \
  -H "DC-ACCESS-KEY: $DC_API_KEY" \
  -H "DC-ACCESS-SIGN: $SIGNATURE" \
  -H "DC-ACCESS-TIMESTAMP: $TIMESTAMP" \
  -H "DC-ACCESS-PASSPHRASE: $DC_PASSPHRASE" \
  -d '{"instId":"BTC-USDT-SWAP","ordId":"123456789"}'
```
