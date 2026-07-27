# UI

## Current UI

**TaipoUI** (RoF2-compatible build) is the currently active UI.

## Compatibility Notes

- TaipoUI hides the Marketplace and Krono-related UI elements by default. No further action is needed for this on the UI side.
- **Do not rename or remove `EQUI_MarketplaceWnd.xml`** — this has been confirmed to break client loading entirely. TaipoUI's default handling is the working solution; leave this file as-is.
- Krono itself is a database/item concern, not a UI concern — see `docs/database/` for that thread.

## Other UIs Evaluated, Not in Use

- **DuxasUI** — Titanium-only, no RoF2 port exists. Not usable as a base. Retained as a style reference only (known for classic-style spell gem support).
- **Defiance** — RoF2-compatible, but not currently used. Incompatible with Very Vanilla MQ's target-info window functionality; its own target window also does not resize its image correctly (gets cut off rather than scaling).
- **SARS UI** — a version which shipped bundled with the used RoF2 client (`uifiles\sars\`), but is not the active UI.

## Related

Client-side spell icon/gem visuals are covered under `docs/client/GRAPHICS.md` (or the relevant client doc) since they're a shared FV Project asset source, not TaipoUI-specific.

Full history of UI evaluation and testing lives in **ADR-008**.
