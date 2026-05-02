# EXECUÇÃO UPGRADE PRODUÇÃO N8N — 2026-05-02

**Servidor**: wf001 (Produção)
**Versão Atual**: 2.6.4
**Versão Alvo**: 2.19.1
**Total de Hops**: 14 (hop 2.6.4 → 2.7.5 dividido em 2)
**Tempo Estimado**: ~210 minutos (15 min/hop)
**Acesso Remoto**: `~/.local/bin/ssh-wf001`

⚠️ **ROLLBACK EXECUTADO**: 19:14 UTC - Hop direto 2.6.4 → 2.7.5 causou erro "There was an error initializing DB" conforme previsto no histórico

🚀 **OTIMIZAÇÃO APLICADA**: 19:28 UTC - Pre-pull paralelo de todas as 14 imagens (4 por vez) para acelerar os hops subsequentes

---

## ✅ PRÉ-REQUISITOS (COMPLETADOS)

- [x] Backup do banco de dados em andamento (usuário)
- [x] Containers parados no wf001
- [x] Change aprovado
- [x] Janela de manutenção definida
- [x] Pre-pull de todas as 14 imagens da trilha (2.7.0 até 2.19.1)

---

## 📋 TRILHA DE UPGRADE COMPLETA (CORRIGIDA)

⚠️ **HOP 1 DIVIDIDO**: 2.6.4 → 2.7.5 causa erro "There was an error initializing DB"
✅ **Solução**: Quebrar em 2 hops intermediários conforme histórico da sessão 2026-03-24

```
2.6.4  → 2.7.0  → 2.7.5  → 2.8.4  → 2.9.4  → 2.10.4 → 2.11.4 → 2.12.3 →
2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

**Total de hops**: 14 (não 13)

---

## 🎯 EXECUÇÃO POR HOP

### HOP 1A: 2.6.4 → 2.7.0 (intermediário obrigatório)
**Status**: ❌ FALHOU + ROLLBACK EXECUTADO
**Início**: 19:53:28 UTC
**Término**: 20:09:14 UTC (rollback)
**Gate (15min)**: NÃO EXECUTADO (falha bloqueou progressão)
**Resultado**: ❌ ERRO DE MIGRAÇÃO DO BANCO
**Observação**: Migration "CreateSecretsProviderConnectionTables1769433700000" falhou - tabela já existe

**Problema identificado**:
- Erro: `relation "secrets_provider_connection" already exists`
- Causa: Schema contaminado de tentativa anterior de upgrade
- Impacto: Workflows não conseguem ativar (erro de autenticação)
- Correção aplicada: `DB_POSTGRESDB_STATEMENT_TIMEOUT=0` (eliminou erro statement_timeout)

**Rollback executado**:
- Backup utilizado: `/tmp/docker-compose.yaml.20260502T190647Z`
- Versão restaurada: 2.6.4
- Status pós-rollback: ✅ 9/9 containers UP, healthcheck 200 OK
- Documentação: `docs/SESSIONS/2026-05-02/ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md`

**Próximos passos**: Limpeza do schema do banco antes de tentar novamente

---

### HOP 1B: 2.7.0 → 2.7.5
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 2: 2.7.5 → 2.8.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 2: 2.7.5 → 2.8.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 3: 2.8.4 → 2.9.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 4: 2.9.4 → 2.10.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 5: 2.10.4 → 2.11.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 6: 2.11.4 → 2.12.3
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 7: 2.12.3 → 2.13.4
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 8: 2.13.4 → 2.14.2
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 9: 2.14.2 → 2.15.1
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 10: 2.15.1 → 2.16.2
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 11: 2.16.2 → 2.17.8
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 12: 2.17.8 → 2.18.5
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

### HOP 13: 2.18.5 → 2.19.1
**Status**: ⏳ Aguardando
**Início**:
**Término**:
**Gate (15min)**:
**Resultado**:

---

## 📊 MÉTRICAS E GATES

### Baseline (2.6.4)
- `critical_error_count`:
- `p95_execution_time_ms`:
- `avg_throughput_per_15min`:

### Critérios de Gate (GO/NO-GO)
- ✅ **GO**: `critical_error_count = 0` e regressão ≤ 10% vs baseline
- ❌ **NO-GO**: Erros críticos OU regressão > 10% → ROLLBACK imediato

---

## 🔄 PROCEDIMENTO POR HOP

1. **Pre-check**: Confirmar versão atual
2. **Update**: Atualizar tag no docker-compose.yaml
3. **Pull**: `docker compose pull`
4. **Up**: `docker compose up -d`
5. **Validate**: Confirmar versão em runtime
6. **Gate**: Aguardar 15 minutos e coletar métricas
7. **Decision**: GO → próximo hop | NO-GO → ROLLBACK

---

## 🚨 ROLLBACK

Procedimento em caso de NO-GO:
```bash
# 1. Parar containers
docker compose down

# 2. Restaurar compose anterior
sudo cp /tmp/docker-compose.yaml.<timestamp> docker-compose.yaml

# 3. Restartar versão anterior
docker compose up -d

# 4. Validar rollback
docker compose exec n8n n8n --version
```

---

## 📝 OBSERVAÇÕES

- Usar exclusivamente: `~/.local/bin/ssh-wfdb01`
- Diretório do stack: `/opt/docker_user/n8n`
- Validação obrigatória de workflows críticos ao final
- Documentar qualquer anomalia ou ajuste necessário
