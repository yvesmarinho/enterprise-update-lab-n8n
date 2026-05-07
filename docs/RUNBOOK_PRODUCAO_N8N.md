# RUNBOOK PRODUCAO N8N

## Histórico de Versões

| Versão | Data | Autor | Descrição |
|--------|------|-------|-----------|
| 1.0 | 2026-03-24 | Sistema | Versão inicial - Trilha 2.6.4 → 2.13.2 executada no Lab |
| 1.1 | 2026-04-29 | Sistema | Atualização trilha complementar 2.13.2 → 2.19.1 (Lab) |
| 1.2 | 2026-05-02 | Sistema | Análise de falha HOP 1A em Produção - schema contaminado |
| 1.3 | 2026-05-04 | Sistema | Procedimento de limpeza de schema PostgreSQL |
| 1.4 | 2026-05-07 | Sistema | Correcoes C1-C5: trilha 14 hops, n8n_db, hosts separados, baseline credenciais, senha redatada |
| 1.5 | 2026-05-07 | Sistema | Revisao pre-upgrade 20h: limpeza SQL condicional, trilha complementar concluida, hosts wf001/wfdb02 corrigidos, checklist atualizado |
| 1.6 | 2026-05-07 | Sistema | Correcao host DB: wfdb01 → wfdb02 (82.197.64.145) em todo o documento |

**Versão atual**: 1.6
**Última atualização**: 2026-05-07
**Status**: Produção bloqueada em 2.6.4 | Lab em 2.19.1

---

## Objetivo

Padronizar a aplicacao do processo de upgrade do n8n em producao com seguranca, rastreabilidade e rollback controlado.

## Escopo

- Ambiente alvo: stack n8n via Docker Compose
- Estrategia: upgrade sequencial por checkpoint
- Janela de medicao: 15 minutos por hop

## Acesso remoto padrao (obrigatorio)

> **ATENCAO — DOIS HOSTS + SQL LOCAL**: usar o metodo correto para cada operacao.

| Operacao | Host | Metodo obrigatorio | base de dados |
|----------|------|--------------------|---------------|
| Containers Docker N8N Producao | `wf001` (31.220.103.208) | `~/.local/bin/ssh-wf001` | n8n_db |
| Containers Docker N8N Lab | `wfdb01` (86.48.31.149) | `~/.local/bin/ssh-wfdb01` | n8n_dev_db |
| SQL / PostgreSQL | `wfdb02` (82.197.64.145:5432) | `psql` **neste computador** (sem SSH) | null |

- Nao usar SSH direto (`ssh wf001` ou `ssh wfdb01`) durante a operacao deste projeto.
- **wf001 e wfdb01 NAO tem psql instalado** — todo comando SQL roda neste computador.
- Ambos os usuarios: `archaris`, com `sudo` sem senha.

Exemplo — operacao em containers (wf001):

```bash
~/.local/bin/ssh-wf001 'cd /opt/docker_user/n8n && docker compose images'
```

Exemplo — operacao em banco de dados (PostgreSQL em wfdb02, executar NESTE COMPUTADOR):

```bash
# psql roda localmente — nenhum dos hosts tem psql instalado
psql -h 82.197.64.145 -p 5432 -U n8n_admin -d n8n_db
```

## Pre-requisitos obrigatorios

1. Change aprovado com janela de manutencao definida.
2. Backup validado de dados persistentes e configuracoes.
3. Lista de workflows criticos para validacao funcional.
4. Aprovadores de gate definidos (tecnico e negocio).
5. Plano de rollback testado (drill ou simulacao validada).
6. **🔴 CRÍTICO**: Schema PostgreSQL limpo (sem tabelas órfãs) - ver seção "Limpeza de Schema".
7. **🔴 CRÍTICO**: Credenciais integras — `SELECT COUNT(*) FROM credentials_entity;` deve retornar >= 61.

## Trilhas de Upgrade Disponíveis

### 🏭 Trilha COMPLETA — Para Produção (2.6.4 → 2.19.1)

**Ambiente**: Produção (versão atual: 2.6.4)
**Quando executar**: Após validação completa da trilha complementar no laboratório
**Total de hops**: 14
**Tempo estimado**: ~210 minutos (15 min/hop)
**⚠️ CRÍTICO**: Deve percorrer TODAS as versoes intermediarias, sem pular. O HOP 2.6.4→2.7.0 e OBRIGATORIO — pular direto para 2.7.5 causa falha de migration (confirmado em 2026-03-24 e 2026-05-02).

```text
2.6.4  → 2.7.0  → 2.7.5  → 2.8.4  → 2.9.4  → 2.10.4 → 2.11.4 → 2.12.3 →
2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

**Séries cobertas**:
- 2.6 (5 versões) → 2.7 (6 versões) → 2.8 (5 versões) → 2.9 (5 versões)
- 2.10 (5 versões) → 2.11 (5 versões) → 2.12 (4 versões) → 2.13 (5 versões)
- 2.14 (3 versões) → 2.15 (2 versões) → 2.16 (3 versões) → 2.17 (9 versões)
- 2.18 (6 versões) → 2.19 (2 versões)

---

### 🔬 Trilha COMPLEMENTAR — Para Laboratório (2.13.2 → 2.19.1)

**Ambiente**: Laboratório wfdb01 (versão atual: 2.13.2)
**Quando executar**: ✅ CONCLUÍDA em 2026-04-29 (Lab já está em 2.19.1)
**Total de hops**: 8
**Tempo estimado**: ~120 minutos (15 min/hop)
**Objetivo**: Validar versões 2.14-2.19 antes de aplicar trilha completa em produção — **CONCLUÍDO**

```
2.13.2 → 2.13.3 → 2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

---

### Trilha Histórica — Já Executada no Lab (2.6.4 → 2.13.2)

**Período**: Março 2026
**Status**: ✅ Completada até 2.13.2 (validado 2026-03-25)
**Ambiente**: Laboratório wfdb01

**Hops executados**:
1. 2.6.4 → 2.7.0
2. 2.7.0 → 2.7.5
3. 2.7.5 → 2.8.4
4. 2.8.4 → 2.9.4
5. 2.9.4 → 2.10.4 ⚠️ **Bloqueio temporário** (pull não concluiu, resolvido)
6. 2.10.4 → 2.11.4
7. 2.11.4 → 2.12.3
8. 2.12.3 → 2.13.2 ✅ **Baseline lab validado**

**Observações**:
- Procedimento de rollback testado e validado
- ⚠️ Esta validação foi feita no LABORATÓRIO, NÃO em produção
- Produção permanece em 2.6.4

---

## 🔴 Limpeza de Schema PostgreSQL (OBRIGATÓRIO ANTES DO UPGRADE)

### Contexto

**Problema identificado em 2026-05-02**:
- Tentativa de upgrade 2.6.4 → 2.7.0 em Produção FALHOU
- Erro: `There was an error initializing DB`
- Causa raiz: Tabela órfã `secrets_provider_connection` contaminando schema

**Origem da contaminação**:
- Upgrade parcial anterior deixou tabela no schema
- Tabela não está rastreada pelo TypeORM da versão 2.6.4
- Migração 2.7.0 tenta criar a tabela, mas ela já existe

### Diagnóstico Executado (2026-05-04)

**Ferramentas**:
- Script: `.tmp/diagnostico_secrets_provider_connection.py`
- Driver: `psycopg2-binary`

**Resultados**:

| Tabela | Registros | Referências | Status |
|--------|-----------|-------------|--------|
| `secrets_provider_connection` | 0 (vazia) | 1 tabela dependente | ⚠️ Contaminada |
| `project_secrets_provider_access` | 0 (vazia) | FK → secrets_provider_connection | ⚠️ Dependente |

**Estrutura da tabela órfã**:
```sql
CREATE TABLE secrets_provider_connection (
    id INTEGER PRIMARY KEY,
    "providerKey" VARCHAR(128) UNIQUE NOT NULL,
    type VARCHAR(36) NOT NULL,
    "encryptedSettings" TEXT NOT NULL,
    "isEnabled" BOOLEAN DEFAULT false,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP(3),
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP(3)
);
```

**Análise de impacto**:
- ✅ Ambas as tabelas estão VAZIAS (0 registros)
- ✅ Nenhum workflow utiliza estas tabelas
- ✅ Nenhum dado será perdido com DROP CASCADE
- ✅ **SEGURO para remoção**

### Procedimento de Limpeza

**⚠️ ATENÇÃO**: Executar ANTES de qualquer tentativa de upgrade

#### Passo 1: Conectar ao PostgreSQL

```bash
# Executar NESTE COMPUTADOR (wf001 e wfdb01 nao tem psql instalado)
psql -h 82.197.64.145 -p 5432 -U n8n_admin -d n8n_db
```

**Credenciais** (de `.secrets/.env`):
- Host: `82.197.64.145`
- Port: `5432`
- Database: `n8n_db`
- User admin: `n8n_admin`
- Password: consultar `.secrets/.env` (variavel `DB_POSTGRESDB_PASSWORD`) — nunca em texto claro

#### Passo 2: Verificar existência da tabela

```sql
-- Confirmar que a tabela existe
SELECT tablename, schemaname
FROM pg_tables
WHERE tablename = 'secrets_provider_connection';

-- Verificar se há dados (deve retornar 0)
SELECT COUNT(*) FROM secrets_provider_connection;

-- Verificar tabela dependente
SELECT COUNT(*) FROM project_secrets_provider_access;
```

**Resultado esperado**:
- `secrets_provider_connection`: 0 registros
- `project_secrets_provider_access`: 0 registros

#### Passo 3: Executar limpeza condicional

```sql
-- BACKUP: Documentar estado antes da limpeza
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name IN ('secrets_provider_connection', 'project_secrets_provider_access');

-- LIMPEZA CONDICIONAL: so executa DROP se a tabela existir E estiver vazia
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
```

**Efeito do CASCADE**:
- Remove a tabela `secrets_provider_connection`
- Remove automaticamente a foreign key de `project_secrets_provider_access`
- A tabela `project_secrets_provider_access` permanece, mas sem a constraint

#### Passo 4: Validar limpeza

```sql
-- Confirmar remoção (deve retornar 0 linhas)
SELECT tablename
FROM pg_tables
WHERE tablename = 'secrets_provider_connection';

-- Verificar que tabela dependente ainda existe
SELECT tablename
FROM pg_tables
WHERE tablename = 'project_secrets_provider_access';

-- Confirmar que foreign key foi removida
SELECT
    tc.constraint_name,
    tc.table_name
FROM information_schema.table_constraints tc
WHERE tc.constraint_name = 'FK_18e5c27d2524b1638b292904e48';
-- Deve retornar 0 linhas
```

**Resultado esperado**:
- ✅ Tabela `secrets_provider_connection` NÃO EXISTE
- ✅ Tabela `project_secrets_provider_access` EXISTE (sem FK)
- ✅ Schema limpo para upgrade

#### Passo 5: Documentar evidências

```bash
# Salvar timestamp da limpeza
echo "Schema cleanup executed at $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> /tmp/schema_cleanup.log

# Registrar em DAILY_ACTIVITIES da sessão
```

### Validação pós-limpeza

**Checklist**:
- [ ] Conectado ao PostgreSQL como `n8n_admin`
- [ ] Confirmado que `secrets_provider_connection` tem 0 registros
- [ ] Confirmado que `project_secrets_provider_access` tem 0 registros
- [ ] Executado bloco condicional `DO $$ ... END $$;` — limpeza automatica se vazia, aborta se houver dados
- [ ] Confirmado que tabela foi removida (SELECT retorna 0 linhas)
- [ ] Confirmado que FK foi removida
- [ ] Timestamp de limpeza documentado
- [ ] Evidências salvas em sessão

### Observações importantes

1. **Por que CASCADE é seguro?**
   - Ambas as tabelas estão completamente vazias
   - Nenhum workflow ativo usa estas tabelas
   - Nenhum dado será perdido

2. **Por que a tabela existe em Produção e não no Lab?**
   - Lab teve instalação/upgrade limpo
   - Produção teve tentativa anterior de upgrade que falhou parcialmente
   - Tabela ficou órfã no schema de Produção

3. **Esta limpeza afeta workflows?**
   - NÃO — nenhum workflow utiliza estas tabelas
   - Validado via query: `SELECT * FROM workflow_entity WHERE nodes::text ILIKE '%secrets_provider%'`
   - Resultado: 0 workflows encontrados

4. **Preciso fazer backup antes?**
   - Recomendado por segurança, mas tabelas estão vazias
   - Backup mínimo: documentar estrutura da tabela (já feito no diagnóstico)

### Referências

- Diagnóstico completo: `.tmp/diagnostico_secrets_provider_20260504_102019.json`
- Análise de falha: `docs/SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md`
- Análise de sucesso do Lab: `docs/SESSIONS/2026-05-04/ANALISE_UPGRADE_LAB_SUCESSO.md`

---

## Procedimento por Checkpoint

### 1. Pre-check

1. Confirmar versao atual em runtime: `~/.local/bin/ssh-wf001 'docker inspect n8n_editor --format "{{.Config.Image}}"'`
2. Confirmar status dos containers (todos Up): `~/.local/bin/ssh-wf001 'docker ps --filter "name=n8n" --format "table {{.Names}}\t{{.Status}}"'`
3. Verificar schema limpo em `n8n_db` — executar limpeza condicional (ver secao **🔴 Limpeza de Schema**) via `psql` neste computador.
4. Verificar credenciais integras — executar neste computador:

   ```bash
   psql -h 82.197.64.145 -p 5432 -U n8n_admin -d n8n_db -c "SELECT COUNT(*) FROM credentials_entity;"
   ```

   Deve retornar >= 61.
5. Coletar baseline de erros e metricas na janela de 15 minutos.

### 2. Backup

1. Gerar backup dos volumes/dados.
2. Gerar backup de compose e variaveis.
3. Validar checksum e registrar artefato.

Exemplo minimo (quando sem permissao de escrita no diretorio do stack):

```bash
# Backup em wf001 (host dos containers Docker de Producao)
~/.local/bin/ssh-wf001 'cd /opt/docker_user/n8n && ts=$(date -u +%Y%m%dT%H%M%SZ) && sudo cp docker-compose.yaml /tmp/docker-compose.yaml.$ts && sudo cp .env /tmp/.env.$ts && echo "Backup: $ts"'
```

### 3. Aplicacao do hop

1. Atualizar tag da imagem no compose para a versao alvo do hop.
2. Realizar pull da imagem alvo.
3. Subir stack (`docker compose up -d`).
4. Validar novamente versao efetiva em runtime.

### 4. Validacao pos-hop

1. Validacao funcional dos workflows criticos.
2. Coleta de metricas na janela de 15 minutos:

- `critical_error_count`
- `p95_execution_time_ms`
- `avg_throughput_per_15min`

1. Aplicar limite de regressao: <= 10% vs baseline.

### 5. Gate

1. GO se:

- `critical_error_count = 0`
- p95 e throughput dentro do limite
- validacao funcional sem regressao

1. NO-GO se qualquer criterio falhar.

### 6. Rollback (se NO-GO)

1. Restaurar compose e dados da versao anterior.
2. Subir stack da versao anterior.
3. Revalidar saude, workflows criticos e conectividade.
4. Registrar causa raiz preliminar e bloqueio para proximo hop.

Exemplo de rollback de imagem (com sudo no compose):

```bash
# Rollback em wf001 (host dos containers Docker de Producao)
~/.local/bin/ssh-wf001 'cd /opt/docker_user/n8n && sudo sed -i "s/n8nio\/n8n:VERSAO_NOVA/n8nio\/n8n:VERSAO_ANTERIOR/g" docker-compose.yaml && docker compose up -d'

# Confirmar versao restaurada
~/.local/bin/ssh-wf001 'docker inspect n8n_editor --format "{{.Config.Image}}"'
```

## Evidencias obrigatorias por hop

1. Snapshot pre-check e pos-check.
2. Log de comando de atualizacao.
3. Resultado de validacao funcional.
4. Resultado de metricas 15 minutos.
5. Decisao GO/NO-GO assinada.
6. Registro de rollback (quando aplicavel).

## Checklist rapido de producao

1. Janela de manutencao e comunicacao aprovadas.
2. Schema PostgreSQL limpo — bloco `DO $$ ... END $$;` executado neste computador em `n8n_db` sem EXCEPTION.
3. Credenciais integras — `SELECT COUNT(*) FROM credentials_entity;` retornou >= 61.
4. Backups concluidos — compose + `.env` copiados em `/tmp/` no `wf001` (via `ssh-wf001`).
5. Variaveis de ambiente verificadas no `.env` remoto: `DB_POSTGRESDB_STATEMENT_TIMEOUT=0`, `N8N_PROXY_HOPS=1`, `NODE_OPTIONS=--no-deprecation`.
6. Hop executado e versao confirmada em runtime (`docker inspect n8n_editor`).
7. Gate validado em 15 minutos.
8. Evidencias anexadas no changelog da rodada.

## Observacoes desta sessao (2026-03-24)

- Foi observado historico de erro de autenticacao em ativacao de workflow.
- A janela oficial mais recente registrou `critical_error_count=0`.
- O primeiro hop `2.6.4 -> 2.7.5` foi aplicado e reprovado no gate por erros de inicializacao de DB.
- Rollback executado com sucesso para `2.6.4` usando `~/.local/bin/ssh-wfdb01` e `sudo` para alteracao do compose.
- Diretriz revisada para proxima tentativa: executar `2.6.4 -> 2.7.0 -> 2.7.5` antes de seguir para `2.8.x`.

## Verificacao de permissao de banco (2026-03-24)

- Fonte de credenciais: `.secrets/.env` (usuario efetivo `n8n_user` e usuario administrativo `n8n_admin`).
- Matriz de privilegios validada em ambos os usuarios:
  - database: `CONNECT=true`, `CREATE=true`
  - schema `public`: `USAGE=true`, `CREATE=true`
- Teste DDL transacional executado e aprovado para ambos os usuarios:
  - `CREATE TABLE`
  - `ALTER TABLE`
  - `CREATE INDEX`
  - `DROP TABLE`
  - `ROLLBACK`
- Conclusao: nao foi identificado bloqueio de permissao DDL no banco para o proximo hop.

## Pre-requisitos adicionais validados para linha 2.7.x (2026-03-24)

1. Compatibilidade de startup options no endpoint de banco.

- Sinal de falha quando nao atendido: `unsupported startup parameter in options: statement_timeout`.
- Mitigacao aplicada para ambiente atual: `DB_POSTGRESDB_STATEMENT_TIMEOUT=0` no `.env` remoto.

1. Configuracao de reverse proxy para editor/API.

- Sinal de falha quando nao atendido: `ERR_ERL_UNEXPECTED_X_FORWARDED_FOR`.
- Mitigacao aplicada para ambiente atual: `N8N_PROXY_HOPS=1` no `.env` remoto.

1. Resultado operacional apos mitigacoes.

- Hop `2.6.4 -> 2.7.0` estabilizado.
- Janela curta de validacao:
  - `ERR_DB_3M=0`
  - `ERR_PROXY_3M=0`

## Observacoes desta sessao (2026-03-24) - continuidade

1. Hop `2.8.4 -> 2.9.4` aplicado com sucesso.

- Compose atualizado para `n8nio/n8n:2.9.4`.
- Runtime confirmado em `n8n_editor`, `n8n_worker`, `n8n_webhook` e `n8n_mcp`.
- Validacao curta pos-hop:
  - `ERR_DB_3M=0`
  - `ERR_PROXY_3M=0`
  - `ERR_CRITICAL_3M=0`

1. Correcao de ruido de log em runtime Node.js.

- Sintoma observado: `(node:7) [DEP0040] DeprecationWarning` para modulo `punycode`.
- Mitigacao aplicada no `.env` remoto: `NODE_OPTIONS=--no-deprecation`.
- Resultado pos-ajuste:
  - `DEP0040_COUNT=0`
  - `PUNYCODE_COUNT=0`
  - `LAST30S_CRASH_COUNT=0`

1. Observacao operacional importante.

- Mensagem `Last session crashed` pode aparecer no boot imediatamente apos `force-recreate`.
- Se nao houver recorrencia em janela curta subsequente, tratar como evento transitorio de inicializacao.

## Observacoes desta sessao (2026-03-24) - bloqueio de proximo hop

1. Tentativa de hop `2.9.4 -> 2.10.4`.

- Compose foi atualizado para `n8nio/n8n:2.10.4` com backup previo.
- Tag `2.10.4` confirmada no registry (`docker manifest inspect` com retorno valido).
- Pull local nao concluiu: processo permanece em `Pulling fs layer` sem finalizar imagem local.
- Estado atual apos tentativa: runtime manteve `2.9.4` (sem alteracao de containers).

1. Tentativa de fallback por tags adjacentes.

- Tags `2.10.5`, `2.10.6`, `2.10.7` e `2.10.8` indisponiveis no registry.
- Fallback testado para `2.11.4` (tag existente), mas pull tambem ficou preso no fim das camadas.

1. Risco e decisao operacional.

- Nao avancar recreate enquanto a imagem alvo nao estiver presente localmente.
- Manter runtime estavel em `2.9.4` ate desbloquear pull de imagem.
- Proxima acao recomendada: diagnostico de rede/registry no host para finalizar download de layers pendentes.

## Observacoes desta sessao (2026-03-24) - retomada apos pull concluido

1. Confirmacao operacional recebida.

- Pull concluido com sucesso para `n8nio/n8n:2.11.4`.

1. Aplicacao efetiva do hop para runtime.

- `docker compose up -d --force-recreate` executado para `n8n_editor`, `n8n_worker`, `n8n_webhook` e `n8n_mcp`.
- Runtime confirmado em `2.11.4` para os 4 servicos.

1. Validacao curta pos-hop.

- `ERR_DB_3M=0`
- `ERR_PROXY_3M=0`
- `ERR_CRITICAL_3M=0`
- `DEP0040_3M=0`

## Observacoes desta sessao (2026-03-24) - ultimo hop 2.13.2 em andamento

1. Solicitacao de continuidade apos front ativo.

- Compose foi atualizado para `n8nio/n8n:2.13.2`.
- Backups gerados: compose e `.env` antes da troca.

1. Estado operacional observado no host durante esta janela.

- Runtime permanece em `2.12.3` enquanto a imagem `2.13.2` nao fica disponivel localmente.
- Pull iniciado por sessao interativa e por unidade `systemd` transitoria, ambos sem fechamento da imagem local ate o momento do registro.
- Logs indicam download completo das camadas novas, sem mensagem final de conclusao de pull.

1. Decisao de seguranca.

- Nao forcar recreate sem imagem local valida.
- Manter servicos estaveis em `2.12.3` ate confirmacao objetiva de `docker image inspect n8nio/n8n:2.13.2` no host.

## Observacoes desta sessao (2026-03-24) - consolidacao de baseline estavel

1. Confirmacao do operador.

- `2.12.3` ativo com frontend acessivel.

1. Ajuste de consistencia aplicado.

- Detectado drift: runtime em `2.12.3` e compose em `2.13.2`.
- Compose realinhado para `n8nio/n8n:2.12.3` sem recreate adicional.
- Estado final consolidado:
  - compose `2.12.3`
  - runtime `2.12.3`

## Observacoes desta sessao (2026-03-24) - fechamento final 2.13.2

1. Upgrade final aplicado.

- Baseline confirmado em `2.12.3`.
- Compose promovido para `n8nio/n8n:2.13.2`.
- Pull concluido com sucesso (`Image is up to date for n8nio/n8n:2.13.2`).
- Recreate executado para `n8n_editor`, `n8n_worker`, `n8n_webhook` e `n8n_mcp`.
- Runtime confirmado em `2.13.2` para os 4 servicos.

1. Validacao curta pos-hop.

- `ERR_DB_3M=0`
- `ERR_PROXY_3M=0`
- `ERR_CRITICAL_3M=0`
- `DEP0040_3M=0`
- `LAST_SESSION_CRASH_30S=0` (sem recorrencia apos bootstrap)

## Observacoes desta sessao (2026-03-24) - hop 2.12.3

1. Pull da imagem confirmado pelo operador.

- Evidencia recebida: `Downloaded newer image for n8nio/n8n:2.12.3`.

1. Aplicacao do hop em runtime.

- Compose atualizado para `n8nio/n8n:2.12.3`.
- `docker compose up -d --force-recreate` executado para `n8n_editor`, `n8n_worker`, `n8n_webhook` e `n8n_mcp`.
- Runtime confirmado em `2.12.3` para os 4 servicos.

1. Validacao curta pos-hop.

- `ERR_DB_3M=0`
- `ERR_PROXY_3M=0`
- `ERR_CRITICAL_3M=0`
- `DEP0040_3M=0`

## Encerramento da rodada (2026-03-24)

1. Estado final confirmado.

- Versao em producao: `2.13.2`.
- Frontend ativo e acessivel.

1. Evidencias finais de saude.

- `ERR_DB_15M=0`
- `ERR_PROXY_15M=0`
- `ERR_CRITICAL_15M=0`
- `DEP0040_15M=0`
- `LAST_SESSION_CRASH_30S=0`

1. Decisao de gate.

- GO final para encerramento da janela de upgrade.
