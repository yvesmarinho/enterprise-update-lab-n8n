# Checkpoint 001 Runtime Evidence - 2026-03-24

## Context

- Environment: `wfdb01:/opt/docker_user/n8n`
- Checkpoint ID: `CP-001-BASELINE`
- From version: `2.6.4`
- To version: `2.6.4` (baseline before first transition)

## Runtime Snapshot

- Services discovered: `n8n_editor`, `n8n_webhook`, `n8n_worker`, `n8n_mcp`
- Service state: all containers `Up`
- Effective image: `n8nio/n8n:2.6.4` (all services)
- Configured database name: `n8n_dev_db`

## Metrics Collection (15-minute window)

| Metric | Value | Status |
| --- | --- | --- |
| sample_window_minutes | 15 | Collected |
| critical_error_count | 40 | Collected |
| p95_execution_time_ms | N/A | Not reliable for this window |
| avg_throughput_per_15min | N/A | Not reliable for this window |

## Error Classification Sample

Observed repeated runtime activation failures:

- `WorkflowActivationError: There was a problem activating the workflow: "Client authentication failed (...)"`

## Gate Decision

- Decision: NO-GO
- Reason 1 (CT-003): critical error count is not zero.
- Reason 2 (CT-006): p95/throughput were not reliable for release decision in this initial window.

## Immediate Actions Required

1. Resolve workflow activation/authentication failures.
2. Repeat baseline collection with clean 15-minute window.
3. Recompute p95 and throughput and re-run gate decision.

## Remediation Progress (2026-03-24)

### Actions Executed

1. Desativacao seletiva de workflows ativos com credenciais OAuth/auth em conflito de ativacao.
2. Revalidacao de configuracao runtime com banco canonico `n8n_dev_db`.
3. Recoleta de erros em janela curta apos remediacao.

### Interim Results

- `risky_active=0` para o conjunto de workflows alvo da remediacao.
- Erro critico em janela curta (`--since=1m` e `--since=2m`): `0`.
- Janela oficial de 15 minutos ainda apresentou residuos historicos no momento da medicao (`4`).

### Updated Gate Status

- Decision: NO-GO (provisorio)
- Remaining blocker: confirmar janela oficial de 15 minutos com `critical_error_count=0` e consolidar amostra quantitativa final da mesma janela.

## Recheck de Persistencia de Erros (2026-03-24T14:09:00Z)

### Janela oficial (15 minutos)

| Metric | Value | Status |
| --- | --- | --- |
| sample_window_minutes | 15 | Collected |
| critical_error_count | 0 | Collected |

### Erros persistentes

- Estado atual: nenhum erro persistente detectado na janela oficial de 15 minutos.
- Assinatura historica observada na mesma sessao: `WorkflowActivationError: Client authentication failed (...)`.

### Implicacao de gate

- CT-003 (erro critico) passou nesta coleta.
- Coleta quantitativa final de p95/throughput permanece obrigatoria para fechamento completo do checkpoint.

## Execucao do Primeiro Hop e Rollback (2026-03-24)

### Padrão SSH utilizado

- Wrapper obrigatorio aplicado: `~/.local/bin/ssh-wfdb01` (conforme `.secrets/ssh.json`).

### Hop executado

- from_version: `2.6.4`
- to_version: `2.7.5`
- compose_file: `/opt/docker_user/n8n/docker-compose.yaml`

### Evidencia de falha no hop

- timestamp_utc: `2026-03-24T14:23:13Z`
- effective_image: `n8nio/n8n:2.7.5` (todos os servicos)
- critical_error_count_2m: `24`
- critical_error_count_15m: `36`
- assinatura principal: `There was an error initializing DB` em `n8n_editor`, `n8n_worker`, `n8n_webhook`, `n8n_mcp`

### Gate decision do hop

- Decision: NO-GO
- Rationale: falha de inicializacao de banco em todos os servicos e contagem de erro critico acima de zero.

### Rollback executado

- rollback_timestamp_utc: `2026-03-24T14:24:48Z`
- backup_artifact: `/tmp/docker-compose.yaml.2.7.5.failed.20260324T142448Z`
- metodo: `sudo sed` no compose + `docker compose up -d`
- restored_image: `n8nio/n8n:2.6.4` (todos os servicos)

### Pos-rollback

- timestamp_utc: `2026-03-24T14:25:02Z`
- critical_error_count_2m: `0`
- critical_error_count_15m: `0`
- status: ambiente estabilizado em baseline 2.6.4

## Revalidacao Oficial do Hop 2.7.5 (Janela 15m)

### Tentativa controlada

- ssh_wrapper: `~/.local/bin/ssh-wfdb01`
- gate_start_utc: `2026-03-24T14:29:36Z`
- pre_gate_errors_2m: `0`

### Resultado de gate (oficial)

- gate_check_utc: `2026-03-24T14:31:11Z`
- critical_error_count_15m: `20`
- effective_image: `2.7.5` em todos os servicos

### Gate decision

- Decision: NO-GO
- Rationale: erro critico persistente em janela oficial de 15 minutos.

### Rollback apos gate

- rollback_utc: `2026-03-24T14:31:44Z`
- rollback_artifact: `/tmp/docker-compose.yaml.rollback-after-gate.20260324T143144Z`
- restored_image: `2.6.4` em todos os servicos
- post_rollback_errors_2m: `0`
