# ADR-0004: Pub workspace + melos for monorepo tooling

- **Status:** Accepted
- **Date:** 2026-07-16

## Context

The monorepo (docs/04 §6) needs shared dependency resolution, cross-package
scripts, and later, versioning automation.

## Options considered

1. Plain pub workspace + shell scripts — native resolution but no task
   runner, no package filtering, versioning left to hand-rolled scripts.
2. Melos 6 classic mode — proven, but maintains its own linking model that
   pub now provides natively; superseded upstream.
3. **Pub workspace (Dart ≥3.5 native) + melos 7 on top** — one root lockfile,
   atomic cross-package resolution from pub itself; melos adds script
   running, package filters, and versioning.

## Decision

Option 3. Packages opt in with `resolution: workspace`; melos is a root dev
dependency (`dart run melos <script>`).

## Consequences

Single lockfile at the root (committed); every package must list itself in
the root `workspace:`; CI can run plain `dart` commands without melos being
globally installed.
