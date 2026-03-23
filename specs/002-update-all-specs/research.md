# Phase 0 Research - Atualizacao Global das Especificacoes

## Decision 1: Politica de update sequencial versao a versao

- Decision: Executar upgrade do n8n de forma sequencial por versoes intermediarias,
  sem salto, desde 2.6.4 ate versao-alvo congelada.
- Rationale: Reduz risco de quebra de compatibilidade acumulada e facilita
  diagnostico/rollback por checkpoint.
- Alternatives considered:
  - Salto direto para latest: rejeitado por alto risco de regressao e menor
    previsibilidade de recuperacao.
  - Pular apenas versoes menores: rejeitado por ambiguidade operacional.

## Decision 2: Tratamento do alvo latest

- Decision: Resolver latest durante planejamento, congelar alvo para a rodada,
  e alterar apenas via change-control aprovado.
- Decision detail: A resolucao de latest deve usar fonte canonica oficial
  com precedencia definida: (1) tags oficiais de release do n8n,
  (2) release notes oficiais (fallback), com registro de URL da fonte,
  timestamp de consulta e versao resolvida.
- Rationale: Evita drift de escopo durante execucao e preserva auditabilidade.
- Alternatives considered:
  - Recalcular latest em cada etapa: rejeitado por instabilidade de escopo.
  - Definir alvo manual fixo sem resolver latest: rejeitado por reduzir
    alinhamento com objetivo de chegar na ultima disponivel.

## Decision 3: Checkpoints obrigatorios por versao

- Decision: Exigir pre-check, validacao funcional, validacao de desempenho,
  decisao go/no-go e pos-check para cada versao intermediaria.
- Rationale: Mantem controle de risco continuo e evidencia objetiva de qualidade.
- Alternatives considered:
  - Validacao apenas no inicio e fim: rejeitado por nao detectar regressao por etapa.

## Decision 5: Baseline e metricas de desempenho por checkpoint

- Decision: Coletar baseline antes da primeira transicao da rodada em
  `wfdb01:/opt/docker_user/n8n`, usando os mesmos workflows criticos da validacao.
- Decision detail: Medir p95 de tempo de execucao e throughput medio em janela
  de 15 minutos por checkpoint, com limite de regressao <= 10%.
- Rationale: Garante comparabilidade objetiva entre checkpoints e reduz ruido de
  medicao por variacao de cenario.
- Alternatives considered:
  - Medicao ad-hoc sem baseline formal: rejeitado por baixa confiabilidade.
  - Medicao com metrica unica: rejeitado por cobertura insuficiente de desempenho.

## Decision 4: Rastreabilidade SDD obrigatoria

- Decision: Mapear requisitos -> tarefas -> evidencias em todos os artefatos
  do fluxo Speckit.
- Rationale: Garante consistencia entre especificacao, planejamento e execucao.
- Alternatives considered:
  - Rastreabilidade parcial por documento: rejeitado por gerar lacunas de governanca.

## Resolution of Clarifications

All planning-time unknowns were resolved for this feature. No open
NEEDS CLARIFICATION items remain.
