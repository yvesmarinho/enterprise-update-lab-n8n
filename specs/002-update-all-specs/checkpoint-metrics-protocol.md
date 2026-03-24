# Checkpoint Metrics Protocol - 002-update-all-specs

## Purpose

Definir o protocolo operacional de coleta e validacao das metricas obrigatorias dos checkpoints para atender CT-002, CT-003, CT-005 e CT-006.

## Scope

- Ambiente: `wfdb01:/opt/docker_user/n8n`
- Escopo funcional: mesmos workflows criticos definidos para a rodada
- Janela de medicao: 15 minutos por ciclo de coleta

## Mandatory Baseline Procedure (CT-005)

- Coletar baseline antes da primeira transicao de versao da rodada.
- Executar a mesma bateria de workflows criticos usada nos checkpoints subsequentes.
- Registrar timestamp, versao de origem, hash/referencia do pacote e responsavel pela coleta.

### Baseline Record Template

| Field | Value |
| --- | --- |
| baseline_timestamp | |
| from_version | |
| workload_profile | |
| environment | `wfdb01:/opt/docker_user/n8n` |
| sample_window_minutes | 15 |
| p95_execution_time_ms | |
| avg_throughput_per_15min | |
| critical_error_count | |
| evidence_artifact | |

## Checkpoint Metrics (CT-006)

Para cada checkpoint, registrar obrigatoriamente:

- p95 de tempo de execucao dos workflows criticos
- throughput medio por janela de 15 minutos
- contagem de erros criticos

### Checkpoint Record Template

| Field | Value |
| --- | --- |
| checkpoint_id | |
| from_version | |
| to_version | |
| measurement_timestamp | |
| sample_window_minutes | 15 |
| p95_execution_time_ms | |
| avg_throughput_per_15min | |
| critical_error_count | |
| evidence_artifact | |

## Gate Decision Thresholds

- CT-002: regressao de desempenho <= 10% versus baseline
- CT-003: erros criticos = 0 para decisao GO
- CT-005: baseline valido deve existir antes da primeira transicao
- CT-006: p95 e throughput por 15 minutos devem estar preenchidos

## Decision Rule

- GO: todos os thresholds obrigatorios atendidos e evidencias completas
- NO-GO: qualquer threshold violado ou evidencia incompleta

## Traceability

- CT-002, CT-003, CT-005, CT-006
- OSR-004
- SC-005
