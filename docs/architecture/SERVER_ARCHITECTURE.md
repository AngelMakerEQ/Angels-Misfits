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

---

# Server Layer

## EQEmu Server Components

EQEmu provides the server framework responsible for:

- Login handling
- World management
- Zone operation
- Gameplay processing
- Client communication

Specific server component relationships will be documented after environment verification.

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

PEQ and TAKP-derived databases serve as historical and developmental references.

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

EQEmu MCP is an external development interface used to inspect and interact with the EQEmu environment when available.

It is not part of the EQEmu Windows Installer stack.

When connected, MCP should be used to verify actual server state before making assumptions about implementation, configuration, or database contents..

---

# Architecture Goals

The architecture should prioritize:

- Maintainability
- Documentation
- Compatibility
- Reversible changes
- Clear separation between client, server, and database responsibilities

Future architecture decisions should be documented before becoming permanent systems.