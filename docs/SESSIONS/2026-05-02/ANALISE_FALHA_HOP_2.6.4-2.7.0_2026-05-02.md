# Análise de Falha: HOP 2.6.4 → 2.7.0 (2026-05-02)

**Data/Hora**: 2026-05-02 17:05 UTC
**Servidor**: wf001 (31.220.103.208)
**Ação**: Rollback executado
**Responsável**: Sistema automatizado

---

## 📋 Sumário Executivo

Tentativa de upgrade N8N 2.6.4 → 2.7.0 **FALHOU** devido a incompatibilidade de migração de schema do banco de dados PostgreSQL 16.10.

**Status final**:
- ✅ Containers: 8/8 UP
- ✅ Healthcheck: HTTP 200
- ❌ Database migrations: FAILED
- ❌ Workflow activation: FAILED
- 🔄 Decisão: **ROLLBACK para 2.6.4**

---

## 🔍 Problemas Identificados

### 1. **Erro de Migração de Schema (CRÍTICO)**

```
Migration "CreateSecretsProviderConnectionTables1769433700000" failed
Error: relation "secrets_provider_connection" already exists
```

**Causa Raiz**:
- Tabela `secrets_provider_connection` já existe no banco de dados
- Migration do N8N 2.7.0 tenta criar a tabela novamente
- Provável contaminação de schema de tentativas anteriores de upgrade

**Impacto**:
- Migration não completa
- Schema do banco fica em estado inconsistente
- Workflows não conseguem ativar corretamente

---

### 2. **Erro de Autenticação de Workflows (SECUNDÁRIO)**

```
WorkflowActivationError: Client authentication failed
(e.g., unknown client, no client authentication included,
or unsupported authentication method)
```

**Workflows afetados**:
- `agente-ia-maia-interno` (ID: 3NVowOEzMXpIL66L)
- Possivelmente outros (logs mostram repetições)

**Possível causa**:
- Schema incompleto após falha de migration
- Credenciais/secrets não acessíveis devido à tabela corrompida
- Workflow tenta usar provider de secrets que falhou na criação

---

### 3. **Problema Resolvido: statement_timeout (CORREÇÃO APLICADA)**

```
❌ ANTES: unsupported startup parameter in options: statement_timeout
✅ DEPOIS: Erro eliminado após adicionar DB_POSTGRESDB_STATEMENT_TIMEOUT=0
```

**Solução aplicada**:
- Adicionado `DB_POSTGRESDB_STATEMENT_TIMEOUT=0` no `.env`
- Documentado no RUNBOOK (já era problema conhecido)
- Correção funcionou corretamente

---

## 🖥️ Estado Técnico no Momento do Rollback

### Versão e Containers

```
Versão instalada: n8nio/n8n:2.7.0
Containers rodando: 8/8
```

| Container | Status | Tempo Up |
|-----------|--------|----------|
| n8n_editor-1 | Up | 5 min |
| n8n_mcp-1 | Up | 5 min |
| n8n_webhook-1 | Up | 5 min |
| n8n_webhook-2 | Up | 5 min |
| n8n_webhook-3 | Up | 5 min |
| n8n_worker-1 | Up | 5 min |
| n8n_worker-2 | Up | 5 min |
| n8n_worker-3 | Up | 5 min |

### Configuração de Banco de Dados

```ini
DB_TYPE=postgresdb
DB_POSTGRESDB_DATABASE=n8n_db
DB_POSTGRESDB_HOST=82.197.64.145  # wfdb02
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_POOL_SIZE=20
DB_POSTGRESDB_STATEMENT_TIMEOUT=0  # ✅ Adicionado para corrigir statement_timeout
```

### Healthcheck

```
https://workflow.vya.digital/healthz → HTTP 200 ✅
Interface web carregando: SIM ✅
```

---

## 🧪 Logs Completos de Erro

### Editor - Erro de Migration

```
Last session crashed
Migration "CreateSecretsProviderConnectionTables1769433700000" failed, error: relation "secrets_provider_connection" already exists
There was an error running database migrations
relation "secrets_provider_connection" already exists
Last session crashed
```

### Editor - Erro de Ativação de Workflow (repetido várias vezes)

```
There was a problem activating the workflow:
"Client authentication failed (e.g., unknown client,
no client authentication included, or unsupported authentication method)."

WorkflowActivationError: There was a problem activating the workflow:
"Client authentication failed (e.g., unknown client,
no client authentication included, or unsupported authentication method)."
    at ActiveWorkflows.add (...)
    at processTicksAndRejections (node:internal/process/task_queues:105:5)
    at ActiveWorkflowManager.addTriggersAndPollers (...)
    at ActiveWorkflowManager.add (...)
    at Timeout.retryFunction [as _onTimeout] (...)

Issue on initial workflow activation try of "agente-ia-maia-interno"
(ID: 3NVowOEzMXpIL66L) (startup)
```

---

## 🔧 Ações Tomadas

### 1. Correção de statement_timeout ✅

```bash
echo 'DB_POSTGRESDB_STATEMENT_TIMEOUT=0' >> /opt/docker_user/n8n/.env
docker compose down && docker compose up -d
```

**Resultado**: Erro `statement_timeout` eliminado.

### 2. Coleta de Estado para Análise ✅

```bash
# Estado completo salvo em:
.tmp/n8n_state_before_rollback_20260502.txt
```

### 3. Decisão de Rollback ✅

Devido à gravidade da falha de migration, rollback é necessário.

---

## 📊 Análise de Causa Raiz

### Por que a migration falhou?

**Hipótese 1** (mais provável):
Tentativas anteriores de upgrade (incluindo hop direto 2.6.4→2.7.5 que falhou) deixaram o banco em estado intermediário:
- Migration começou a rodar
- Criou a tabela `secrets_provider_connection`
- Falhou antes de registrar a migration como completa
- Rollback restaurou versão do N8N mas NÃO do banco
- Próxima tentativa encontra tabela já existente

**Hipótese 2**:
Schema pré-existente de versão futura do N8N (se houve testes anteriores não documentados).

### O que deve ser verificado antes de tentar novamente?

1. **CRÍTICO**: Estado da tabela `migrations` no PostgreSQL
   ```sql
   SELECT * FROM migrations
   WHERE name LIKE '%SecretsProvider%'
   ORDER BY timestamp DESC;
   ```

2. **CRÍTICO**: Existência de tabelas de versões futuras
   ```sql
   SELECT tablename FROM pg_tables
   WHERE schemaname = 'public'
   AND tablename LIKE '%secret%';
   ```

3. **RECOMENDADO**: Backup completo do banco ANTES de qualquer hop

---

## 🎯 Próximos Passos Recomendados

### Opção A: Limpar Schema Manualmente (RÁPIDO)

```sql
-- Executar no PostgreSQL antes do próximo hop
DROP TABLE IF EXISTS secrets_provider_connection CASCADE;
DROP TABLE IF EXISTS secrets_provider_connection_credential CASCADE;

-- Remover entrada de migration se existir
DELETE FROM migrations
WHERE name = 'CreateSecretsProviderConnectionTables1769433700000';
```

### Opção B: Restaurar Backup do Banco (SEGURO)

Se existe backup do banco de dados no estado 2.6.4:
1. Restaurar dump completo do PostgreSQL
2. Validar que schema está limpo (sem tabelas de versões futuras)
3. Tentar hop novamente

### Opção C: Validar e Prosseguir (SE schema estiver OK)

Se verificação SQL mostrar que:
- Tabela `secrets_provider_connection` NÃO existe
- Migration NÃO está registrada

Então pode tentar hop novamente com segurança.

---

## 📝 Lições Aprendidas

1. ✅ **statement_timeout**: Correção `DB_POSTGRESDB_STATEMENT_TIMEOUT=0` funciona
2. ❌ **Rollback incompleto**: Rollback do N8N via compose NÃO reverte banco
3. ⚠️ **Schema contamination**: Migrations parciais deixam banco inconsistente
4. 📋 **Necessidade de backup**: Backup do BANCO é tão crítico quanto do compose

---

## 📂 Arquivos Relacionados

- **Estado completo**: `.tmp/n8n_state_before_rollback_20260502.txt`
- **Backup do compose**: `/tmp/docker-compose.yaml.20260502T195328Z` (wf001)
- **Este documento**: `docs/SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md`

---

## ✅ Rollback Executado

Timestamp: 2026-05-02 17:05 UTC
Backup utilizado: `/tmp/docker-compose.yaml.20260502T195328Z`
Versão restaurada: `n8nio/n8n:2.6.4`
Status: **PENDENTE VALIDAÇÃO**

---

**Próxima ação**: Validar que N8N 2.6.4 está operacional após rollback.
