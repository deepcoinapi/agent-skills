# Deepcoin Strategy CLI Commands

`dcli strategy` commands require Deepcoin credentials. Confirm with the user before live deployment. Use `dcli strategy <command> --help` when a flag value is unclear.

## Backtest

```bash
dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json [--json]
```

Notes:

- `--dsl` accepts inline JSON or `@filepath`; prefer `@strategy.json`.
- Supported indicators include `BOLL`, `MA`, `EMA`, `KDJ`, `RSI`, `WR`.
- Supported condition operators include `>=`, `<=`, `>`, `<`, `==`, `cross_above`, `cross_below`.
- Use ISO 8601 timestamps.

## Live Deployment

```bash
dcli strategy dsl-trigger-order --symbol <INST_ID> --trade-mode <cross|isolated> --mrg-position <merge|split> --dsl @strategy.json
```

Live deployment is a WRITE command. Confirm strategy file, symbol, trade mode, position mode, and backtest status before running.

## DSL Artifact Rules

- Creating or editing a strategy DSL JSON file is allowed when the user asks for a strategy artifact.
- Do not create helper scripts that bypass `dcli`.
- Validate JSON before running `dcli strategy`.
