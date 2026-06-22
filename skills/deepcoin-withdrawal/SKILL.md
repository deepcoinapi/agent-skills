---
name: deepcoin-withdrawal
description: "Use this skill when the user wants to create, cancel, pre-check, configure, or query Deepcoin on-chain withdrawals, including withdrawal records, withdrawal status, withdrawable assets, supported withdrawal chains, whitelist withdrawal addresses, withdrawal config, memo/tag requirements, fees, limits, and debit account selection. Do NOT use for generic balances, positions, deposits, internal transfers, sub-account transfers, trading orders, copy trading, or strategy orders."
license: MIT
metadata:
  author: Deepcoin
  version: "1.0.2"
  homepage: "https://api.deepcoin.com"
  openclaw:
    primaryEnv: DC_API_KEY
    requires:
      env: ["DC_API_KEY", "DC_SECRET_KEY", "DC_PASSPHRASE"]
---

# Deepcoin Withdrawal Skill

Create, cancel, pre-check, and query Deepcoin on-chain withdrawals. All endpoints are **authenticated** private REST endpoints.

## CLI Execution

Before running commands, follow [`../_shared/deepcoin-cli.md`](../_shared/deepcoin-cli.md).
Use only the stable CLI commands in [`references/withdrawal-commands.md`](references/withdrawal-commands.md). Do not write temporary Python, JavaScript, shell, or cURL request/signing scripts for Deepcoin APIs.

## Performance and Rate Limits

Withdrawal endpoints are documented with a **1 request per second** frequency limit. Keep that pace unless a stricter configured limit is known.

- Serialize WRITE operations: `withdrawal` and `cancel-withdrawal`.
- Prefer `withdraw-config` before creating a withdrawal; it aggregates assets, chains, limits, memo requirements, and optional whitelist addresses.
- For independent READ requests, use the aggregate endpoint first instead of fanning out to assets, chains, and addresses.
- On HTTP `429` or equivalent rate-limit errors, back off and retry later; never replay a withdrawal write blindly.

## Authentication

Every request must include these headers:

| Header | Value |
|--------|-------|
| `DC-ACCESS-KEY` | Your API Key |
| `DC-ACCESS-SIGN` | `Base64(HMAC-SHA256(timestamp + method + requestPath + body, secretKey))` |
| `DC-ACCESS-TIMESTAMP` | ISO 8601 timestamp |
| `DC-ACCESS-PASSPHRASE` | Passphrase set when creating the API key |

**Never accept or print API credentials in chat.** Use environment variables or local config.

## API Endpoint Index

| # | Endpoint | Method | Path | Type |
|---|----------|--------|------|------|
| 1 | Create withdrawal | POST | `/deepcoin/asset/withdrawal` | **WRITE** |
| 2 | Cancel withdrawal | POST | `/deepcoin/asset/cancel-withdrawal` | **WRITE** |
| 3 | Withdrawal records | GET | `/deepcoin/asset/withdraw-list` | READ |
| 4 | Single withdrawal status | GET | `/deepcoin/asset/withdrawal-status` | READ |
| 5 | Withdrawable assets | GET | `/deepcoin/asset/withdraw-assets` | READ |
| 6 | Withdrawal chains | GET | `/deepcoin/asset/withdraw-chains` | READ |
| 7 | Whitelist addresses | GET | `/deepcoin/asset/withdraw-addresses` | READ |
| 8 | Aggregated withdrawal config | GET | `/deepcoin/asset/withdraw-config` | READ |

## Operation Flow

```text
1. Identify intent: create / cancel / query status / query records / pre-check config.
2. For create:
   - Call withdraw-config with ccy and includeAddresses=true unless equivalent validated config is already in context.
   - Select a chain from chains[].chain, not the platform-internal chain type.
   - Select a whitelist address by addressId; API withdrawals require whitelist addresses.
   - Validate withdrawEnabled, apiWithdrawEnabled, minWd, maxWd if present, precision, fee, quota, and memo/tag requirements.
   - Use at most one accountTypes value: funding, spot, or swap. Omit it to default to funding.
   - Present a confirmation summary and wait for explicit user confirmation.
   - Submit POST withdrawal once, then verify with withdrawal-status or withdraw-list.
3. For cancel:
   - Query the withdrawal first when wdId state/canCancel is unknown.
   - Present a cancellation summary and wait for explicit user confirmation.
   - Run `deepcoin-cli withdrawal cancel` once, then verify with `deepcoin-cli withdrawal status`.
4. For read-only queries:
   - Use the narrowest CLI command; use `deepcoin-cli withdrawal config` for pre-withdrawal checks.
5. If the requested operation is not exposed by deepcoin-cli, stop and report the missing CLI command.
```

## Endpoint Reference

### 1. Create Withdrawal

```text
POST /deepcoin/asset/withdrawal
```

| Param | Required | Description |
|-------|----------|-------------|
| `ccy` | Yes | Coin, e.g. `USDT` |
| `chain` | Yes | OpenAPI chain from config, e.g. `USDT-TRC20` |
| `amt` | Yes | Withdrawal amount as a string |
| `addressId` | Yes | Whitelist address ID |
| `toAddr` | No | Address consistency check against whitelist |
| `memo` | Conditional | Required when chain or whitelist address needs memo/tag/payment ID |
| `accountTypes` | No | Array with at most one value: `funding`, `spot`, `swap`; default is `funding` |
| `clientId` | No | Client request ID, max 32 characters |
| `remark` | No | Remark |

Response fields: `wdId`, `clientId`, `ccy`, `chain`, `amt`, `fee`, `state`, `cTime`.

### 2. Cancel Withdrawal

```text
POST /deepcoin/asset/cancel-withdrawal
```

| Param | Required | Description |
|-------|----------|-------------|
| `wdId` | Yes | Withdrawal ID |
| `ccy` | No | Coin |
| `clientId` | No | Tracking client request ID |

Response fields: `wdId`, `clientId`, `state`, `uTime`, `canCancel`.

### 3. Withdrawal Records

```text
GET /deepcoin/asset/withdraw-list
```

| Param | Required | Description |
|-------|----------|-------------|
| `coin` / `ccy` | No | Coin filter |
| `chain` | No | Chain filter |
| `txHash` / `txId` | No | Transaction hash filter |
| `wdId` | No | Withdrawal ID filter |
| `state` | No | `pending`, `auditing`, `cancelling`, `succeed`, `failed`, `cancelled` |
| `startTime` / `endTime` | No | Millisecond timestamp; docs limit history to the last 6 months |
| `page` | No | Default `1` |
| `size` | No | Default `20`, max `100` |

Record fields include `wdId`, `clientId`, `ccy`, `chain`, `amt`, `fee`, `toAddr`, `memo`, `txId`, `state`, `canCancel`, `cTime`, `uTime`, and compatibility fields such as `txHash`, `address`, `amount`, `coin`, `status`.

### 4. Single Withdrawal Status

```text
GET /deepcoin/asset/withdrawal-status
```

| Param | Required | Description |
|-------|----------|-------------|
| `wdId` | Yes | Withdrawal ID |
| `ccy` | No | Coin |

Returns the same item structure as withdrawal records.

### 5. Withdrawable Assets

```text
GET /deepcoin/asset/withdraw-assets
```

| Param | Required | Description |
|-------|----------|-------------|
| `ccy` | No | Coin |

Response fields: `ccy`, `available`, `withdrawable`, and `accounts[]` with `accountType` (`funding`, `spot`, `swap`) and `available`.

### 6. Withdrawal Chains

```text
GET /deepcoin/asset/withdraw-chains
```

| Param | Required | Description |
|-------|----------|-------------|
| `ccy` | Yes | Coin |

Response fields: `ccy`, `chain`, `chainName`, `chainType`, `withdrawEnabled`, `state`, `minWd`, `maxWd`, `fee`, `feeCcy`, `precision`, `needMemo`, `memoName`, `reason`, `uTime`.

### 7. Whitelist Addresses

```text
GET /deepcoin/asset/withdraw-addresses
```

| Param | Required | Description |
|-------|----------|-------------|
| `ccy` | Yes | Coin |
| `chain` | No | OpenAPI chain |
| `addressId` | No | Whitelist address ID |

Response fields: `addressId`, `ccy`, `chain`, `chainType`, `toAddr`, `memo`, `label`, `apiWithdrawEnabled`, `state`, `cTime`, `uTime`.

### 8. Aggregated Withdrawal Config

```text
GET /deepcoin/asset/withdraw-config
```

| Param | Required | Description |
|-------|----------|-------------|
| `ccy` | Yes | Coin |
| `includeAddresses` | No | Include whitelist addresses; use `true` before creating a withdrawal |

Response fields: `ccy`, `withdrawable`, `quota`, `usedQuota`, `leftQuota`, `withdrawEnabled`, `addressWhitelistWithdrawOnly`, `notice`, `assets[]`, `addresses[]`, `chains[]`.

## Safety Rules

1. Creating or cancelling withdrawals always requires explicit user confirmation.
2. Treat withdrawals as irreversible once accepted by the platform. Never retry a create request unless idempotency via `clientId` and final status are understood.
3. Confirm `ccy`, `chain`, `amt`, `addressId`, `toAddr`, `memo`, `fee`, and `accountTypes` before a create write.
4. Use whitelist `addressId`; do not invent addresses or bypass whitelist restrictions.
5. When `needMemo=true` or the whitelist address has a memo, require the exact memo in the withdrawal request.
6. Validate precision and minimum/maximum withdrawal amount before asking for confirmation.
7. Never expose API secrets, signatures, or passphrases in output or logs.

## Scope & Boundaries

| User Intent | Skill to Use |
|-------------|-------------|
| On-chain withdrawal create/cancel/status/config/whitelist | **deepcoin-withdrawal** (this skill) |
| Generic balances, positions, account bills, deposits, transfers | `deepcoin-portfolio` |
| Internal transfers between Deepcoin users | `deepcoin-portfolio` |
| Place/cancel/amend trading orders | `deepcoin-trade` |
| Public market data | `deepcoin-market` |
| Copy trading | `deepcoin-copytrade` |
| Strategy orders and backtests | `deepcoin-strategy` |
