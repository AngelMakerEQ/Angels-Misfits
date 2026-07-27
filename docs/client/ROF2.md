# Rain of Fear 2 Client (RoF2)

## What It Is

RoF2 ("Rain of Fear 2") is an EverQuest client build from 2013, one of only five client versions EQEmu servers support at all: Titanium, Secrets of Faydwer (SoF), Seeds of Destruction (SoD), Underfoot (UF), and RoF2. No other client version — including Trilogy, Platinum, or Anniversary editions — is compatible with an EQEmu server, regardless of how it's configured.

## Why RoF2 Specifically

**Very Vanilla MQ (VV MQ) exclusively supports the RoF2 client.** This is the deciding factor for Angels Misfits, not RoF2's visual presentation — VV MQ is a supported, player-facing project requirement (see `docs/compatibility/VV_MQ.md`), and no other EQEmu-compatible client version has VV MQ support at all.

## Comparison to Other EQEmu-Compatible Clients

| Client | Era Represented | Pros | Cons |
|---|---|---|---|
| **Titanium** | Closest to true Classic/Kunark/Velious visuals | Best raw visual match to the target era | Has real unresolved bugs (e.g., missing NO DROP trade opcode, a swapped female/neuter Qeynos Citizen model); no VV MQ support |
| **SoF / SoD / UF** | Progressively later, closer to RoF2 | Each somewhat closer to Velious than RoF2 visually | Still no VV MQ support; each still requires the same category of zone/model restoration work as RoF2, for less compatibility benefit |
| **RoF2 (current choice)** | Luclin+ by default | VV MQ support; strongest EQEmu ecosystem/tooling compatibility | Requires the most restoration work to approximate classic visuals (see `docs/architecture/CLIENT_ARCHITECTURE.md`) |

## Other Classic-Focused Projects (Not Directly Comparable)

TAKP, Project 1999, and Project Quarm are separate emulator projects, each running their own specific client build tied to their own server codebase — not a generic client choice interchangeable with the five EQEmu-supported versions above. Any of these would very plausibly reach a more classic-accurate state with less restoration effort than RoF2 requires, **but this has not been researched in detail** — specifically, whether their client builds could function against a different (non-their-own) EQEmu server is unconfirmed. If VV MQ support is ever dropped as a project requirement, or extended to another client, this is the comparison worth revisiting first.

## Known Issues (Current)

- Spell icon mismatch (magic-resist buff showing a cold/snowflake icon) — root cause not yet isolated.
- Loading screens display RoF2-era art rather than Classic/Kunark/Velious art — restoration method not yet researched.

## History

Full reasoning and testing timeline for client selection and all modifications: **ADR-008**.
