# Data Model - Atualizacao Global das Especificacoes

## Entity: UpgradePolicy

- Description: Define a estrategia oficial de upgrade do n8n para a rodada.
- Fields:
  - source_version: string (required, expected 2.6.4)
  - resolved_target_version: string (required, resolved during planning)
  - latest_source_primary: string (required; official release tags)
  - latest_source_fallback: string (optional; official release notes)
  - latest_source_url: string (required)
  - latest_resolved_timestamp: datetime (required)
  - upgrade_mode: enum (required; sequential_version_by_version)
  - skip_versions_allowed: boolean (required; expected false)
  - change_control_required_for_target_change: boolean (required; expected true)
- Validation Rules:
  - source_version MUST be lower than resolved_target_version
  - upgrade_mode MUST be sequential_version_by_version
  - skip_versions_allowed MUST be false

## Entity: VersionCheckpoint

- Description: Representa uma etapa intermediaria de validacao entre versoes.
- Fields:
  - from_version: string (required)
  - to_version: string (required)
  - pre_check_status: enum (pending/pass/fail)
  - compatibility_status: enum (pending/pass/fail)
  - performance_status: enum (pending/pass/fail)
  - baseline_collected: boolean (required)
  - p95_execution_time_ms: number (required)
  - throughput_per_15m: number (required)
  - go_no_go_decision: enum (go/no-go)
  - approved_by: list of strings (required)
  - timestamp: datetime (required)
- Validation Rules:
  - to_version MUST be immediate successor of from_version in planned path
  - baseline_collected MUST be true before first transition in round
  - p95_execution_time_ms and throughput_per_15m MUST be present per checkpoint
  - go_no_go_decision MUST be no-go if any status is fail

## Entity: EvidenceRecord

- Description: Evidencias associadas ao checkpoint de versao.
- Fields:
  - checkpoint_id: string (required)
  - pre_check_artifact: string (required)
  - functional_validation_artifact: string (required)
  - performance_validation_artifact: string (required)
  - post_check_artifact: string (required)
  - rollback_drill_artifact: string (required)
  - backup_artifact: string (required)
  - restore_artifact: string (required)
  - trace_links: list of strings (required)
- Validation Rules:
  - All artifact fields MUST be non-empty before gate approval
  - trace_links MUST include requirement-to-task and task-to-evidence references

## Entity: ApprovalGate

- Description: Decisao formal de promocao para a proxima versao.
- Fields:
  - gate_name: string (required)
  - version_scope: string (required)
  - roles_required: list of strings (required)
  - decision: enum (approved/rejected)
  - rationale: string (required)
- Validation Rules:
  - roles_required MUST include architect and test representatives
  - decision approved requires completed EvidenceRecord

## Relationships

- UpgradePolicy 1..* VersionCheckpoint
- VersionCheckpoint 1..1 EvidenceRecord
- VersionCheckpoint 1..1 ApprovalGate
- ApprovalGate depends on EvidenceRecord completeness
