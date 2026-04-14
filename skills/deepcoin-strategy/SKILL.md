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
  "indicators": [
    {
      "name": "boll",
      "type": "BOLL",
      "scope": "entry",
      "params": { "period": 20, "std": 2, "interval": "1m" },
      "condition": { "ref": "boll.lower", "op": "<" }
    }
  ],
  "then": {
    "entry": {
      "on_true": { "action": "open", "side": "long", "volume": 100 }
    },
    "exit": {
      "on_true": { "action": "close", "side": "long", "volume": 100 }
    }
  },
  "risk": {
    "stop_loss": { "value": 0.1 },
    "take_profit": { "value": 0.2 }
  },
  "execution": {
    "fee_bps": 5
  }
}
```

### Supported Indicators

| Indicator | Params | Description |
|-----------|--------|-------------|
| `BOLL` | `period`, `std`, `interval` | Bollinger Bands (upper, middle, lower) |
| `MA` | `period`, `interval` | Simple Moving Average |
| `EMA` | `period`, `interval` | Exponential Moving Average |
| `KDJ` | `n`, `k_smoothing`, `d_smoothing`, `interval` | KDJ Stochastic |
| `RSI` | `period`, `interval` | Relative Strength Index |
| `WR` | `period`, `interval` | Williams %R |

### Indicator Definition Example

```json
{
  "name": "boll",
  "type": "BOLL",
  "scope": "entry",
  "params": { "period": 20, "std": 2, "interval": "1m" },
  "condition": { "ref": "boll.lower", "op": "<" }
}
```

### Condition Operators

| Operator | Description |
|----------|-------------|
| `>` | Greater than |
| `<` | Less than |

### Reference Fields

- `boll.lower`, `boll.upper`, `ma5.value` style indicator fields
- `right` can be a fixed threshold for KDJ / RSI / WR
- `diff_price` can express distance from current market price

### Entry / Exit Definition

```json
{
  "then": {
    "entry": {
      "on_true": {
        "action": "open",
        "side": "long",
        "volume": 100
      }
    },
    "exit": {
      "on_true": {
        "action": "close",
        "side": "long",
        "volume": 100
      }
    }
  }
}
```

### Risk Management

```json
{
  "risk": {
    "stop_loss": { "value": 0.1 },
    "take_profit": { "value": 0.2 }
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
        "name": "boll",
        "type": "BOLL",
        "scope": "entry",
        "params": { "period": 20, "std": 2, "interval": "1m" },
        "condition": { "ref": "boll.lower", "op": "<" }
      }
    ],
    "then": {
      "entry": { "on_true": { "action": "open", "side": "long", "volume": 100 } },
      "exit": { "on_true": { "action": "close", "side": "long", "volume": 100 } }
    },
    "risk": {
      "stop_loss": { "value": 0.1 },
      "take_profit": { "value": 0.2 }
    },
    "execution": { "fee_bps": 5 }
  },
  "data_source": {
    "symbol": "BTC-USDT-SWAP",
    "from_ts": 1772054911,
    "to_ts": 1772090911
  },
  "include_trades": true
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

Observed limitation: testing indicates a required order-size field is still missing from the published backtest schema. Attempts without that extra size field fail, and the correct accepted placement within the payload is not yet documented in the API docs.

### 2. DSL Trigger Order (Live Deployment)

```
POST /deepcoin/trade/dsl-trigger-order
```

| Param | Required | Description |
|-------|----------|-------------|
| trade_info.symbol | Yes | e.g. `BTC-USDT-SWAP` |
| trade_info.tradeMode | Yes | `isolated`, `cross` |
| trade_info.mrgPosition | No | `merge`, `split` (default `merge`) |
| dsl_json | Yes | Full DSL JSON using `indicators`, `condition`, `then.entry/exit.on_true`, and optional `risk` |

> **WRITE operation** — this deploys a live automated strategy. Always confirm with user.

Observed limitation: live deployment appears to have the same undocumented size-field gap as backtesting. The public docs do not currently describe a working payload shape that satisfies this extra requirement.

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
      "name": "boll",
      "type": "BOLL",
      "scope": "entry",
      "params": { "period": 20, "std": 2, "interval": "1m" },
      "condition": { "ref": "boll.lower", "op": "<" }
    },
    {
      "name": "rsi",
      "type": "RSI",
      "scope": "entry",
      "params": { "period": 14, "interval": "1m" },
      "condition": { "ref": "rsi.value", "op": "<", "right": 30 }
    }
  ],
  "then": {
    "entry": { "on_true": { "action": "open", "side": "long", "volume": 100 } }
  },
  "risk": {
    "stop_loss": { "value": 0.02 },
    "take_profit": { "value": 0.05 }
  },
  "execution": { "fee_bps": 5 }
}
```

**Logic**: Enter long when the Bollinger lower-band condition and RSI<30 are both satisfied. Protect the position with 5% take profit and 2% stop loss.

---

## Edge Cases & Gotchas

1. **DSL version** should be `"1.0"` when included.
2. **Backtest `data_source`** uses Unix timestamps in seconds for `from_ts` and `to_ts`.
3. **Indicator blocks** use `type`, `params`, `condition`, and `scope`; they do not use the older `conditions[]` shape.
4. **Live strategy orders** support `on_true` action branches; keep payloads aligned with the documented DSL shape.
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
