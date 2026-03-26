# Deepcoin Agent Skills

This repository contains Deepcoin-focused agent skills for AI coding tools and assistants.

## Included Skills

- `deepcoin-market`: public market REST and public WebSocket data
- `deepcoin-account`: authenticated account queries and private WebSocket state
- `deepcoin-trade`: authenticated trading, trigger orders, TP/SL, and strategy workflows

## Suggested Layout

```text
skills/
  deepcoin-market/
    SKILL.md
  deepcoin-account/
    SKILL.md
  deepcoin-trade/
    SKILL.md
```

## Notes

- These skills are documentation-first skills.
- They are intended to help an AI tool choose the correct Deepcoin API surface and generate accurate code.
- Live execution still depends on the caller providing valid API credentials and implementing the documented signing flow.
