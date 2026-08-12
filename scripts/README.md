# Migration Scripts

This directory contains versioned SQL migrations for deliberate live-database
changes. Scripts should follow `docs/development/CODING_STANDARDS.md`: include
a scoped preflight, use a transaction when appropriate, and be verified by an
independent live-database query after application.

The value-level record of changes is `docs/database/PEQ_CHANGES.md`; ADRs own
the reasoning for significant decisions. Never place credentials or local
machine paths in a script.

Once a script has been successfully applied to the live database and
verified, rename it with an `_APPLIED` suffix and move it into `Applied/`.
Scripts sitting directly in this directory (not in `Applied/`) are pending —
generated but not yet run against the live database.
