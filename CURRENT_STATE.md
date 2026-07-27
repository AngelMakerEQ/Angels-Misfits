# Angels Misfits - Current State

## Overview

Angels Misfits is an operational local EverQuest Emulator server running on a Windows environment. The server has moved beyond a stock PEQ baseline — substantial database corrections and client-side visual restoration have been implemented and documented via the project's ADR series.

---

# Current Environment

## Server Platform

Current server environment:

- Local Windows installation
- EQEmu Windows Installer v23.10.3 (Akk Stack Docker)
- MariaDB database
- HeidiSQL database management
- Spire server management and configuration workflows
- Rain of Fear 2 (RoF2) client, base client sourced from AddictedDads' "RoF2_Full.zip" (used as a pristine base only; see ADR-008)
- EQEmu MCP — connected and in active use for direct database inspection and modification

## Database State

Current database:

- Originally imported as a pure PEQ database (Sept 2025 dump); has since undergone substantial, documented correction toward classic/Velious-era accuracy.

Applied corrections to date (see `docs/decisions/` for full detail):

- Content scope restricted to Velious-and-earlier (ADR-001).
- Server rules baseline corrected against PEQ/TAKP comparison, including level cap correction to 60 (ADR-002).
- NPC combat stats retuned — HP, damage, AC, resists, regen, aggro radius (ADR-003).
- Spell mechanics fully replaced with verified classic-era data (ADR-004).
- Pet NPC stats retuned (ADR-005).
- Starting item kit corrected (ADR-006).
- NPC model race data corrected — skeleton family (ADR-007).

Remaining known-stock areas:

- Item and spell-level expansion scoping is deferred and ongoing (per ADR-001), handled incrementally rather than as a single migration.
- Broader itemization and quest content not yet reviewed.

---

# Current Server Architecture

See `docs/architecture/SERVER_ARCHITECTURE.md` for the current architecture overview.

## Client Layer

### Rain of Fear 2 (RoF2)

Client-side classic visual restoration is underway per ADR-008: Luclin player models disabled (individual per-race settings), classic zone files applied (FV Project source), spell icons/gems/effects and skeleton models updated, and TaipoUI selected as the current UI. Known open items include a spell icon mismatch, loading screen restoration, and a deferred verification pass — see ADR-008 for full detail.
