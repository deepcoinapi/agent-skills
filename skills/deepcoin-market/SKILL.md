---
name: deepcoin-market
description: "Use this skill when the user asks for: price of any crypto asset on Deepcoin, ticker data, order book depth, recent trades, K-line / candlestick data (regular, mark-price, index-price), funding rate, instrument metadata (tickSz, minSz, leverage tiers), step margin, book spread, system time, or real-time public WebSocket market streams. Do NOT use for account balance / positions (use deepcoin-portfolio), order placement / cancellation (use deepcoin-trade), copy trading (use deepcoin-copytrade), or strategy orders (use deepcoin-strategy)."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.0"
  homepage: "https://api.deepcoin.com"
---

# Deepcoin Market Skill

Retrieve public market data from Deepcoin via REST APIs and public WebSocket channels. All endpoints in this skill are **unauthenticated** — no API key required.

## Compliance Disclaimer

Market data returned by these APIs is raw exchange data. It is **not** financial advice. The agent must never interpret price data as a buy/sell recommendation.

---

## API Endpoint Index

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 1 | Instruments (product info) | GET | `/deepcoin/market/instruments` | READ |
| 2 | Market tickers | GET | `/deepcoin/market/tickers` | READ |
| 3 | Order book | GET | `/deepcoin/market/books` | READ |
| 4 | Recent trades | GET | `/deepcoin/market/trades` | READ |
| 5 | K-line / candlesticks | GET | `/deepcoin/market/candles` | READ |
| 6 | Index price K-line | GET | `/deepcoin/market/index-candles` | READ |
| 7 | Mark price K-line | GET | `/deepcoin/market/mark-price-candles` | READ |
| 8 | Historical K-line (1m) | GET | `/deepcoin/market/handicap-kline1m` | READ |
| 9 | Historical orderbook | GET | `/deepcoin/market/handicap-orderbook` | READ |
| 10 | Historical trades | GET | `/deepcoin/market/handicap-trade` | READ |
| 11 | Step margin | GET | `/deepcoin/market/step-margin` | READ |
| 12 | Book spread | GET | `/deepcoin/market/book-spread` | READ |
| 13 | Server time | GET | `/deepcoin/market/time` | READ |
| 14 | Ping | GET | `/deepcoin/market/ping` | READ |
| 15 | Current funding rate | GET | `/deepcoin/trade/fund-rate/current-funding-rate` | READ |
| 16 | Funding rate list | GET | `/deepcoin/trade/funding-rate` | READ |
| 17 | Funding rate history | GET | `/deepcoin/trade/fund-rate/history` | READ |

> All endpoints are READ-only. No authentication headers are required.

---

## Operation Flow

```
1. Identify user intent (price? depth? candles? streaming?)
2. Select the correct endpoint from the index above
3. Build the request with required parameters
4. Return a minimal, runnable code snippet (Python / JS / cURL)
5. Explain what the response fields mean if the user is unfamiliar
```

---

## Endpoint Reference

### 1. Instruments (Product Info)

```
GET /deepcoin/market/instruments
```

| Param | Required | Values | Description |
|-------|----------|--------|-------------|
| instType | Yes | `SPOT`, `SWAP` | Instrument type |
| uly | No | e.g. `BTC-USDT` | Underlying |
| instId | No | e.g. `BTC-USDT-SWAP` | Specific instrument |

Key response fields: `instId`, `baseCcy`, `quoteCcy`, `tickSz`, `lotSz`, `minSz`, `maxLmtSz`, `maxMktSz`, `lever`, `ctVal`, `state`.

### 2. Market Tickers

```
GET /deepcoin/market/tickers
```

| Param | Required | Values |
|-------|----------|--------|
| instType | Yes | `SPOT`, `SWAP` |
| uly | No | e.g. `BTC-USDT` |

Key response fields: `instId`, `last`, `lastSz`, `askPx`, `askSz`, `bidPx`, `bidSz`, `open24h`, `high24h`, `low24h`, `vol24h`, `volCcy24h`, `ts`.

### 3. Order Book

```
GET /deepcoin/market/books
```

| Param | Required | Values |
|-------|----------|--------|
| instId | Yes | e.g. `BTC-USDT-SWAP` |
| sz | No | Max 400 levels |

Response: `asks` and `bids` arrays, each element is `[price, size]`.

### 4. Recent Trades

```
GET /deepcoin/market/trades
```

| Param | Required | Values |
|-------|----------|--------|
| instId | Yes | e.g. `BTC-USDT` |
| productGroup | No | `Spot`, `Swap`, `SwapU` |
| limit | No | Max 500, default 100 |

### 5. K-line / Candlesticks

```
GET /deepcoin/market/candles
```

| Param | Required | Values |
|-------|----------|--------|
| instId | Yes | e.g. `BTC-USDT-SWAP` |
| bar | No | `1m`, `5m`, `15m`, `30m`, `1H`, `4H`, `12H`, `1D`, `1W`, `1M`, `1Y` |
| after | No | Pagination timestamp |
| limit | No | Max 300 |

Response: array of `[ts, open, high, low, close, vol_base, vol_quote]`.

### 6–7. Index / Mark Price K-lines

```
GET /deepcoin/market/index-candles
GET /deepcoin/market/mark-price-candles
```

Same parameters as `/candles`. Response: `[ts, open, high, low, close, 0, 0]`.

### 8–10. Historical Handicap Data

```
GET /deepcoin/market/handicap-kline1m
GET /deepcoin/market/handicap-orderbook
GET /deepcoin/market/handicap-trade
```

| Param | Required | Description |
|-------|----------|-------------|
| symbol | Yes | e.g. `BTC-USDT-SWAP` |
| stime | Yes | Start time in **seconds** |
| etime | Yes | End time in **seconds** |
| limit | No | 1–2000 |

> Note: these endpoints use `symbol` (not `instId`) and **seconds** (not milliseconds).

### 11. Step Margin

```
GET /deepcoin/market/step-margin
```

| Param | Required | Description |
|-------|----------|-------------|
| instId | Yes | SWAP instruments only |

Response: `grade`, `leverage`, `maxContractValue`, `maintenanceMarginRate`.

### 12. Book Spread

```
GET /deepcoin/market/book-spread
```

| Param | Required | Description |
|-------|----------|-------------|
| instId | Yes | e.g. `BTC-USDT-SWAP` |
| value | No | Order value |
| vType | No | `0` = quoteCcy, `1` = baseCcy |

### 13–14. System Info

```
GET /deepcoin/market/time    → { ts: "1597026383085" }
GET /deepcoin/market/ping    → connectivity check
```

### 15–17. Funding Rate

```
GET /deepcoin/trade/fund-rate/current-funding-rate
    Params: instType (SwapU/Swap), instId

GET /deepcoin/trade/funding-rate
    Params: instType (SwapU/Swap), instId

GET /deepcoin/trade/fund-rate/history
    Params: instId, page, size (max 100)
```

---

## Public WebSocket

### Connection URLs

| Market | URL |
|--------|-----|
| Swap contracts | `wss://stream.deepcoin.com/streamlet/trade/public/swap?platform=api` |
| Spot | `wss://stream.deepcoin.com/streamlet/trade/public/spot?platform=api` |

Heartbeat: send `ping`, receive `pong`.

### Subscribe Format (v2 — recommended)

```json
{
  "action": "sub",
  "topic": "{topic}",
  "instId": "{instId}",
  "version": "v2"
}
```

### Available Topics (v2)

| Topic | Description | Example instId |
|-------|-------------|----------------|
| `market` | Latest tick data | `BTC-USDT-SWAP` |
| `trade` | Recent trades | `BTC-USDT-SWAP` |
| `kline-{period}` | K-line data | `BTC-USDT-SWAP` |
| `book25` | 25-level incremental orderbook | `BTC-USDT-SWAP` |
| `liquidationOrder` | Liquidation orders | `BTC-USDT-SWAP` |

K-line periods: `1m`, `5m`, `15m`, `30m`, `1h`, `4h`, `12h`, `1d`, `1w`, `1o`, `1y`.

### V1 Topics (legacy)

| TopicID | Description |
|---------|-------------|
| 2 | Transaction details |
| 7 | Latest market data |
| 11 | K-lines (1m only) |
| 25 | 25-level orderbook |
| 30 | Liquidation orders |

---

## Edge Cases & Gotchas

1. **instId format**: Always use the exact format — `BTC-USDT` for spot, `BTC-USDT-SWAP` for perpetual swap. Case-sensitive.
2. **Handicap endpoints** use `symbol` param (not `instId`) and timestamps in **seconds** (not milliseconds).
3. **K-line bar values** are case-sensitive: `1H` not `1h` for REST; WebSocket v2 uses lowercase `1h`.
4. **Funding rate endpoints** live under `/deepcoin/trade/` path but are public READ operations — included here for discoverability.
5. **Order book `sz`** max is 400 levels. For real-time incremental updates, use WebSocket `book25` topic instead.
6. **Rate limits**: Market data endpoints are typically limited to 5 req/s per IP.

---

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| Price, ticker, orderbook, candles, funding rate, instruments | **deepcoin-market** (this skill) |
| Account balance, positions, leverage, assets, transfers | `deepcoin-portfolio` |
| Place / cancel / amend orders, trigger orders, TP/SL | `deepcoin-trade` |
| Copy trading settings, followers, leader positions | `deepcoin-copytrade` |
| DSL strategy orders, backtesting | `deepcoin-strategy` |

---

## Example Requests

### Get BTC-USDT spot ticker (cURL)

```bash
curl "https://api.deepcoin.com/deepcoin/market/tickers?instType=SPOT&uly=BTC-USDT"
```

### Get 1-hour K-lines for BTC-USDT-SWAP (Python)

```python
import requests

resp = requests.get("https://api.deepcoin.com/deepcoin/market/candles", params={
    "instId": "BTC-USDT-SWAP",
    "bar": "1H",
    "limit": 100
})
candles = resp.json()["data"]
```

### Subscribe to real-time trades via WebSocket (Python)

```python
import websockets, json, asyncio

async def stream():
    uri = "wss://stream.deepcoin.com/streamlet/trade/public/swap?platform=api"
    async with websockets.connect(uri) as ws:
        await ws.send(json.dumps({
            "action": "sub",
            "topic": "trade",
            "instId": "BTC-USDT-SWAP",
            "version": "v2"
        }))
        async for msg in ws:
            if msg == "pong":
                continue
            print(json.loads(msg))

asyncio.run(stream())
```
