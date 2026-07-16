# ADR-0002: Drift/SQLite as the local persistence layer

- **Status:** Accepted
- **Date:** 2026-07-16

## Context

Local-first operational store: relational job ledger with ACID checkpoints,
reactive queries for live progress UI, six-platform support, 10k+ tracks.

## Options considered

Drift, raw SQLite, Isar, Realm, Hive, Supabase — full comparison in
[docs/03](../03-technology-stack.md#3-database-comparison--decision).

## Decision

Drift over SQLite (native FFI; WASM/OPFS on web). Compile-time-checked SQL,
migrations, stream queries, transactions, isolate safety. Realm is
disqualified by MongoDB's deprecation of its sync/SDK investment; Isar by
stalled maintenance; Hive by lacking queries/transactions; Supabase by the
local-first requirement.

## Consequences

A codegen step in the build; schema evolution is disciplined by versioned
migrations with fixture-DB tests; the job engine's crash-consistency story
reduces to SQLite transactions.
