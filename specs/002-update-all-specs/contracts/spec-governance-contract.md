# Contract: Specification Governance and Consistency

## Purpose

Define o contrato minimo para considerar a especificacao apta a seguir para tasks
and implementation.

## Inputs

- docs/objetivo.yaml
- docs/mcp-questions.yaml
- .specify/memory/constitution.md
- specs/002-update-all-specs/spec.md

## Mandatory Clauses

1. Sequential Upgrade Clause

- Strategy MUST be version-by-version from 2.6.4 to resolved target.
- Version skipping MUST be disallowed by default.

1. Frozen Target Clause

- Target derived from latest MUST be resolved during planning.
- Target changes after planning MUST require approved change-control.

1. Latest Resolution Source Clause

- Latest resolution MUST use official n8n release tags as primary source.
- Official release notes MAY be used only as explicit fallback.
- Source URL, timestamp, and resolved version MUST be documented.

1. Checkpoint Evidence Clause

- Every intermediate version transition MUST provide pre-check,
  functional validation, performance validation, post-check, and gate decision.

1. Rollback Drill Clause

- Every intermediate transition MUST include rollback drill evidence
  (controlled rollback or validated simulation) before next promotion.

1. Traceability Clause

- Requirements MUST map to planned tasks and evidence artifacts.

1. Consistency Clause

- Objective, MCP questions, constitution, and feature spec MUST not contradict
  each other regarding upgrade strategy and governance.

## Validation Outcome

A specification package is compliant only when all mandatory clauses are met.
