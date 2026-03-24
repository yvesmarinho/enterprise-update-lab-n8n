# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- SDD Traceability: Every major decision is mapped to explicit requirements from
  spec inputs and project objective artifacts.
- Rollback Safety: Backup, rollback trigger, and recovery path are defined before
  implementation tasks begin.
- Compatibility Coverage: Plan includes checks for runtime/image, storage/DB,
  credentials, queues/integrations, and critical workflows.
- Validation Evidence: Plan defines objective evidence outputs for go/no-go
  decisions (pre-check, post-check, functional and performance validation)
  including 15-minute checkpoint windows and threshold rules.
- Incremental Documentation: Plan defines which docs are updated incrementally
  during execution and how trace links are preserved.
- Hybrid Execution Model: Plan defines Ansible execution scope (idempotent remote
  operations and rollback) and Python scope (version planning, gate engine,
  and evidence/report generation).

Pre-Design Gate Status:

- SDD Traceability: [PASS|FAIL]
- Rollback Safety: [PASS|FAIL]
- Compatibility Coverage: [PASS|FAIL]
- Validation Evidence: [PASS|FAIL]
- Incremental Documentation: [PASS|FAIL]
- Hybrid Execution Model: [PASS|FAIL]

Post-Design Gate Status:

- SDD Traceability: [PASS|FAIL]
- Rollback Safety: [PASS|FAIL]
- Compatibility Coverage: [PASS|FAIL]
- Validation Evidence: [PASS|FAIL]
- Incremental Documentation: [PASS|FAIL]
- Hybrid Execution Model: [PASS|FAIL]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation                  | Why Needed         | Simpler Alternative Rejected Because    |
| -------------------------- | ------------------ | --------------------------------------- |
| [e.g., 4th project]        | [current need]     | [why 3 projects insufficient]           |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient]     |
