# ADR-0005: Hand-written immutable domain models in the core (defer freezed)

- **Status:** Accepted
- **Date:** 2026-07-16

## Context

docs/03 lists freezed in the stack. `core_domain` is the most-depended-upon
package in the workspace; anything it adopts, everything inherits.

## Options considered

1. freezed now — less boilerplate, but drags build_runner + generated files
   into the leaf package every other package depends on, slowing every
   downstream test cycle from day one.
2. **Hand-written immutable classes with explicit `==`/`hashCode`
   (package:collection for deep equality), sealed classes for unions,
   extension types for ids** — more boilerplate, zero codegen, and the
   boilerplate is itself under test.
3. Records/typedefs only — no nominal types, loses exhaustive switching and
   doc anchoring.

## Decision

Option 2 for `core_domain`. freezed remains approved (docs/03) for
data-transfer objects in provider plugins and `data_local`, where JSON codecs
make codegen genuinely pay for itself.

## Consequences

Entity additions require writing equality by hand (tests cover it); the core
stays codegen-free and instant to test. Revisit only if the entity count
makes the boilerplate a measurable tax.
