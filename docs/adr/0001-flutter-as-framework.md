# ADR-0001: Flutter as the single cross-platform framework

- **Status:** Accepted
- **Date:** 2026-07-16

## Context

Hard product requirement: one shared codebase on Android, iOS, Windows, macOS,
Linux, and web.

## Options considered

Flutter, React Native, Kotlin Multiplatform, .NET MAUI, Electron, Tauri —
full comparison in [docs/03](../03-technology-stack.md#1-cross-platform-framework-comparison).

## Decision

Flutter. It is the only candidate where all six targets are first-party and
stable from one codebase, one language, one rendering pipeline. MAUI has no
Linux target; RN's desktop story is community forks; KMP's web/Linux-desktop UI
is frontier-risk; Electron/Tauri lack a mature mobile path.

## Consequences

Canvas-rendered web output (acceptable: logged-in tool, no SEO need); small
platform channels required for background execution and tray behavior; Dart
becomes the single team language; engines can be pure Dart and VM-testable.
