<!--
Sync Impact Report
- Version change: 1.1.0 -> 1.2.0
- Modified principles:
  - I. Specification-Driven Delivery (SDD) -> I. Specification-Driven Delivery (SDD)
  - II. Upgrade Safety and Mandatory Rollback -> II. Upgrade Safety and Mandatory Rollback
  - III. Compatibility and Data Integrity Gates -> III. Compatibility and Data Integrity Gates
  - IV. Risk-Based Validation Evidence -> IV. Metric-Based Validation Evidence
  - V. End-to-End Traceability and Incremental Documentation -> V. End-to-End Traceability and Incremental Documentation
- Added sections:
  - Execution Model and Rollout Waves
- Removed sections:
  - None
- Templates requiring updates:
  - ✅ updated: .specify/templates/plan-template.md
  - ✅ updated: .specify/templates/spec-template.md
  - ✅ updated: .specify/templates/tasks-template.md
  - ✅ updated: README.md
  - ✅ not applicable (folder absent): .specify/templates/commands/*.md
- Deferred placeholders/TODOs:
  - None
-->
<!-- Gerado por scaffold.py 2026-03-05 | Domínio: infrastructure | Linguagem: python -->
# Enterprise Update Lab N8N Constitution

## Core Principles

### I. Specification-Driven Delivery (SDD)

All planning and implementation decisions MUST trace back to explicit requirements in
`docs/objetivo.yaml`, `docs/mcp-questions.yaml`, and feature artifacts under
`specs/`. Work without requirement mapping is non-compliant. Rationale: SDD reduces
rework, prevents scope drift, and keeps technical execution auditable.

### II. Upgrade Safety and Mandatory Rollback

Any n8n upgrade activity MUST define backup, rollback triggers, and recovery steps
before execution. Irreversible changes without validated rollback are forbidden.
Upgrade progression from 2.6.4 to latest MUST be performed version-by-version,
without skipping intermediate versions unless an explicit upstream compatibility
guarantee is documented and approved by architecture and testing gates.
Resolution of latest MUST prioritize official n8n release tags, using official
release notes only as explicit fallback with recorded source URL, timestamp,
and resolved version.
Image pull operations MUST use bounded retry with timeout and MUST block deploy
when local digest validation fails. Recreate/deploy without validated local image
availability is forbidden.
Rationale: upgrade failure must not compromise service continuity or recoverability.

### III. Compatibility and Data Integrity Gates

Promotion between phases or environments MUST pass compatibility checks covering
image/runtime, volumes, database, credentials, queues, and critical workflows.
Data integrity and credential continuity are non-negotiable gates. Rationale:
technical success is invalid if integrations or persistent data are degraded.

### IV. Metric-Based Validation Evidence

Release decisions MUST be supported by reproducible evidence: pre-check outputs,
functional validation of critical workflows, post-check metrics, and explicit
go/no-go results. Each checkpoint MUST evaluate a 15-minute validation window with
all mandatory thresholds met: 100% critical workflow pass, critical errors equal
to 0, p95 regression less than or equal to 10%, and throughput greater than or
equal to 90% of baseline. Missing or incomplete evidence MUST force NO-GO.
Rationale: objective thresholds reduce ambiguous decisions and false confidence.

### V. End-to-End Traceability and Incremental Documentation

All significant changes MUST maintain traceability from specification to task to
execution evidence and MUST update documentation incrementally (never destructive
rewrite of historical records). Rationale: traceability enables accountability,
auditability, and reliable session recovery.

## Operational Constraints and Security Baseline

- The canonical validation environment is `wfdb01:/opt/docker_user/n8n`.
- Sensitive connection material MUST remain outside versioned artifacts and use
  `.secrets/` with environment-variable indirection where applicable.
- MCP usage MUST follow the documented flow:
  `objetivo.yaml -> Copilot -> mcp-questions.yaml -> MCP`.
- The required execution model is hybrid: Ansible executes idempotent remote
  operations and rollback, while Python controls version planning, gate decisions,
  and evidence/report generation.

## Execution Model and Rollout Waves

- Upgrade automation MUST execute per checkpoint state machine:
  `PRECHECK -> BACKUP -> PULL -> DEPLOY -> VALIDATE -> GATE`.
- Rollout governance MUST follow waves in this order:
  1. Onda 0 (governance and baseline)
  2. Onda 1 (automation base)
  3. Onda 2 (version-by-version in homolog)
  4. Onda 3 (controlled production canary)
  5. Onda 4 (scale and operational handoff)
- Promotion between waves MUST require explicit GO approval based on checkpoint
  evidence and rollback readiness from the previous wave.

## Workflow, Roles, and Approval Gates

- Lifecycle execution MUST follow Speckit phases in order:
  `constitution -> plan -> tasks -> implement`.
- Each phase MUST declare objective gate criteria and approval ownership.
- `system_architect` approves architecture and rollback readiness.
- `n8n_specialist` approves compatibility and workflow behavior gates.
- `test_engineer` approves test evidence and regression/performance gates.
- `project_manager` approves milestone/go-no-go progression and risk posture.
- `devops_engineer` and `devops_automation` ensure SDD traceability and
  reproducible execution artifacts.

## Governance

This constitution supersedes informal process conventions for the upgrade program.
Amendments require: (1) documented rationale, (2) template impact assessment,
(3) updates to affected artifacts, and (4) date/version update in this file.

Versioning policy (semantic):

- MAJOR: incompatible governance changes or principle removals/redefinitions.
- MINOR: new principle/section or materially expanded mandatory guidance.
- PATCH: clarifications, wording improvements, and typo-level updates.

Compliance review expectations:

- Every planning cycle MUST pass Constitution Check gates in `plan.md`.
- Every task set MUST include traceability, rollback, and validation evidence tasks.
- Every intermediate version step MUST have checkpoint evidence before advancing.
- Reviews MUST reject changes that violate non-negotiable principles.

**Version**: 1.2.0 | **Ratified**: 2026-03-20 | **Last Amended**: 2026-03-24
