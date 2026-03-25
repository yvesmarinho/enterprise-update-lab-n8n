# Enterprise Update Lab N8N

Laboratorio para planejar, validar e executar atualizacoes seguras do n8n em ambiente controlado, com foco em compatibilidade, desempenho e rollback.

Dominio: infrastructure
Linguagem principal: python
Automacao complementar: ansible
Criado em: 2026-03-20T18:44:10Z

---

## Visao Geral

Este repositorio implementa uma estrategia de upgrade do n8n orientada por especificacao (SDD), com governanca de risco e rastreabilidade ponta a ponta.

Objetivo operacional:

1. Atualizar o n8n de 2.6.4 ate a versao mais recente disponivel.
2. Executar de forma sequencial, versao a versao, sem salto entre intermediarias.
3. Aplicar gate objetivo de promocao por checkpoint.
4. Preservar rollback seguro e evidencia tecnica de cada decisao GO ou NO-GO.

Ambiente de referencia para validacao:

1. Host: wfdb01
2. Path: /opt/docker_user/n8n

---

## Status Atual (2026-03-25)

1. Baseline valida em runtime 2.6.4 apos rollback controlado.
2. Hop 2.6.4 -> 2.7.5 permanece NO-GO em janela oficial de 15 minutos.
3. Bloqueio principal: erro de inicializacao de banco durante startup do hop 2.7.5.
4. Proxima etapa: investigacao de causa raiz e nova tentativa controlada com pre-check reforcado.

Para trilha diaria, consulte as sessoes em docs/SESSIONS.

---

## Modelo de Execucao

Fluxo de trabalho principal:

1. objetivo.yaml -> Copilot -> mcp-questions.yaml -> MCP automatico
2. Speckit: constitution -> plan -> tasks -> implement

Papeis tecnicos considerados:

1. system_architect
2. n8n_specialist
3. devops_engineer
4. devops_automation
5. project_manager
6. test_engineer

Stack de automacao:

1. Python para planejamento de versoes, gates, relatorios e consolidacao de evidencias.
2. Ansible para operacoes remotas idempotentes, pre-check, rollout e rollback.

---

## Regras Criticas de Upgrade

1. Politica sequencial obrigatoria:
2.6.4 -> ... -> latest, sem pular versoes.
2. Resolucao de latest:
fonte primaria em tags oficiais do n8n, com fallback em release notes oficiais e justificativa.
3. Alvo congelado por rodada:
versao resolvida no planejamento e alterada somente via change-control aprovado.
4. Gate obrigatorio por checkpoint:
somente promove para a proxima versao se criterios de aceite forem atendidos.

---

## Criterios de Gate (Janela Oficial)

Cada checkpoint usa janela de 15 minutos e decisao GO ou NO-GO com base em metricas objetivas.

1. Compatibilidade funcional: 100% dos workflows criticos aprovados.
2. Erro critico: 0 para decisao GO.
3. Desempenho: regressao p95 <= 10% versus baseline.
4. Throughput: >= 90% do baseline.
5. Evidencias obrigatorias: pre-check, validacao, pos-check, backup e estrategia de rollback.

---

## Estrutura do Repositorio

1. docs/: documentacao tecnica, runbook, indice e rastreabilidade de sessao.
2. docs/SESSIONS/YYYY-MM-DD/: recovery, atividades, relatorio e status final por dia.
3. specs/001-*/ e specs/002-*/: especificacoes, plano, tarefas, checkpoints e matriz de rastreabilidade.
4. scripts/: scripts de automacao utilitaria.
5. src/: codigo-fonte Python/Ansible do projeto.
6. Makefile: comandos de rotina para desenvolvimento e QA.

---

## Comandos Principais

Executar no diretorio raiz do projeto:

```bash
# Instalar dependencias
make install-deps

# Fluxo de desenvolvimento
make dev

# Build, testes e qualidade
make build
make test
make lint
make format

# Limpeza
make clean

# Carregar variaveis MCP a partir de .secrets/.env
make mcp
```

---

## Documentacao Essencial

1. Indice principal: [docs/INDEX.md](docs/INDEX.md)
2. Backlog e status de tarefas: [docs/TODO.md](docs/TODO.md)
3. Objetivo de alto nivel: [docs/objetivo.yaml](docs/objetivo.yaml)
4. Configuracao MCP derivada: [docs/mcp-questions.yaml](docs/mcp-questions.yaml)
5. Runbook de producao: [docs/RUNBOOK_PRODUCAO_N8N.md](docs/RUNBOOK_PRODUCAO_N8N.md)
6. Especificacao da feature principal: [specs/002-update-all-specs/spec.md](specs/002-update-all-specs/spec.md)
7. Plano de implementacao: [specs/002-update-all-specs/plan.md](specs/002-update-all-specs/plan.md)
8. Tarefas da feature: [specs/002-update-all-specs/tasks.md](specs/002-update-all-specs/tasks.md)
9. Matriz de rastreabilidade: [specs/002-update-all-specs/traceability-matrix.md](specs/002-update-all-specs/traceability-matrix.md)
10. Relatorio final da rodada: [specs/002-update-all-specs/final-summary.md](specs/002-update-all-specs/final-summary.md)

---

## Sessao Atual

Artefatos da sessao de 2026-03-25:

1. Recovery: [docs/SESSIONS/2026-03-25/SESSION_RECOVERY_2026-03-25.md](docs/SESSIONS/2026-03-25/SESSION_RECOVERY_2026-03-25.md)
2. Daily Activities: [docs/SESSIONS/2026-03-25/DAILY_ACTIVITIES_2026-03-25.md](docs/SESSIONS/2026-03-25/DAILY_ACTIVITIES_2026-03-25.md)
3. Session Report: [docs/SESSIONS/2026-03-25/SESSION_REPORT_2026-03-25.md](docs/SESSIONS/2026-03-25/SESSION_REPORT_2026-03-25.md)
4. Final Status: [docs/SESSIONS/2026-03-25/FINAL_STATUS_2026-03-25.md](docs/SESSIONS/2026-03-25/FINAL_STATUS_2026-03-25.md)

---

## Observacoes de Governanca

1. Documentos incrementais devem ser atualizados por append ou ajuste pontual, sem sobrescrever historico.
2. Credenciais nao devem ser versionadas; usar variaveis de ambiente e .secrets.
3. Decisoes operacionais devem manter evidencia verificavel para auditoria tecnica.
