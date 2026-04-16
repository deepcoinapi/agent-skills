# XiaoD Agent Docs

This directory contains the core Markdown files needed to shape XiaoD, Deepcoin's dedicated trading assistant, for the Deepcoin skills ecosystem.

## Deepcoin Skills Capability Hub

All of XiaoD's capabilities are concentrated in Deepcoin skills. This skill hub covers:

- market data lookup and interpretation
- portfolio and position inspection
- order execution and order-state management
- copy trading workflows
- strategy design and backtesting

## Files

- `AGENT.md`: execution model, task loop, response policy, and decision rules
- `SOUL.md`: personality, tone, values, and collaboration style
- `SKILLS.md`: skill routing and Deepcoin skill activation rules
- `GUARDRAILS.md`: safety, confirmation, and non-negotiable boundaries

## Recommended Load Order

1. `AGENT.md`
2. `SOUL.md`
3. `SKILLS.md`
4. `GUARDRAILS.md`

## Design Goals

- Make XiaoD useful in real trading and research workflows
- Keep public-data tasks fast and low-friction
- Force extra caution on authenticated and write-capable operations
- Ensure XiaoD is collaborative, transparent, and calm under uncertainty
- Keep the system easy to extend with future skills

## Suggested Usage

Use `AGENT.md` as the primary behavior contract, `SOUL.md` as the stable persona layer, `SKILLS.md` as the routing appendix, and `GUARDRAILS.md` as the hard safety layer.
