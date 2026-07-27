# Very Vanilla MQ (VV MQ)

## Current Status

VV MQ (RedGuides' precompiled MacroQuest build for emulated servers) is treated as a supported, player-facing component of Angels Misfits. Group content is expected to be handled through VV MQ multiboxing rather than server-side bot systems (see `docs/database/PEQ_CHANGES.md` — bot rules explicitly rejected).

## Why This Document Matters More Than Its Size Suggests

**VV MQ compatibility is the sole reason RoF2 remains the target client**, despite TAKP, P1999, or a Quarm-era client build being a more direct, better-documented, and more easily achievable path to a genuinely classic visual/mechanical state. Those clients would require substantially less restoration work (many of the client-side workarounds in ADR-008 — zone file reversion, spell asset swaps, model toggles — exist specifically because RoF2 is a Luclin+ client being pulled backward). RoF2 was kept as the target anyway because it is the client VV MQ supports for emulated servers. If VV MQ ever adds support for an older client build, or if this project's priorities shift away from treating MQ as a supported player feature, this is the decision that would need to be revisited first — it is upstream of nearly every other client-side tradeoff documented in ADR-008.

## Compatibility Requirement

**Any custom UI candidate must be checked for VV MQ compatibility — particularly target/info windows — before adoption.** This is now a standing requirement, following the Defiance UI evaluation (see `docs/client/UI.md`), where a UI's target window broke VV MQ's target-information functionality.

The current UI (TaipoUI) has not surfaced any known VV MQ compatibility issues.

Full history of this finding lives in **ADR-008**.
