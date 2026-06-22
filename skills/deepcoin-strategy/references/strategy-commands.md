# Deepcoin Strategy CLI Commands

All commands require API credentials. Confirm with the user before live deployment.

```bash
dcli strategy backtest --symbol <INST_ID> --from-ts <iso-time> --to-ts <iso-time> --dsl @strategy.json [--json]
dcli strategy dsl-trigger-order --symbol <INST_ID> --trade-mode <cross|isolated> --mrg-position <merge|split> --dsl @strategy.json
```

Use `@strategy.json` for non-trivial DSL payloads. Do not generate temporary API-calling scripts; only create or edit the DSL JSON artifact when the user asks you to draft or run a strategy.
