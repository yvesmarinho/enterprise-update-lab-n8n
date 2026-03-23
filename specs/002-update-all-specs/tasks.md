# Tasks: Atualizacao Global das Especificacoes

**Input**: Design documents from `/specs/002-update-all-specs/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md
**Tests**: Nao ha tarefa de teste automatizado obrigatoria; validacoes documentais e de consistencia sao obrigatorias.
**Organization**: Tasks grouped by user story for independent implementation and validation.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar base de execucao documental e artefatos de controle.

- [x] T001 Criar registro de execucao da feature em specs/002-update-all-specs/execution-log.md
- [x] T002 Criar matriz inicial de rastreabilidade em specs/002-update-all-specs/traceability-matrix.md
- [x] T003 [P] Criar checklist de governanca da feature em specs/002-update-all-specs/checklists/governance.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Alinhar templates e regras centrais que bloqueiam todas as user stories.

**CRITICAL**: Nenhuma user story deve iniciar antes desta fase.

- [x] T004 Atualizar gates constitucionais de planejamento em .specify/templates/plan-template.md
- [x] T005 [P] Atualizar requisitos operacionais obrigatorios em .specify/templates/spec-template.md
- [x] T006 [P] Atualizar tarefas obrigatorias de compliance em .specify/templates/tasks-template.md
- [x] T007 Consolidar clausulas obrigatorias de governanca em specs/002-update-all-specs/contracts/spec-governance-contract.md
- [x] T008 Registrar regra de alvo congelado e change-control em specs/002-update-all-specs/spec.md
- [x] T031 Definir politica de rollback por checkpoint em specs/002-update-all-specs/rollback-procedure.md
- [x] T032 [P] Definir politica de backup e restore drill por checkpoint em specs/002-update-all-specs/rollback-procedure.md

**Checkpoint**: Templates e contratos base prontos para execucao das historias.

---

## Phase 3: User Story 1 - Padronizar regra de upgrade sequencial (Priority: P1)

**Goal**: Garantir regra explicita de upgrade versao a versao em todos os artefatos nucleares.

**Independent Test**: Revisao cruzada de docs nucleares sem contradicoes sobre estrategia 2.6.4 -> ... -> target congelado.

- [x] T009 [P] [US1] Atualizar descricao e regras de estrategia sequencial em docs/objetivo.yaml
- [x] T010 [P] [US1] Atualizar politica de upgrade e campos de controle em docs/mcp-questions.yaml
- [x] T011 [P] [US1] Atualizar principio de seguranca de upgrade em .specify/memory/constitution.md
- [x] T012 [US1] Atualizar resumo de governanca sequencial em README.md
- [x] T013 [US1] Registrar decisoes de execucao sequencial e alvo congelado em specs/002-update-all-specs/research.md
- [x] T014 [US1] Atualizar checklist de requisitos com validacao da regra sequencial em specs/002-update-all-specs/checklists/requirements.md
- [x] T033 [US1] Registrar fonte canonica de resolucao de latest com timestamp em specs/002-update-all-specs/research.md

**Checkpoint**: Regra version-by-version explicitada e consistente nos artefatos nucleares.

---

## Phase 4: User Story 2 - Alinhar governanca e rastreabilidade (Priority: P2)

**Goal**: Tornar checkpoints por versao intermediaria obrigatorios e auditaveis.

**Independent Test**: Verificar existencia de entidades, clausulas e fluxo quickstart cobrindo checkpoint/evidencia por versao.

- [x] T015 [US2] Refinar entidade UpgradePolicy e regras de validacao em specs/002-update-all-specs/data-model.md
- [x] T016 [P] [US2] Refinar entidade VersionCheckpoint com criterios de go/no-go em specs/002-update-all-specs/data-model.md
- [x] T017 [P] [US2] Refinar entidades EvidenceRecord e ApprovalGate em specs/002-update-all-specs/data-model.md
- [x] T018 [P] [US2] Atualizar fluxo operacional por checkpoint em specs/002-update-all-specs/quickstart.md
- [x] T019 [US2] Completar mapeamento requisito -> evidencia em specs/002-update-all-specs/traceability-matrix.md
- [x] T020 [US2] Atualizar plano com status de gate pre e post design em specs/002-update-all-specs/plan.md
- [x] T034 [US2] Mapear evidencia de rollback por checkpoint em specs/002-update-all-specs/traceability-matrix.md
- [x] T035 [US2] Definir template de registro de rollback drill em specs/002-update-all-specs/validation-report.md

**Checkpoint**: Governanca por checkpoint formalizada com rastreabilidade completa.

---

## Phase 5: User Story 3 - Garantir consistencia entre documentos (Priority: P3)

**Goal**: Eliminar divergencias semanticas entre prompts/agentes e documentos de especificacao.

**Independent Test**: Revisao de consistencia sem conflito entre objetivo, mcp-questions, constituicao, spec e agentes principais.

- [x] T021 [P] [US3] Atualizar politica sequencial no agente de arquitetura em .github/agents/n8n.system-architect.agent.md
- [x] T022 [P] [US3] Atualizar politica sequencial no agente especialista de n8n em .github/agents/n8n.specialist.agent.md
- [x] T023 [P] [US3] Atualizar politica sequencial no agente devops SDD em .github/agents/devops.engineer-sdd.agent.md
- [x] T024 [P] [US3] Atualizar gate de controle sequencial no agente de projeto em .github/agents/project.manager.agent.md
- [x] T025 [P] [US3] Atualizar validacoes por versao no agente de testes em .github/agents/test.engineer.agent.md
- [x] T026 [US3] Registrar resultado de consistencia cruzada em specs/002-update-all-specs/validation-report.md

**Checkpoint**: Artefatos e agentes alinhados semanticamente com a mesma politica de upgrade.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Fechamento documental e prontidao para implementacao.

- [x] T027 [P] Atualizar indice documental com referencias da feature em docs/INDEX.md
- [x] T028 [P] Atualizar backlog com proximos passos de implementacao em docs/TODO.md
- [x] T029 Consolidar resumo final da feature em specs/002-update-all-specs/final-summary.md
- [x] T030 Executar revisao final de completude em specs/002-update-all-specs/checklists/governance.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): sem dependencias
- Foundational (Phase 2): depende da fase Setup e bloqueia todas as user stories
- User Stories (Phase 3-5): dependem da conclusao da fase Foundational
- Polish (Phase 6): depende da conclusao das user stories desejadas

### User Story Dependencies

- US1 (P1): inicia apos Foundational
- US2 (P2): inicia apos Foundational; usa resultados nucleares de US1 para validar governanca
- US3 (P3): inicia apos Foundational; recomenda consumir resultados de US1 e US2 para revisao cruzada final

### Within Each User Story

- Primeiro: atualizar artefatos base da historia
- Depois: consolidar evidencias/rastreabilidade
- Por fim: registrar validacao independente da historia

---

## Parallel Execution Examples

### User Story 1

- T009, T010 e T011 podem rodar em paralelo (arquivos diferentes)
- T012 depende de T009-T011
- T014 depende de T009-T013
- T033 depende de T010 e T013

### User Story 2

- T016, T017 e T018 podem rodar em paralelo
- T019 depende de T015-T018
- T020 depende de T019
- T034 depende de T019 e T031-T032
- T035 depende de T031-T032 e T018

### User Story 3

- T021, T022, T023, T024 e T025 podem rodar em paralelo
- T026 depende de T021-T025

---

## Implementation Strategy

### MVP First (US1)

1. Concluir Setup e Foundational
2. Implementar US1
3. Validar regra sequencial em todos os artefatos nucleares
4. Congelar baseline para avancar

### Incremental Delivery

1. US1: estrategia sequencial explicita
2. US2: governanca e rastreabilidade por checkpoint
3. US3: consistencia final entre docs e agentes
4. Polish: consolidacao e prontidao para implementacao

### Parallel Team Strategy

1. Time A: templates e contratos (Foundational)
2. Time B: documentos nucleares (US1)
3. Time C: agentes e consistencia cruzada (US3) apos baseline de US1
4. Time D: governanca/rastreabilidade (US2) em paralelo controlado
