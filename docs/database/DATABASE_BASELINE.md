## Open Items

- ADR-001 content restrictions (zone `expansion <= 2` gating) are
  **decided but not yet implemented**. No database changes have been
  made. Implementation will occur directly against the live Angels
  Misfits database once EQEmu MCP is connected, rather than as a
  standalone SQL migration applied to this reference dump.
- Item/spell/NPC-level expansion scoping not yet implemented — deferred
  per ADR-001, to be handled as Phase 3/5 work proceeds, once zone
  gating is in place.
- TAKP Rebalanced data not yet compared against PEQ baseline values.
- This document is based on the uploaded reference PEQ dump, not a
  live connection to the running Angels Misfits database. Once MCP is
  connected, the live database should be verified against this
  baseline before any restriction work begins, in case Angels Misfits
  has already diverged from a clean PEQ import.