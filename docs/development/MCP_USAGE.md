# EQEmu MCP Usage

## Overview

Angels Misfits uses the **EQEmu MCP server** (`straps-eq/eqemu-mcp-server`) as
an external development interface. When connected, it gives an AI assistant
(Claude Desktop, in this project's case) direct read access to:

- The live Angels Misfits MariaDB database
- The EQEmu C++ source tree (if available locally)
- Quest script files
- EQEmu's official documentation (docs.eqemu.io), searchable

This lets the assistant verify actual server state, look up real data, and
read engine source directly instead of relying on assumptions or memory —
consistent with this project's "verify via MCP before assuming" principle
(see SERVER_ARCHITECTURE.md).

This is a small, independent community project, not an official EQEmu or
Anthropic tool. It is a locally-run Python script that must be installed and
configured per machine; it does not come bundled with the EQEmu Windows
Installer.

---

## Important: This Project Uses the Windows Installer, Not Akk-Stack/Docker

The MCP server's own documentation is written primarily with a Dockerized
"akk-stack" Linux setup in mind. Angels Misfits instead uses the
**EQEmu Windows Installer**, a non-Docker layout. The manual/no-Docker
installation path applies, with some Windows-specific adjustments noted
below. Several early setup issues traced directly back to this mismatch —
documented here so they aren't rediscovered from scratch.

---

## Prerequisites

- **Python 3.10+** — with "Add to PATH" checked during install.
- **Git for Windows** — to clone the MCP server repository.
- **(Optional) ripgrep** — powers fast source-code search
  (`winget install BurntSushi.ripgrep.MSVC`). Without it, the source-search
  tools still work but are noticeably slower.

---

## Installation Steps

Run each line individually in PowerShell (pasting multiple commands as one
block can cause them to be parsed as a single command with ambiguous
parameters):

```powershell
cd <path to your EQEmu server folder>
git clone https://github.com/straps-eq/eqemu-mcp-server.git
cd eqemu-mcp-server
python -m venv venv
venv\Scripts\activate
pip install -e .
```

### Known issue: `Activate.ps1 cannot be loaded` (script execution disabled)

Windows blocks PowerShell script execution by default. Two options:

- Allow scripts for your user account only (recommended):
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Or skip activation entirely and call the venv's `pip`/`python` directly:
  ```powershell
  venv\Scripts\pip.exe install -e .
  ```
  This works fine long-term, since the Claude Desktop config (below) points
  directly at `venv\Scripts\python.exe` regardless of whether the venv was
  ever "activated" in a shell.

---

## Locating Database Credentials

The Windows Installer generates **two different credential sets** in two
different files. Using the wrong one is a common failure point:

| File | Contains | Use for MCP? |
|---|---|---|
| `install_config.yml` (repo root) | The **live world/game database** credentials (`mysql_username`, `mysql_password`, `mysql_database_name`, `mysql_host`, `mysql_port`) | **Yes — use these** |
| `eqemu_config.json` → `qsdatabase` block | The **query server** (logging) database credentials, with `host` set to `mariadb` — a Docker-network hostname that does not resolve on a non-Docker Windows install | **No — do not use this block** |

Confirm the actual live database name too — it will likely **not** be the
generic default (`peq`); check `mysql_database_name` in `install_config.yml`.

---

## Claude Desktop Configuration

Claude Desktop connects to local MCP servers via `stdio`, not the SSE mode
described for Docker/Linux setups in the MCP server's own README.

Config file location: `%APPDATA%\Claude\claude_desktop_config.json`
(easiest way to open it: Claude Desktop → Settings → Developer → **Edit Config**).

Note: this is under `AppData\Roaming\Claude`, **not**
`AppData\Local\AnthropicClaude` — the latter is just the application's
install directory and contains no config files.

Example structure (replace bracketed values with your own — do not commit
real credentials to this public repo):

```json
{
  "mcpServers": {
    "eqemu": {
      "command": "<path>\\eqemu-mcp-server\\venv\\Scripts\\python.exe",
      "args": ["<path>\\eqemu-mcp-server\\server.py"],
      "env": {
        "EQEMU_SOURCE_PATH": "<path to EQEmu C++ source tree, if present>",
        "EQEMU_QUESTS_PATH": "<path to server>\\quests",
        "EQEMU_SERVER_PATH": "<path to server>",
        "EQEMU_DB_HOST": "127.0.0.1",
        "EQEMU_DB_PORT": "3306",
        "EQEMU_DB_USER": "<from install_config.yml>",
        "EQEMU_DB_PASSWORD": "<from install_config.yml>",
        "EQEMU_DB_NAME": "<from install_config.yml, e.g. angelsmisfits>",
        "EQEMU_ACCESS_MODE": "read"
      }
    }
  }
}
```

Notes on specific fields:

- **`EQEMU_ACCESS_MODE`**: start with `read`. Only the database's `SELECT` /
  `SHOW` / `DESCRIBE` / `EXPLAIN` operations are permitted in this mode —
  matches this project's preference for validated, reversible changes
  before anything is applied live.
- **`EQEMU_SOURCE_PATH`**: only relevant if a full EQEmu C++ source checkout
  exists locally (separate from the compiled server binaries the Windows
  Installer ships). If present, this enables source-code search/read tools
  in addition to the database tools.
- Config changes require a **full quit and reopen** of Claude Desktop
  (system tray → Quit, not just closing the window) to take effect — the
  MCP server subprocess is only spawned once at startup and does not
  hot-reload the config.

### Known issue: JSON parse error after editing the config

If Claude Desktop reports something like *"Unexpected non-whitespace
character after JSON at position ..."*, the file likely has leftover content
before or after the pasted block (e.g. a stray default `{}` Claude Desktop
pre-populated). Select all, delete, and paste in only the intended JSON —
nothing else in the file.

---

## Verifying the Connection

Once reconnected, test with a simple read query, e.g. asking the assistant
to list database tables or look up a known NPC's loot table. A successful
response returning real data (actual table names, actual items) confirms
the full chain — Claude Desktop → Python MCP server → MariaDB — is working.

---

## Available Tool Categories

- **Database** — read-only SQL queries and schema browsing against the live
  Angels Misfits database.
- **C++ source** — search, list, and read files from the EQEmu server source
  tree (only if `EQEMU_SOURCE_PATH` is configured and points to a real
  checkout of the EQEmu `Server` repository).
- **Documentation** — full-text search against docs.eqemu.io.
- **Quest scripts** — read access to the configured quests directory.

---

## Known Limitations / Open Issues

- Some individual tools (e.g. full NPC loot-chain lookups) have been
  observed to occasionally time out without completing. If this happens,
  retrying once, or falling back to an equivalent direct read-only SQL
  query (e.g. joining `npc_types` → `loottable` → `loottable_entries` →
  `lootdrop_entries` → `items`), is a reasonable workaround. A full
  quit/reopen of Claude Desktop restarts the underlying process if a tool
  call appears permanently stuck.
- This MCP connection is local to whichever machine runs Claude Desktop with
  this config. It is not available in claude.ai or the mobile app, and is
  not shared across separate Claude Desktop conversations' tool state
  automatically — each session loads tools as needed.

---

## Security Note

Do not commit real database credentials, Spire admin credentials, or local
file paths containing personal usernames to this repository, since it is
public. Use placeholder values in documentation (as above) and keep actual
secrets only in local, untracked config files.
