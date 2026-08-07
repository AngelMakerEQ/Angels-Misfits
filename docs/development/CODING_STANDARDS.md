# Coding Standards

## Purpose

This document records established coding and change-implementation
conventions for Angels Misfits as they emerge from actual project work.

It is intentionally partial. Only conventions that have already been
established through real implementation work are recorded here — this
avoids prescribing rules for work that hasn't started yet (see
Scope Note below).

---

# SQL Migration Convention (Established)

The following pattern has been used consistently across ADR-002 through
ADR-007 and should be treated as the standard approach for any future
database change:

1. **Investigate and document first.** Compare data sources (e.g. PEQ vs.
   client data, P99 wiki, or the TAKP-claimed comparison database —
   treating the latter as an unverified candidate-generating starting
   point, not an authoritative source; see `docs/research/TAKP.md`),
   identify the scope of a change, and write the reasoning and
   decision into an ADR before writing migration SQL.
2. **Generate a migration script rather than hand-run ad hoc statements**
   for any change affecting more than a handful of rows. Hand-written
   one-off statements are acceptable only for genuinely small, simple
   changes (e.g. a handful of rule_values updates).
3. **Apply directly against the live Angels Misfits database via MCP**
   once available, rather than maintaining a separate staging database.
   Earlier ADRs note "implementation pending MCP connection" for exactly
   this reason.
4. **Verify per TESTING.md** immediately after applying — direct
   post-run queries, targeted and random sampling, exclusion checks where
   relevant.
5. **Record implementation status in the ADR**, including the date
   applied, method (migration script vs. direct SQL), and verification
   summary.
6. **Preserve Spire compatibility** — note explicitly in the ADR whether
   the change involved schema modification (it should not, absent a
   strong reason) and confirm the affected table(s) are standard PEQ
   tables Spire already edits directly.

---

# Database Safety

Before any change that modifies or removes existing data:

- Identify affected tables explicitly in the ADR.
- Recommend a database backup before applying, per the project system
  prompt's Database Safety requirements.
- Describe a practical rollback method where possible (e.g. restoring
  from the pre-migration snapshot, or re-running an inverse migration for
  simple value changes).

---

# Scope Note

This document does not yet cover:

- **Lua/Perl quest scripting conventions** — no quest scripting has
  started (Phase 5 work per ROADMAP.md). Standards here would be
  premature and should be written once real quest-script patterns exist
  to document, not speculated in advance.
- **C++ engine modification conventions** — out of scope unless/until the
  project undertakes engine-level changes, which DESIGN_PHILOSOPHY.md
  treats as a last resort after database, rules, and quest-scripting
  solutions are exhausted.
- **Naming conventions, file organization, or style guides** for future
  custom systems — to be added as those systems are actually built.

This document should be expanded incrementally as each of these areas
becomes active work, following the same principle applied here: document
real, established practice rather than anticipated rules.
