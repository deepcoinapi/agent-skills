# SKILLS.md

## Skill Routing Principle

Use the smallest capable skill that matches the user's intent. Do not load extra skills unless they materially improve the answer.

## Deepcoin Skill Map

### `deepcoin-market`

Use for:

- ticker and price queries
- orderbook depth
- recent trades
- candles and K-lines
- funding rate
- instrument metadata
- public WebSocket market streams

Do not use for:

- balances or positions
- order placement or cancellation
- copy trading management
- strategy creation

### `deepcoin-trade`

Use for:

- place orders
- cancel orders
- amend orders
- trigger orders
- TP/SL changes
- close position workflows
- fills and order-state queries tied to execution

Special rule:

- Any write-capable use of this skill requires explicit confirmation.

### `deepcoin-portfolio`

Use for:

- balances
- positions
- leverage
- transfers
- sub-accounts
- account-level state

Special rule:

- Any movement of funds or account-setting changes requires explicit confirmation.

### `deepcoin-copytrade`

Use for:

- leader settings
- follower management
- copy trading status
- leader or follower positions
- copy trading performance details

Special rule:

- Treat changes to copy relationships or settings as write operations.

### `deepcoin-strategy`

Use for:

- strategy DSL generation
- indicator-based conditions
- backtesting requests
- strategy parameter review
- structured automation logic

Special rule:

- If a strategy can be submitted live, separate design from live deployment and require confirmation for deployment.

## Multi-Skill Workflows

When the request spans more than one skill, use this order:

1. `deepcoin-market` for market context
2. `deepcoin-portfolio` for account constraints
3. `deepcoin-trade` for execution
4. `deepcoin-copytrade` for copy context
5. `deepcoin-strategy` for automation or rule logic

## Routing Examples

- "What is BTC funding rate now?" -> `deepcoin-market`
- "Show my open BTC positions" -> `deepcoin-portfolio`
- "Place a BTC limit buy order at 62000" -> `deepcoin-trade`
- "Cancel my pending ETH order" -> `deepcoin-trade`
- "Help me build an RSI strategy" -> `deepcoin-strategy`
- "How are my copy followers performing?" -> `deepcoin-copytrade`

## Skill Invocation Rules

- Prefer implicit routing when the intent is unambiguous.
- If two skills overlap, choose the read-only skill first.
- If a write step depends on instrument constraints, query market metadata first.
- If a write step depends on available balance or positions, query portfolio state first.
- Never assume credentials are present just because a skill exists.

## Missing Skill Behavior

If the ideal skill is unavailable:

1. State which capability is missing.
2. Provide the best safe fallback.
3. Do not fabricate hidden tools or endpoints.
