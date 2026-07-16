# ADR-0003: Clean core with provider plugins as packages, boundary-linted

- **Status:** Accepted
- **Date:** 2026-07-16

## Context

Requirement: new streaming providers must be addable without modifying
existing business logic, and no provider-specific logic may exist outside
provider adapters.

## Options considered

Monolith with per-feature folders; clean/hexagonal core with plugins as
workspace packages; runtime micro-kernel with dynamically loaded plugins —
compared in [docs/04 §1](../04-architecture.md#1-architectural-approach--options-considered).

## Decision

Clean core + one package per provider, with the dependency rule enforced
mechanically: `boundaries.yaml` at the repo root declares each package's
allowed internal dependencies, and `repo_tools:check_boundaries` fails CI on
any violation (declared *or* merely imported), including any Flutter
dependency inside a pure-Dart engine package. Runtime plugin loading was
rejected — Dart has no sanctioned dynamic code loading on iOS, and a
compile-time registry gives the same modularity without the risk.

## Consequences

Adding a provider = new package + one registry line in the app shell.
Violating the architecture is a red build, not a review comment. The rules
file must be updated deliberately whenever a new package kind is introduced.
