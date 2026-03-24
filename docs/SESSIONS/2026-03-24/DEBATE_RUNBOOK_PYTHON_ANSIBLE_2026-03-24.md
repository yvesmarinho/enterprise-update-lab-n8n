# DEBATE TÉCNICO: RUNBOOK -> AUTOMAÇÃO PYTHON/ANSIBLE

**Data:** 2026-03-24
**Objetivo:** definir como evoluir o runbook manual de upgrade n8n para automação com governança, segurança e auditabilidade.

## 1) Participantes do debate (agentes convocados)

- `n8n.system-architect` (arquitetura e estratégia de rollout)
- `devops.engineer-sdd` (implementação idempotente Python/Ansible)
- `test.engineer` (validação, qualidade e critérios GO/NO-GO)
- `project.manager` (governança, ondas de entrega e aprovação de change)

## 2) Posições apresentadas

### 2.1 Arquitetura (`n8n.system-architect`)

- Recomendação: **abordagem híbrida (Python + Ansible)**.
- Diretrizes obrigatórias:
  - upgrade sequencial sem salto de versão;
  - target congelado por rodada;
  - sem promoção sem backup validado e restore drill;
  - sem deploy sem imagem local validada por digest;
  - evidência obrigatória para qualquer decisão de gate.
- Destaque: NO-GO automático quando evidência estiver incompleta.

### 2.2 Implementação (`devops.engineer-sdd`)

- Recomendação: **híbrido com Ansible como engine de execução e Python como control plane**.
- Blueprint proposto:
  - Python: `orchestrator`, `version_resolver`, `hop_planner`, `gate_engine`, `evidence_writer`, `docs_updater`.
  - Ansible: playbooks `precheck`, `checkpoint`, `rollback`, `collect-evidence`; roles para backup/upgrade/validate/gate.
- Resiliência para pull de imagens:
  - retry exponencial com jitter;
  - timeout explícito por tentativa;
  - bloqueio de recreate se imagem não estiver validada localmente;
  - circuit breaker após falhas consecutivas.

### 2.3 Validação (`test.engineer`)

- Recomendação: **híbrido**, por melhor testabilidade e rastreabilidade.
- Gates objetivos por checkpoint:
  - workflow crítico aprovado;
  - `critical_error_count = 0`;
  - regressão de p95 <= 10%;
  - throughput >= 90% baseline;
  - evidência completa e rollback drill aprovado.
- Risco principal: falso positivo por ruído de janela curta.
- Mitigação: janela oficial de 15 min, recorte temporal estrito e perfil de carga consistente entre baseline e pós-hop.

### 2.4 Governança (`project.manager`)

- Recomendação executiva: **híbrido**, equilibrando risco, prazo e valor.
- Modelo de entrega em ondas:
  - Onda 0: governança e baseline;
  - Onda 1: automação base;
  - Onda 2: execução version-by-version em homolog;
  - Onda 3: canário em produção;
  - Onda 4: escala e handoff.
- Condição de aprovação: sem evidência de rollback validado, sem go-live.

## 3) Consensos do debate

- A abordagem **híbrida** foi consenso entre todos os participantes.
- Separação de responsabilidades aprovada:
  - **Ansible** para mudança remota idempotente e rollback.
  - **Python** para lógica de decisão, gates, evidências e atualização documental.
- Governança mandatória por checkpoint com decisão formal GO/NO-GO.
- Critérios de bloqueio comuns:
  - ausência de backup/restore drill;
  - falha de validação funcional crítica;
  - regressão acima do limite;
  - falta de evidência auditável.

## 4) Divergências e resolução

- Divergência leve: nível de complexidade inicial do MVP.
- Resolução:
  - iniciar com MVP enxuto (fluxo completo em 1-2 hops);
  - ampliar para hardening após validação de campo;
  - manter runbook manual como fallback controlado (break-glass) até maturidade.

## 5) Decisão final

**Decisão aprovada:** implementar **automação híbrida Python + Ansible** para evoluir o runbook de upgrade n8n.

**Justificativa final:**

- menor risco operacional para execução remota em produção;
- maior previsibilidade por idempotência e rollback automatizado;
- melhor auditabilidade com evidências estruturadas por hop;
- velocidade adequada para entregar MVP sem sacrificar governança.

## 6) Plano de execução recomendado

### Fase A: MVP (5-7 dias úteis)

- Implementar fluxo por hop:
  - `PRECHECK -> BACKUP -> PULL -> DEPLOY -> VALIDATE -> GATE`.
- Entregar playbooks essenciais Ansible (`precheck`, `checkpoint`, `rollback`).
- Entregar orquestração Python com freeze de target e gate engine.
- Gerar pacote de evidências por checkpoint (JSON + Markdown).
- Executar piloto controlado com decisão formal GO/NO-GO.

### Fase B: Hardening (7-10 dias úteis)

- Expandir testes de falha/rede e rollback parcial.
- Refinar retries, circuit breaker e retomada segura.
- Endurecer segurança de logs/segredos e trilha de auditoria.
- Completar handoff operacional e critérios finais de change.

## 7) Critérios de aceite (DoD)

- execução idempotente comprovada em repetição controlada;
- rollback automatizado testado com evidência;
- 100% workflows críticos aprovados;
- `critical_error_count = 0` no checkpoint oficial;
- performance dentro de limite acordado;
- evidências completas anexadas para auditoria;
- aprovação formal de gate pelos responsáveis.

## 8) RACI simplificado

- `Change Manager`: aprovação de janela e gates de mudança.
- `Tech Lead Plataforma`: dono técnico da arquitetura e decisão operacional.
- `SRE/DevOps`: execução Ansible e confiabilidade do rollout.
- `QA/Validação`: evidências, regressão e aceite funcional.
- `Operações`: suporte de janela e contingência.

## 9) Próximos passos imediatos

- Definir contrato de dados Python <-> Ansible (input/output por hop).
- Criar estrutura inicial de playbooks e módulos Python no repositório.
- Rodar um checkpoint piloto em modo controlado e anexar relatório de decisão.
- Após piloto aprovado, avançar para rollout por ondas.
