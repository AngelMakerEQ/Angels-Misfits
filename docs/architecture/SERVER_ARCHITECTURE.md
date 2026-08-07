# Server Architecture

## Overview

Angels Misfits is an EverQuest Emulator environment composed of multiple connected components.

The final player experience is created through the interaction of:

- EverQuest client
- EQEmu server components
- Database
- Configuration tools
- Development and administration tools

Each component serves a specific role within the overall system.

---

# Client Layer

## Rain of Fear 2 Client (RoF2)

The RoF2 client is the current client target.

It provides:

- Player connection to the server
- Rendering and visual presentation
- UI functionality
- Client-side game systems

RoF2 was selected primarily because of Very Vanilla MQ Emulator compatibility and broader EQEmu ecosystem compatibility.

Titanium-era clients more closely represent the desired historical era but may not provide the same compatibility.

Client-side customization decisions (models, zone files, spell visuals, UI) are tracked separately in **ADR-008: Client-Side Classic Visual Restoration**.

---

# Server Layer

## EQEmu Server Components

EQEmu provides the server framework responsible for:

- Login handling
- World management
- Zone operation
- Gameplay processing
- Client communication

---

# Database Layer

## MariaDB

MariaDB stores the persistent server data, including:

- NPCs
- Zones
- Loot
- Items
- Spawns
- Player data
- Server configuration

The Angels Misfits database is the active working database.

PEQ and the TAKP-claimed comparison database (see `docs/research/TAKP.md`) serve as historical and developmental references.

Detailed database structure, baseline data, and change tracking are maintained in `docs/database/` (see `DATABASE_BASELINE.md`), which is the authoritative source for database-level documentation.

---

# Development and Administration Tools

## EQEmu Windows Installer

The EQEmu Windows Installer is used to install and configure the local EQEmu environment.

---

## Spire

Spire is used as a database management and administration interface where compatible.

Maintaining Spire compatibility is a major project requirement.

---

## EQEmu MCP

EQEmu MCP is an external development interface used to inspect and interact with the EQEmu environment.

It is not part of the EQEmu Windows Installer stack.

MCP has been connected and is in active use for direct database inspection and modification — see the ADR series (`docs/decisions/`) for a record of changes applied via MCP. MCP should continue to be used to verify actual server state before making assumptions about implementation, configuration, or database contents.

---

# Architecture Goals

The architecture should prioritize:

- Maintainability
- Documentation
- Compatibility
- Reversible changes
- Clear separation between client, server, and database responsibilities

Architecture, gameplay, and client decisions are documented as ADRs in `docs/decisions/` before becoming permanent systems.
