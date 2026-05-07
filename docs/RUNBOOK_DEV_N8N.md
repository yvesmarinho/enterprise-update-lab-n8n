# RUNBOOK DEV/LAB N8N

## Historico de Versoes

| Versao | Data | Autor | Descricao |
|--------|------|-------|-----------|
| 1.0 | 2026-05-07 | Sistema | Criacao inicial — baseado em licoes aprendidas de Producao e Lab |

**Versao atual**: 1.0
**Ultima atualizacao**: 2026-05-07
**Status**: Lab em 2.19.1 (completo) | proximo upgrade a definir

---

## Objetivo

Documentar procedimentos de upgrade do N8N no ambiente de laboratório (wfdb01) para:

1. Validar cada trilha antes de aplicar em Producao.
2. Testar hotfixes e versoes candidatas em ambiente seguro.
3. Servir como referencia de evidencias historicas para o RUNBOOK de Producao.

---

## Escopo

- Ambiente alvo: Lab N8N via Docker Compose em `wfdb01`
- Estrategia: upgrade sequencial por checkpoint (mesma metodologia de Producao)
- Janela de medicao: 5-10 minutos por hop (ambiente controlado)
- Database Lab: `n8n_dev_db`

---

## Diferencas em relacao ao RUNBOOK de Producao

| Aspecto | Lab (este documento) | Producao |
|---------|---------------------|----------|
| Servidor Docker | `wfdb01` (82.197.64.145) | `wf001` (31.220.103.208) |
| Acesso SSH | `~/.local/bin/ssh-wfdb01` | `~/.local/bin/ssh-wf001` |
| Database PostgreSQL | `n8n_dev_db` | `n8n_db` |
| Gate de validacao | 5-10 min/hop | 15 min/hop |
| Change formal | Nao necessario | Obrigatorio |
| Aprovadores de gate | Tecnico (self-approval) | Tecnico + Negocio |
| URL de acesso | (endpoint interno do lab) | `https://workflow.vya.digital` |
| Credenciais esperadas | Dados de teste | >= 61 registros em `credentials_entity` |

---

## Acesso remoto padrao (obrigatorio)

> **wfdb01 serve como host de DOIS servicos** — containers Docker do Lab e servidor PostgreSQL.

### Operacoes em containers Docker (Lab N8N)

```bash
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && docker compose images'
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && docker compose ps'
```

### Operacoes em banco de dados (PostgreSQL — Lab)

```bash
~/.local/bin/ssh-wfdb01 'psql -h 82.197.64.145 -p 5432 -U n8n_admin -d n8n_dev_db'
```

**Credenciais**: consultar `.secrets/.env` — nunca em texto claro ou arquivos versionados.

---

## Estado atual do Lab (2026-05-07)

| Componente | Versao | Status |
|-----------|--------|--------|
| N8N Lab | 2.19.1 | OK — operacional |
| PostgreSQL | 16.x | OK — operacional |
| Schema `n8n_dev_db` | Limpo | OK — sem tabelas orfas |
| Imagens pre-pulled | 2.7.0 ate 2.19.1 | OK — disponiveis em wfdb01 |

---

## Licoes Aprendidas — Criticas

Estas licoes foram validadas em Lab e/ou Producao. Sao **pre-requisitos de conhecimento** para qualquer operador.

### L1 — HOP 2.6.4 → 2.7.0 e OBRIGATORIO (nao pular para 2.7.5)

**Confirmado em**: 2026-03-24 (Lab) e 2026-05-02 (Producao — rollback executado)

Pular direto de `2.6.4 → 2.7.5` causa:

```text
Migration "CreateSecretsProviderConnectionTables1769433700000" failed
There was an error initializing DB
```

A versao `2.7.0` e necessaria como intermediario para aplicar as migrations corretamente antes de avancar para `2.7.5`.

### L2 — Schema deve estar limpo antes de qualquer hop

Tabelas orfas causam falha de migration com erro `relation already exists`. Verificar antes de qualquer hop:

```sql
SELECT tablename
FROM pg_tables
WHERE tablename IN ('secrets_provider_connection', 'project_secrets_provider_access')
  AND schemaname = 'public';
-- Resultado esperado: 0 linhas
```

Se existirem, executar limpeza (ver secao "Limpeza de Schema" abaixo).

### L3 — Variaveis de ambiente obrigatorias para versoes 2.7.x+

| Variavel | Valor | Motivo |
|----------|-------|--------|
| `DB_POSTGRESDB_STATEMENT_TIMEOUT` | `0` | Evita `unsupported startup parameter: statement_timeout` |
| `N8N_PROXY_HOPS` | `1` | Evita `ERR_ERL_UNEXPECTED_X_FORWARDED_FOR` |
| `NODE_OPTIONS` | `--no-deprecation` | Suprime `[DEP0040] DeprecationWarning: punycode` |

### L4 — "Last session crashed" e transitorio no boot

Mensagem `Last session crashed` pode aparecer imediatamente apos `force-recreate`. Tratar como transitorio se nao houver recorrencia em janela curta subsequente.

### L5 — Pull de imagem pode ficar preso em "Pulling fs layer"

Se o pull ficar sem finalizar, nao executar `up --force-recreate` sem confirmar `docker image inspect n8nio/n8n:VERSAO` no host. Manter runtime estavel ate confirmacao.

---

## Trilha de Upgrade Completa Validada (Lab)

### Trilha 2.6.4 → 2.19.1 (14 hops — completada em 2026-04-29)

```text
2.6.4  → 2.7.0  → 2.7.5  → 2.8.4  → 2.9.4  → 2.10.4 → 2.11.4 → 2.12.3 →
2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

**Total de hops**: 14
**Tempo estimado (Lab)**: ~90-120 minutos (5-10 min/hop)

### Status de execucao historica

| Hop | De | Para | Status | Sessao |
|-----|-----|------|--------|--------|
| 1A | 2.6.4 | 2.7.0 | OK | 2026-03-24 |
| 1B | 2.7.0 | 2.7.5 | OK | 2026-03-24 |
| 2 | 2.7.5 | 2.8.4 | OK | 2026-03-24 |
| 3 | 2.8.4 | 2.9.4 | OK | 2026-03-24 |
| 4 | 2.9.4 | 2.10.4 | OK (pull lento) | 2026-03-24 |
| 5 | 2.10.4 | 2.11.4 | OK | 2026-03-24 |
| 6 | 2.11.4 | 2.12.3 | OK | 2026-03-24 |
| 7 | 2.12.3 | 2.13.2 | OK | 2026-03-24 |
| 8 | 2.13.2 | 2.13.4 | OK | 2026-04-29 |
| 9 | 2.13.4 | 2.14.2 | OK | 2026-04-29 |
| 10 | 2.14.2 | 2.15.1 | OK | 2026-04-29 |
| 11 | 2.15.1 | 2.16.2 | OK | 2026-04-29 |
| 12 | 2.16.2 | 2.17.8 | OK | 2026-04-29 |
| 13 | 2.17.8 | 2.18.5 | OK | 2026-04-29 |
| 14 | 2.18.5 | 2.19.1 | OK | 2026-04-29 |

---

## Pre-requisitos por Hop

1. Schema limpo — sem tabelas orfas (ver L2).
2. Variaveis de ambiente configuradas no `.env` remoto (ver L3).
3. Imagem alvo disponivel localmente no host (`docker image inspect n8nio/n8n:VERSAO`).
4. Backup do compose e `.env` realizado.

---

## Limpeza de Schema (se necessario)

### Diagnostico

```sql
-- Verificar tabelas orfas
SELECT tablename FROM pg_tables
WHERE tablename IN ('secrets_provider_connection', 'project_secrets_provider_access')
  AND schemaname = 'public';

-- Verificar dados (ambas devem estar vazias para ser seguro)
SELECT COUNT(*) FROM secrets_provider_connection;
SELECT COUNT(*) FROM project_secrets_provider_access;
```

### Limpeza condicional (executa DROP somente se a tabela estiver vazia)

```sql
-- Remocao condicional: so executa se a tabela existir E estiver vazia
DO $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_tables
        WHERE tablename = 'secrets_provider_connection'
          AND schemaname = 'public'
    ) THEN
        SELECT COUNT(*) INTO v_count FROM secrets_provider_connection;
        IF v_count = 0 THEN
            DROP TABLE secrets_provider_connection CASCADE;
            RAISE NOTICE 'OK: secrets_provider_connection removida (estava vazia).';
        ELSE
            RAISE EXCEPTION 'ABORTADO: tabela contem % registro(s) — revisao manual obrigatoria.', v_count;
        END IF;
    ELSE
        RAISE NOTICE 'OK: secrets_provider_connection nao existe — schema ja esta limpo.';
    END IF;
END $$;

-- Validar remocao
SELECT tablename FROM pg_tables WHERE tablename = 'secrets_provider_connection';
-- Deve retornar 0 linhas
```

> **Por que CASCADE e seguro?** A tabela `project_secrets_provider_access` continua existindo; apenas a FK e removida. Nenhum dado e perdido quando ambas estao vazias.

---

## Procedimento por Checkpoint (Lab)

### 1. Pre-check

```bash
# Versao atual em runtime
~/.local/bin/ssh-wfdb01 'docker inspect n8n_editor --format "{{.Config.Image}}"'

# Status dos containers
~/.local/bin/ssh-wfdb01 'docker ps --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}"'

# Schema limpo
~/.local/bin/ssh-wfdb01 'psql -h 82.197.64.145 -p 5432 -U n8n_admin -d n8n_dev_db \
  -c "SELECT tablename FROM pg_tables WHERE tablename = '"'"'secrets_provider_connection'"'"';"'
```

### 2. Backup

```bash
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && \
  ts=$(date -u +%Y%m%dT%H%M%SZ) && \
  cp docker-compose.yaml /tmp/docker-compose.yaml.$ts && \
  cp .env /tmp/.env.$ts && \
  echo "Backup: $ts"'
```

### 3. Aplicar hop

```bash
# Substituir tag (ajustar VERSAO_ATUAL e VERSAO_NOVA)
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && \
  sudo sed -i "s/n8nio\/n8n:VERSAO_ATUAL/n8nio\/n8n:VERSAO_NOVA/g" docker-compose.yaml'

# Pull + recreate
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && \
  docker compose pull && docker compose up -d'

# Confirmar versao em runtime
~/.local/bin/ssh-wfdb01 'docker inspect n8n_editor --format "{{.Config.Image}}"'
```

### 4. Validacao pos-hop (5-10 min)

```bash
# Verificar logs — ausencia de erros criticos
~/.local/bin/ssh-wfdb01 'docker logs n8n_editor --tail 60 2>&1 | grep -E "ERROR|Migration failed|crashed"'
```

**Criterios de GO**:

- `ERR_DB = 0`
- `ERR_CRITICAL = 0`
- Sem mensagem `Migration failed`
- Sem `Last session crashed` recorrente

### 5. Gate — GO / NO-GO

| Criterio | Limite | Decisao se falhar |
|----------|--------|-------------------|
| `ERR_DB` | 0 | NO-GO imediato |
| `Migration failed` | 0 | NO-GO imediato |
| `ERR_CRITICAL` | 0 | NO-GO imediato |
| `Last session crashed` recorrente | 0 | NO-GO |

### 6. Rollback (se NO-GO)

```bash
# Restaurar compose do backup (substituir TIMESTAMP pelo valor real)
~/.local/bin/ssh-wfdb01 'sudo cp /tmp/docker-compose.yaml.TIMESTAMP /opt/docker_user/n8n/docker-compose.yaml'
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && docker compose up -d'

# Verificar versao restaurada
~/.local/bin/ssh-wfdb01 'docker inspect n8n_editor --format "{{.Config.Image}}"'
```

---

## Verificacao de Integridade de Dados

```sql
-- Workflows ativos
SELECT COUNT(*) FROM workflow_entity WHERE active = true;

-- Credentials
SELECT COUNT(*) FROM credentials_entity;

-- Execucoes recentes (ultimas 10)
SELECT id, "workflowId", status, "startedAt"
FROM execution_entity
ORDER BY "startedAt" DESC
LIMIT 10;
```

---

## Evidencias obrigatorias por hop (Lab)

1. Versao antes e depois (`docker inspect`).
2. Log pos-hop (resultado do `grep -E "ERROR|Migration"`).
3. Decisao GO/NO-GO registrada em `docs/SESSIONS/YYYY-MM-DD/DAILY_ACTIVITIES_*.md`.

---

## Referencias

- [RUNBOOK Producao](RUNBOOK_PRODUCAO_N8N.md) — procedimento oficial para wf001
- [Analise de falha 2026-05-02](SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md)
- [Report discrepancias 2026-05-07](SESSIONS/2026-05-07/REPORT_ANALISE_FALHA_E_DISCREPANCIAS_2026-05-07.md)
- Diagnostico de schema: `.tmp/diagnostico_secrets_provider_20260504_102019.json`
