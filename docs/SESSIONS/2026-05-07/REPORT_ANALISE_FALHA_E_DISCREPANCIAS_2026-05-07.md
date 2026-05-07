# Report: Análise de Falha HOP 1A e Discrepâncias no RUNBOOK

**Gerado em**: 2026-05-07
**Sessão de referência**: 2026-05-02
**Autor**: GitHub Copilot (análise automática)
**Artefatos analisados**:

1. `docs/SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md`
2. `docs/SESSIONS/2026-05-02/PRODUCAO_UPGRADE_EXECUTION_2026-05-02.md`
3. `docs/SESSIONS/2026-05-02/FINAL_STATUS_2026-05-02.md`
4. `docs/SESSIONS/2026-05-02/PROCEDIMENTO_RESTORE_CREDENCIAIS.md`
5. `docs/SESSIONS/2026-05-02/SESSION_REPORT_2026-05-02.md`
6. `docs/RUNBOOK_PRODUCAO_N8N.md` (versão 1.3, 2026-05-04)

---

## 1. Sumário Executivo

A tentativa de upgrade N8N em Produção em 2026-05-02 **falhou no HOP 1A** (`2.6.4 → 2.7.0`) às 19:53 UTC e resultou em rollback completo às 20:09 UTC. A causa raiz foi **schema PostgreSQL contaminado** por uma tabela órfã deixada por tentativa anterior de upgrade. A análise das sessões revelou ainda **4 discrepâncias críticas** entre os documentos de sessão e o RUNBOOK vigente.

---

## 2. Análise da Falha

### 2.1 Linha do Tempo

| Horário (UTC) | Evento |
|---|---|
| 19:15 | Pre-pull iniciado (14 imagens, 4 paralelas) |
| 19:28 | Pre-pull concluído — ~3.2 GB, ~13 min |
| 19:53:28 | HOP 1A iniciado: `docker compose up -d` com `n8nio/n8n:2.7.0` |
| ~19:58 | Containers UP (8/8), healthcheck HTTP 200 ✅ |
| ~19:58 | **Migration FALHOU** — `relation "secrets_provider_connection" already exists` |
| ~20:05 | Workflows não ativam — `WorkflowActivationError: Client authentication failed` |
| 20:09:14 | **Rollback executado** — backup `/tmp/docker-compose.yaml.20260502T190647Z` aplicado |
| 20:09 | N8N `2.6.4` restaurado — 9/9 containers UP, healthcheck 200 ✅ |

### 2.2 Erro Principal (CRÍTICO)

```
Migration "CreateSecretsProviderConnectionTables1769433700000" failed
Error: relation "secrets_provider_connection" already exists
There was an error running database migrations
```

**Causa raiz confirmada**: Tabela `secrets_provider_connection` pré-existente no schema PostgreSQL de Produção, criada por tentativa de upgrade anterior que falhou parcialmente. O TypeORM da versão `2.6.4` não rastreia esta tabela, mas a migration da versão `2.7.0` tenta criá-la, colidindo com o objeto já existente.

### 2.3 Erro Secundário (CASCATA)

```
WorkflowActivationError: There was a problem activating the workflow:
"Client authentication failed"
Workflow afetado: "agente-ia-maia-interno" (ID: 3NVowOEzMXpIL66L)
```

**Causa**: A falha de migration deixou o schema em estado inconsistente, impedindo o provider de secrets de inicializar, o que por sua vez bloqueou a autenticação dos workflows.

### 2.4 Erro Resolvido Durante a Sessão

```
❌ ANTES: unsupported startup parameter in options: statement_timeout
✅ DEPOIS: Corrigido com DB_POSTGRESDB_STATEMENT_TIMEOUT=0
```

Este erro foi tratado corretamente como pré-condição e corrigido antes do HOP 1A.

### 2.5 Estado pós-Rollback

| Componente | Estado |
|---|---|
| N8N Versão | `2.6.4` (restaurado) |
| Containers | 9/9 UP |
| Healthcheck | HTTP 200 ✅ |
| Credenciais | ⚠️ 61 credenciais baixadas, restore pendente |
| Schema DB | ⚠️ Ainda contaminado (tabela órfã presente) |

---

## 3. Discrepâncias: Sessão vs RUNBOOK

### Discrepância 1 — CRÍTICA: Nome do banco de dados divergente

| Documento | Campo | Valor |
|---|---|---|
| `ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md` | `DB_POSTGRESDB_DATABASE` | `n8n_db` |
| `RUNBOOK_PRODUCAO_N8N.md` § Limpeza de Schema | Database (credenciais psql) | `n8n_dev_db` |

**Impacto**: O procedimento de limpeza do RUNBOOK aponta para `n8n_dev_db`, mas a Produção usa `n8n_db`. Executar os comandos SQL diretamente contra `n8n_dev_db` **não limpará o schema de Produção**.

**Ação corretiva obrigatória**: Atualizar RUNBOOK § "Passo 1: Conectar ao PostgreSQL" para `n8n_db`.

---

### Discrepância 2 — CRÍTICA: Número de hops na Trilha COMPLETA

| Documento | Total de hops | Primeiro hop |
|---|---|---|
| `PRODUCAO_UPGRADE_EXECUTION_2026-05-02.md` | **14 hops** | `2.6.4 → 2.7.0` |
| `RUNBOOK_PRODUCAO_N8N.md` § Trilha COMPLETA | **13 hops** | `2.6.4 → 2.7.5` ← pula 2.7.0 |

**Trilha no RUNBOOK (incorreta)**:
```
2.6.4 → 2.7.5 → 2.8.4 → ... (13 hops)
```

**Trilha correta confirmada pela sessão**:
```
2.6.4 → 2.7.0 → 2.7.5 → 2.8.4 → ... (14 hops)
```

**Impacto**: Pular `2.7.0` em Produção causaria exatamente o mesmo erro de migration já ocorrido. O hop direto `2.6.4 → 2.7.5` foi tentado na sessão 2026-03-24 e **também falhou** (documentado no RUNBOOK em "Observações 2026-03-24": "O primeiro hop `2.6.4 → 2.7.5` foi aplicado e reprovado no gate por erros de inicialização de DB").

**Ação corretiva obrigatória**: Corrigir trilha na seção "Trilha COMPLETA" para 14 hops incluindo `2.7.0`.

---

### Discrepância 3 — MÉDIA: Servidor de acesso remoto padrão

| Documento | Servidor | Wrapper |
|---|---|---|
| `PRODUCAO_UPGRADE_EXECUTION_2026-05-02.md` | `wf001` (app, 31.220.103.208) | `~/.local/bin/ssh-wf001` |
| `RUNBOOK_PRODUCAO_N8N.md` § "Acesso remoto padrão" | `wfdb01` | `~/.local/bin/ssh-wfdb01` |

**Análise**: A seção "Acesso remoto padrão" do RUNBOOK documenta `wfdb01` como host alvo operacional, mas a operação de upgrade é feita em `wf001` (servidor de aplicação Docker). `wfdb01` (82.197.64.145) é o servidor PostgreSQL — acesso separado para operações de banco.

A seção de limpeza de schema usa `~/.local/bin/ssh-wfdb01` (correto para operações SQL diretas), mas a seção de "Acesso remoto padrão" do RUNBOOK deveria distinguir claramente os dois hosts.

**Impacto**: Ambiguidade pode levar operador a usar wrapper errado durante upgrade de containers Docker.

---

### Discrepância 4 — BAIXA: Total de credenciais não documentado no RUNBOOK

| Documento | Informação |
|---|---|
| `FINAL_STATUS_2026-05-02.md` | 61 credenciais (download concluído, restore pendente) |
| `PROCEDIMENTO_RESTORE_CREDENCIAIS.md` | 30 arquivos JSON (backup de 20250424) |
| `RUNBOOK_PRODUCAO_N8N.md` | Nenhuma menção ao número esperado de credenciais |

**Impacto**: Sem valor de referência no RUNBOOK, a validação pós-restore não tem baseline para confirmar integridade. A query de validação `SELECT COUNT(*) FROM credentials_entity` não tem valor esperado documentado (confirmado como ~61 pela sessão 2026-05-04).

---

## 4. Requisito Pendente de Alta Prioridade

### Restore de Credenciais (⏸️ Interrompido em 2026-05-02)

**Estado**: 61 credenciais foram baixadas para máquina local em `~/n8n_credentials_restore/`, mas o restore foi interrompido antes de completar.

**Verificação necessária antes do próximo hop**:

```sql
SELECT COUNT(*) FROM credentials_entity;
-- Valor esperado: ~61
-- Se retornar < 61: executar restore antes do upgrade
```

**Método recomendado**: Interface web (mais seguro, valida automaticamente) — ver `PROCEDIMENTO_RESTORE_CREDENCIAIS.md`.

---

## 5. Pré-condições para Retomada do Upgrade

**Antes de qualquer tentativa de HOP 1A novamente**:

| # | Ação | Status | Prioridade |
|---|---|---|---|
| 1 | `DROP TABLE IF EXISTS secrets_provider_connection CASCADE;` em `n8n_db` (wfdb01) | ⏳ Pendente | P0 |
| 2 | Verificar `SELECT COUNT(*) FROM credentials_entity;` → esperado ~61 | ⏳ Pendente | P0 |
| 3 | Confirmar que RUNBOOK usa `n8n_db` (não `n8n_dev_db`) antes de executar | ⏳ Pendente | P0 |
| 4 | Confirmar trilha de 14 hops no RUNBOOK inclui `2.7.0` como primeiro hop | ⏳ Pendente | P1 |

---

## 6. Ações Corretivas no RUNBOOK Recomendadas

| # | Seção | Correção |
|---|---|---|
| C1 | Trilha COMPLETA — quantidade | Alterar "13 hops" para "14 hops" |
| C2 | Trilha COMPLETA — sequência | Inserir `2.7.0` entre `2.6.4` e `2.7.5` |
| C3 | Limpeza de Schema § Passo 1 | Corrigir `n8n_dev_db` → `n8n_db` |
| C4 | Acesso remoto padrão | Distinguir claramente `wf001` (app) vs `wfdb01` (DB) |
| C5 | Validação de credenciais | Adicionar baseline esperado (~61) para `SELECT COUNT(*)` |

---

## 7. Referências

- Diagnóstico PostgreSQL: `.tmp/diagnostico_secrets_provider_20260504_102019.json`
- Análise de falha completa: `docs/SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md`
- Procedimento de restore: `docs/SESSIONS/2026-05-02/PROCEDIMENTO_RESTORE_CREDENCIAIS.md`
- RUNBOOK vigente: `docs/RUNBOOK_PRODUCAO_N8N.md` (v1.3)
