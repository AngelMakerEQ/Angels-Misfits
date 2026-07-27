# Testing & Verification Standards

## Purpose

This document defines how changes to Angels Misfits are verified before
they are considered complete. It exists because the same verification
pattern has already been applied independently across ADR-002 through
ADR-007 — this document centralizes that practice as an explicit standard
rather than leaving it implicit and re-explained in every ADR.

Per DESIGN_PHILOSOPHY.md's documentation principle, ADRs should reference
this document ("verified per TESTING.md") rather than restating the method
each time.

---

# Core Principle

**A script exiting without error is not verification.** Every migration,
rule change, or database modification must be confirmed by directly
querying the live database afterward — not inferred from a successful
script run, an expected row count in a log, or the absence of a thrown
exception.

---

# Standard Verification Method

For any change applied to the live Angels Misfits database (via MCP or
direct SQL), verification should include:

## 1. Direct Post-Run Query

After applying a change, query the live database directly to confirm the
new state — not the pre-migration script's own reporting.

## 2. Targeted Checks

Specifically verify the values, rows, or rules the change was intended to
affect. If a migration was supposed to update 1,365 NPCs to a specific
race value, confirm that value directly on at least some of those NPCs.

## 3. Random, Non-Cherry-Picked Sampling

In addition to targeted checks, sample a handful of affected rows at
random — not just rows chosen because they're easy to reason about or
already expected to be correct. Random sampling catches errors that
targeted checks (which tend to check what you expect to be right) can
miss.

## 4. Exclusion Verification

When a change is scoped to deliberately exclude certain rows (e.g. named
NPCs preserved for thematic/identity reasons), explicitly confirm the
excluded rows were *not* affected — not just that the included rows were.
Absence of change matters as much as presence of change.

## 5. Zero-Result Confirmation for Deletions

For row deletions, confirm success by querying for the deleted row IDs and
expecting zero results — not by trusting a "rows affected" count alone.

## 6. Order-Dependent Migrations

When a migration has sequential, order-dependent steps (e.g. one
conversion step must run before another to avoid incorrectly sweeping
newly-converted rows into a later step), explicitly verify the final
state reflects the intended order — not just that all steps individually
ran.

## 7. Anomaly Investigation Before Acceptance

If a verification check produces an unexpected or ambiguous result (e.g. a
blank-rendering value), investigate the root cause (query tool display
quirk vs. actual data issue) before either accepting or flagging it as a
problem. Don't assume an anomaly is either "fine" or "broken" without
checking.

---

# What Does Not Count as Verification

- A migration script completing without a thrown error
- Row-count logs from the script itself, unaccepted by an independent
  query
- Assuming correctness because the same method worked on a previous,
  unrelated migration
- Checking only the rows expected to have changed, without any random
  sampling
- Checking only that included rows changed, without confirming excluded
  rows didn't

---

# Documentation of Verification

Every ADR with an "Implementation Status" section should describe:

- What was checked (targeted rows/rules, random sample size, exclusions)
- The verification method used (direct query via MCP, described above)
- Any anomalies found and how they were resolved

This keeps the verification record auditable independently of trusting
that "it was tested" without specifics.

---

# Scope Note

This document currently covers **database/migration verification**, since
that is the only category of change made so far (Phase 3-adjacent work,
implemented ahead of the phase schedule via early MCP access). It should
be expanded to cover client-side changes (ADR-008-style visual/UI
restoration) and quest-script testing once that work begins in Phase 5.
