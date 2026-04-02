---
name: deepcoin-strategy
description: "Use this skill when the user asks about: Deepcoin DSL strategy orders, automated trading strategies with indicators (BOLL, MA, EMA, KDJ, RSI, WR), strategy backtesting, or DSL-based trigger orders. Do NOT use for regular manual orders (use deepcoin-trade), account queries (use deepcoin-portfolio), market data (use deepcoin-market), or copy trading (use deepcoin-copytrade)."
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

# Deepcoin Strategy Skill

Create and backtest automated trading strategies on Deepcoin using a DSL (Domain Specific Language) that supports technical indicators and conditional entry/exit logic. All endpoints are **authenticated**.

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
| 1 | Backtest strategy | POST | `/deepcoin/trade/backtest-run` | READ |
| 2 | DSL trigger order | POST | `/deepcoin/trade/dsl-trigger-order` | **WRITE** |

---

## Operation Flow

```
1. Understand the user's strategy intent (indicators, entry/exit logic, risk)
2. Build the DSL JSON structure
3. Run a backtest first to validate the strategy
4. Review backtest results with user
5. If user confirms → deploy as a live DSL trigger order
6. ALWAYS backtest before deploying live
```

---

## DSL Structure

The DSL is a JSON object with a specific schema for defining indicator-based strategies.

### Top-Level Structure

```json
{
  "version": "1.0",
  "indicators": [...],
  "then": {
    "entry": {...},
    "exit": {...}
  },
  "risk": {
    "stop_loss": {...},
    "take_profit": {...}
  },
  "execution": {
    "order_type": "market"
  }
}
```

### Supported Indicators

| Indicator | Params | Description |
|-----------|--------|-------------|
| `BOLL` | `period`, `std_dev` | Bollinger Bands (upper, middle, lower) |
| `MA` | `period` | Simple Moving Average |
| `EMA` | `period` | Exponential Moving Average |
| `KDJ` | `period` | KDJ Stochastic |
| `RSI` | `period` | Relative Strength Index |
| `WR` | `period` | Williams %R |

### Indicator Definition Example

```json
{
  "name": "BOLL",
  "params": { "period": 20, "std_dev": 2 },
  "conditions": [
    { "field": "lower", "op": ">=", "ref": "close" }
  ]
}
```

### Condition Operators

| Operator | Description |
|----------|-------------|
| `>=` | Greater than or equal |
| `<=` | Less than or equal |
| `>` | Greater than |
| `<` | Less than |
| `==` | Equal |
| `cross_above` | Crosses above |
| `cross_below` | Crosses below |

### Reference Fields

- `close` — current close price
- `open`, `high`, `low` — OHLC prices
- Other indicator output fields (e.g. `upper`, `middle`, `lower` for BOLL; `k`, `d`, `j` for KDJ)

### Entry / Exit Definition

```json
{
  "then": {
    "entry": {
      "side": "buy",
      "posSide": "long",
      "logic": "AND"
    },
    "exit": {
      "side": "sell",
      "posSide": "long",
      "logic": "AND"
    }
  }
}
```

- `logic`: `AND` (all indicator conditions must be true) or `OR` (any condition triggers)

### Risk Management

```json
{
  "risk": {
    "stop_loss": { "percent": 2.0 },
    "take_profit": { "percent": 5.0 }
  }
}
```

---

## Endpoint Reference

### 1. Backtest Strategy

```
POST /deepcoin/trade/backtest-run
```

Request body:

```json
{
  "dsl": {
    "version": "1.0",
    "indicators": [
      {
        "name": "BOLL",
        "params": { "period": 20, "std_dev": 2 },
        "conditions": [
          { "field": "lower", "op": ">=", "ref": "close" }
        ]
      }
    ],
    "then": {
      "entry": { "side": "buy", "posSide": "long", "logic": "AND" },
      "exit": { "side": "sell", "posSide": "long", "logic": "AND" }
    },
    "risk": {
      "stop_loss": { "percent": 2.0 },
      "take_profit": { "percent": 5.0 }
    },
    "execution": { "order_type": "market" }
  },
  "data_source": {
    "symbol": "BTC-USDT-SWAP",
    "from_ts": "2024-01-01T00:00:00Z",
    "to_ts": "2024-06-01T00:00:00Z"
  }
}
```

Response:

```json
{
  "summary": {
    "realized_pnl": 1234.56,
    "symbol": "BTC-USDT-SWAP",
    "total_fee": 12.34,
    "trades": 42
  },
  "trades": [...]
}
```

### 2. DSL Trigger Order (Live Deployment)

```
POST /deepcoin/trade/dsl-trigger-order
```

| Param | Required | Description |
|-------|----------|-------------|
| trade_info.symbol | Yes | e.g. `BTC-USDT-SWAP` |
| trade_info.tradeMode | Yes | `isolated`, `cross` |
| trade_info.mrgPosition | Yes | `merge`, `split` |
| dsl_json | Yes | Full DSL JSON (same structure as backtest) |

> **WRITE operation** — this deploys a live automated strategy. Always confirm with user.

---

## Safety Rules

1. **Always backtest before deploying live.** Present backtest results and get explicit user confirmation.
2. **DSL trigger orders execute automatically.** Make the user aware that once deployed, trades happen without manual intervention.
3. **Validate indicator parameters** — e.g., BOLL period should be reasonable (typically 10–50), RSI period typically 14.
4. **Risk parameters are critical** — stop_loss and take_profit percentages directly affect capital at risk.
5. **Never fabricate** backtest results or PnL numbers.

---

## Decision Workflow

### "I want to create an automated strategy"

```
→ What indicators? (BOLL, MA, EMA, KDJ, RSI, WR)
→ Entry conditions? (which fields, which operators, AND/OR logic)
→ Exit conditions?
→ Risk management? (stop loss %, take profit %)
→ Which instrument? (e.g. BTC-USDT-SWAP)
→ Build DSL JSON
→ Run backtest first (endpoint #1)
→ Present results: PnL, number of trades, fees
→ User confirms? → Deploy live (endpoint #2)
```

---

## Example: Bollinger Band + RSI Strategy

### DSL Definition

```json
{
  "version": "1.0",
  "indicators": [
    {
      "name": "BOLL",
      "params": { "period": 20, "std_dev": 2 },
      "conditions": [
        { "field": "lower", "op": ">=", "ref": "close" }
      ]
    },
    {
      "name": "RSI",
      "params": { "period": 14 },
      "conditions": [
        { "field": "rsi", "op": "<=", "ref": 30 }
      ]
    }
  ],
  "then": {
    "entry": { "side": "buy", "posSide": "long", "logic": "AND" },
    "exit": { "side": "sell", "posSide": "long", "logic": "AND" }
  },
  "risk": {
    "stop_loss": { "percent": 2.0 },
    "take_profit": { "percent": 5.0 }
  },
  "execution": { "order_type": "market" }
}
```

**Logic**: Enter long when price touches the lower Bollinger Band AND RSI is below 30 (oversold). Exit with 5% take profit or 2% stop loss.

---

## Edge Cases & Gotchas

1. **DSL version** must be `"1.0"` — include it in every DSL object.
2. **Backtest `data_source`** uses ISO 8601 timestamps for `from_ts` and `to_ts`.
3. **Indicator `conditions` reference** can be a string field name (e.g. `"close"`) or a numeric literal (e.g. `30` for RSI threshold).
4. **`execution.order_type`** should typically be `"market"` for strategy orders.
5. **Trade mode** in `trade_info` must match the user's account configuration (cross vs isolated, merge vs split).

---

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| DSL strategy orders, backtesting, automated indicator-based trading | **deepcoin-strategy** (this skill) |
| Price, ticker, orderbook, candles | `deepcoin-market` |
| Manual order placement / cancellation | `deepcoin-trade` |
| Account balance, positions, leverage, transfers | `deepcoin-portfolio` |
| Copy trading | `deepcoin-copytrade` |
