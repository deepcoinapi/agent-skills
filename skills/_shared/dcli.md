# Deepcoin CLI Execution Rules

Use `dcli` as the execution boundary for every Deepcoin skill.

## Preflight

Run these checks once per session before any Deepcoin command:

```bash
dcli --version
dcli list-tools
```

If `dcli` is missing, install or build the CLI first:

```bash
curl -fsSL https://raw.githubusercontent.com/deepcoinapi/agent-cli/main/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
dcli --version
dcli list-tools
```

Alternative source install when Go is available:

```bash
go install github.com/deepcoinapi/agent-cli/cmd/dcli@latest
```

Or from a local checkout:

```bash
cd /path/to/agent-cli
go build -o dcli .
```

## Environment

The CLI reads credentials from environment variables. Prefer the `DEEPCOIN_*` names; `DC_*` aliases are supported for compatibility.

| Purpose | Preferred | Alias |
|---|---|---|
| API key | `DEEPCOIN_API_KEY` | `DC_API_KEY` |
| Secret key | `DEEPCOIN_SECRET_KEY` | `DC_SECRET_KEY` |
| Passphrase | `DEEPCOIN_PASSPHRASE` | `DC_PASSPHRASE` |
| Base URL | `DEEPCOIN_BASE_URL` | `DC_BASE_URL` |

Never ask the user to paste credentials into chat. Ask them to configure environment variables or a local shell profile.

## Hard Rule

Do not create ad hoc Python, JavaScript, shell, curl-signing, or multi-step request scripts to call Deepcoin APIs.

Allowed execution forms:

- `dcli ...` commands listed in the skill references
- simple shell wrappers around one CLI command, such as setting environment variables or piping `--json` output to `jq`
- reading a user-provided JSON file for flags that explicitly support `@file`, such as strategy DSL files

If the needed API is not available as a CLI command, stop and report the missing command instead of improvising a custom API client.
