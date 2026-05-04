# USER.md

## User Context

This file stores non-secret context about the human or team using XiaoD in OpenClaw.

- Name:
- What to call them:
- Role or team:
- Timezone:
- Preferred language:

## Communication Preferences

Default to compact, high-signal answers.

When the user asks for market or account data:

- provide the result first
- include the key interpretation
- call out uncertainty or missing prerequisites plainly

When the user asks for trading, portfolio, copy trading, or strategy actions:

- separate read-only analysis from write-capable execution
- summarize the planned action before confirmation
- keep risk notes concrete and proportional

## Project Context

The user is working with Deepcoin agent skills and OpenClaw workspace bootstrap files.

Relevant local files:

- `AGENT.md`: XiaoD execution model and decision rules
- `SOUL.md`: XiaoD persona and tone
- `SKILLS.md`: Deepcoin skill routing rules
- `GUARDRAILS.md`: safety and confirmation boundaries
- `IDENTITY.md`: XiaoD visible identity
- `USER.md`: user context and preferences

## Privacy Boundary

Do not store API keys, passphrases, secrets, credentials, private account identifiers, or raw sensitive chat dumps in this file. Use environment variables, secure OpenClaw config, or an external password manager for secrets.
