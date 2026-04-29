# Análise de Atualizações N8N — 2026-04-29

## Resumo Executivo

**Data da análise**: 2026-04-29
**Última versão disponível**: 2.19.1 (atualizada hoje!)

### Ambientes

**🔬 LABORATÓRIO (wfdb01)**:
- **Versão atual**: 2.13.2
- **Função**: Validação de upgrades antes de produção
- **Gap**: 6 versões minor (2.14 até 2.19)
- **Status**: Up 3 weeks (4 containers ativos)

**🏭 PRODUÇÃO**:
- **Versão atual**: 2.6.4 (baseline original)
- **Função**: Ambiente de produção (não atualizado desde início do projeto)
- **Gap**: 13 versões minor (2.7 até 2.19)
- **Próxima atualização**: Aguardando validação completa no lab

## Versão Atual no Laboratório (wfdb01)

**Host**: wfdb01
**Função**: 🔬 Laboratório de upgrade
**Containers**: 4 containers ativos (editor, worker, webhook, mcp)
**Status**: Up 3 weeks
**Imagem**: n8nio/n8n:2.13.2

```bash
# Verificação executada
ssh wfdb01 'docker inspect n8n-n8n_editor-1 --format "{{.Config.Image}}"'
# Resultado: n8nio/n8n:2.13.2
```

## Mapa Completo de Versões Disponíveis (2.6 até 2.19)

### Série 2.6 (🏭 PRODUÇÃO ATUAL)
- **Primeira**: 2.6.0
- **Atual em Produção**: 2.6.4 ← **🏭 BASELINE PRODUÇÃO**
- **Última**: 2.6.4
- **Total de versões**: 5

### Série 2.7
- **Primeira**: 2.7.0
- **Última**: 2.7.5
- **Total de versões**: 6

### Série 2.8
- **Primeira**: 2.8.0
- **Última**: 2.8.4
- **Total de versões**: 5

### Série 2.9
- **Primeira**: 2.9.0
- **Última**: 2.9.4
- **Total de versões**: 5

### Série 2.10
- **Primeira**: 2.10.0
- **Última**: 2.10.4
- **Total de versões**: 5

### Série 2.11
- **Primeira**: 2.11.0
- **Última**: 2.11.4
- **Total de versões**: 5

### Série 2.12
- **Primeira**: 2.12.0
- **Última**: 2.12.3
- **Total de versões**: 4

### Série 2.13 (🔬 LAB ATUAL)
- **Primeira**: 2.13.0 (2026-03-16)
- **Atual no Lab**: 2.13.2 (2026-03-20) ← **🔬 BASELINE LAB**
- **Última**: 2.13.4 (2026-03-26)
- **Total de versões**: 5 (2.13.0, 2.13.1, 2.13.2, 2.13.3, 2.13.4)

### Série 2.14
- **Primeira**: 2.14.0
- **Última**: 2.14.2
- **Total de versões**: 3

### Série 2.15
- **Primeira**: 2.15.0
- **Última**: 2.15.1
- **Total de versões**: 2

### Série 2.16
- **Primeira**: 2.16.0
- **Última**: 2.16.2
- **Total de versões**: 3

### Série 2.17
- **Primeira**: 2.17.0
- **Última**: 2.17.8 (2026-04-27)
- **Total de versões**: 9

### Série 2.18
- **Primeira**: 2.18.0
- **Última**: 2.18.5 (2026-04-29)
- **Total de versões**: 6

### Série 2.19 (MAIS RECENTE)
- **Primeira**: 2.19.0 (2026-04-28)
- **Última**: 2.19.1 (2026-04-29) ← **LATEST**
- **Total de versões**: 2

## Trilhas de Upgrade

De acordo com a política de upgrade sequencial estabelecida no projeto, o caminho deve seguir a última versão patch de cada série minor.

### 🏭 Trilha COMPLETA — Para Produção (2.6.4 → 2.19.1)

**Quando aplicar**: Após validação completa no laboratório
**Origem**: 2.6.4 (baseline de produção)
**Alvo**: 2.19.1
**Total de hops**: 13
**Tempo estimado**: ~195 minutos (15 min/hop)

```
2.6.4  → 2.7.5  → 2.8.4  → 2.9.4  → 2.10.4 → 2.11.4 → 2.12.3 →
2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

**Séries cobertas**:
- 2.6 (5 versões) → 2.7 (6 versões) → 2.8 (5 versões) → 2.9 (5 versões)
- 2.10 (5 versões) → 2.11 (5 versões) → 2.12 (4 versões) → 2.13 (5 versões)
- 2.14 (3 versões) → 2.15 (2 versões) → 2.16 (3 versões) → 2.17 (9 versões)
- 2.18 (6 versões) → 2.19 (2 versões)

**⚠️ IMPORTANTE**: Esta trilha deve ser executada INTEGRALMENTE em produção, sem pular versões.

---

### 🔬 Trilha COMPLEMENTAR — Para Laboratório (2.13.2 → 2.19.1)

**Quando aplicar**: ✅ **CONCLUÍDA em 2026-04-29**
**Origem**: 2.13.2 (baseline do lab em 2026-03-25)
**Alvo**: 2.19.1 ✅ **ALCANÇADO**
**Total de hops**: 8/8 ✅
**Tempo real**: ~89 minutos (~1h29min)

#### Fase 1: Completar série 2.13 ✅
1. **2.13.2 → 2.13.3** ✅ Executado 2026-04-29 15:00 (~10 min)
2. **2.13.3 → 2.13.4** ✅ Executado 2026-04-29 15:10 (~3 min)

#### Fase 2: Upgrade para série 2.14 ✅
3. **2.13.4 → 2.14.2** ✅ Executado 2026-04-29 15:20 (~12 min) *

#### Fase 3: Upgrade para série 2.15 ✅
4. **2.14.2 → 2.15.1** ✅ Executado 2026-04-29 15:30 (~10 min)

#### Fase 4: Upgrade para série 2.16 ✅
5. **2.15.1 → 2.16.2** ✅ Executado 2026-04-29 15:40 (~12 min)

#### Fase 5: Upgrade para série 2.17 ✅
6. **2.16.2 → 2.17.8** ✅ Executado 2026-04-29 15:50 (~15 min)

#### Fase 6: Upgrade para série 2.18 ✅
7. **2.17.8 → 2.18.5** ✅ Executado 2026-04-29 16:05 (~12 min)

#### Fase 7: Upgrade para série 2.19 (ALVO FINAL) ✅
8. **2.18.5 → 2.19.1** ✅ Executado 2026-04-29 16:20 (~15 min)

**\* Hop 3 teve conflito de containers, resolvido com `docker container prune -f`**

**Status Final**:
- ✅ N8N Lab (wfdb01): **2.19.1** (latest)
- ✅ Todos 4 containers UP e saudáveis
- ✅ N8N ativo, workflows sem erros
- ✅ 8 backups timestamped criados em `/tmp`
- ✅ Procedimento completo documentado

**Observações da Execução**:
- Padrão estabelecido: backup → sed → down → pull → up → verify
- Média de ~230 MB por imagem Docker
- Download ~2-3 minutos por hop
- Cleanup preemptivo evitou conflitos (exceto hop 3)
- SSH wrapper funcionou bem após ajustes

---

## Mapa Completo de Versões Disponíveis (2.6 até 2.19)

### Fase 6: Upgrade para série 2.18
7. **2.17.8 → 2.18.5** (última da série 2.18)

### Fase 7: Upgrade para série 2.19 (ALVO ATUAL)
8. **2.18.5 → 2.19.1** (versão mais recente)

**Total de hops**: 8
**Tempo estimado**: ~120 minutos (15 min/hop)
**Janela de manutenção**: 3-4 horas (incluindo contingência)

## Histórico de Validação no Laboratório

### Trilha Executada no Lab (2.6.4 → 2.13.2)

**Período**: Março 2026
**Status**: ✅ Completada até 2.13.2
**Validação final**: 2026-03-25

```
2.6.4 → 2.7.0 → 2.7.5 → 2.8.4 → 2.9.4 → (bloqueio) → ... → 2.13.2
```

**Observações**:
- ⚠️ Bloqueio temporário no hop 2.9.4 → 2.10.4 (pull não concluiu, resolvido posteriormente)
- ✅ Procedimento de rollback testado e validado
- ✅ Baseline 2.13.2 estável e operacional
- ⚠️ **IMPORTANTE**: Esta validação foi feita no LABORATÓRIO, não em produção

### Trilha Complementar (2.13.2 → 2.19.1)

**Período**: Abril 2026 (em andamento)
**Status**: 🔄 Iniciada

```
2.13.2 → 2.13.3 → 2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 → 2.17.8 → 2.18.5 → 2.19.1
```

**Objetivo**: Validar versões mais recentes antes de aplicar trilha completa em produção

## Riscos Identificados

### Alto — Laboratório (Trilha Complementar)
- **Gap de 6 versões minor** (2.14 → 2.19): Mudanças acumuladas significativas
- **Breaking changes potenciais**: Cada minor pode introduzir incompatibilidades
- **Tempo de janela**: 8 hops × 15min = ~2h + contingência

### Alto — Produção (Trilha Completa)
- **Gap de 13 versões minor** (2.6 → 2.19): Enorme quantidade de mudanças
- **Migração de dados**: Múltiplas migrações de banco de dados acumuladas
- **Tempo de janela estendido**: 13 hops × 15min = ~3.5h + contingência
- **⚠️ CRÍTICO**: TODAS as versões devem ser executadas sequencialmente

### Médio
- **Compatibilidade de workflows**: Validação funcional em cada hop
- **Performance regression**: Monitoramento de p95 e throughput
- **Database migrations**: Cada versão pode ter migrações complexas

### Baixo
- **Rollback testado**: Procedimento validado em sessões anteriores
- **Ambiente de teste**: wfdb01 disponível para validação

## Recomendações

### 🔬 Laboratório — Imediatas (Esta Semana)

1. ✅ **Executar hop 2.13.2 → 2.13.3** no lab (wfdb01)
   - Baixo risco (patch version)
   - Valida procedimento atualizado
   - Tempo estimado: 15-20 minutos

2. 🔄 **Completar série 2.13** antes de avançar
   - Hop adicional: 2.13.3 → 2.13.4
   - Total: 2 hops, ~30 minutos

3. 📊 **Estabelecer baseline de performance**
   - Coletar métricas por 15 minutos na versão 2.13.4
   - Definir workflows críticos
   - Documentar p95 e throughput

4. 🚀 **Executar trilha complementar completa no lab**
   - 6 hops restantes: 2.13.4 → 2.19.1
   - Documentar evidências de cada hop
   - Validar compatibilidade e performance

### 🏭 Produção — Curto/Médio Prazo

5. 📋 **Planejar janela de manutenção COMPLETA**
   - **Duração**: 4-5 horas (13 hops + validações + contingência)
   - **Trilha**: 2.6.4 → 2.19.1 (COMPLETA, sem pular versões)
   - **Pré-requisito**: Trilha complementar validada no lab
   - **Aprovação**: Change management formal

6. 📝 **Preparar documentação de produção**
   - RUNBOOK_PRODUCAO_N8N.md com nova trilha
   - specs/002-update-all-specs/ com versões atualizadas

### Médio Prazo
5. 🤖 **Automatizar processo de upgrade**
   - Script Python para execução sequencial
   - Validação automática de gates
   - Coleta automática de métricas

6. 📊 **Estabelecer baseline de performance** antes do upgrade
   - Coletar métricas por 15 minutos na versão 2.13.2
   - Definir thresholds para cada hop
   - Documentar workflows críticos

---

## Resumo Estratégico

### 🎯 Estratégia de Dois Ambientes

```
┌─────────────────────────────────────────────────────────────┐
│                   LABORATÓRIO (wfdb01)                      │
│                                                             │
│  Versão Atual: 2.13.2                                       │
│  Função: Validação de upgrades                              │
│                                                             │
│  Trilha Complementar (8 hops):                              │
│  2.13.2 → 2.13.3 → 2.13.4 → 2.14.2 → 2.15.1 →              │
│  2.16.2 → 2.17.8 → 2.18.5 → 2.19.1                         │
│                                                             │
│  Status: 🔄 Em andamento                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Validação completa
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       PRODUÇÃO                              │
│                                                             │
│  Versão Atual: 2.6.4                                        │
│  Função: Ambiente produtivo                                 │
│                                                             │
│  Trilha Completa (13 hops):                                 │
│  2.6.4 → 2.7.5 → 2.8.4 → 2.9.4 → 2.10.4 → 2.11.4 →        │
│  2.12.3 → 2.13.4 → 2.14.2 → 2.15.1 → 2.16.2 →             │
│  2.17.8 → 2.18.5 → 2.19.1                                  │
│                                                             │
│  Status: ⏸️ Aguardando validação do lab                      │
└─────────────────────────────────────────────────────────────┘
```

### ⚠️ Pontos Críticos

1. **NUNCA pular versões em produção**
   - A trilha completa deve ser executada integralmente
   - Todas as 13 versões intermediárias são obrigatórias

2. **Lab ≠ Produção**
   - Lab está em 2.13.2 (já percorreu 2.6.4 → 2.13.2)
   - Produção está em 2.6.4 (baseline original)

3. **Validação antes de produção**
   - Completar trilha complementar no lab primeiro
   - Documentar evidências de cada hop
   - Só então executar trilha completa em produção

---

## Próximos Passos

### 🔬 Laboratório — Hoje (2026-04-29)
- [x] Verificar versão atual em wfdb01: 2.13.2 ✅
- [x] Consultar versões disponíveis: até 2.19.1 ✅
- [x] Mapear caminho de upgrade completo ✅
- [x] Atualizar RUNBOOK_PRODUCAO_N8N.md ✅
- [ ] Executar teste: hop 2.13.2 → 2.13.3 ⚠️ (bloqueado)

### 🔬 Laboratório — Próxima Sessão
- [ ] **Verificar estado atual do ambiente** (urgente!)
- [ ] Completar hop 2.13.2 → 2.13.3 (se não completou)
- [ ] Validar baseline de performance em 2.13.2
- [ ] Completar série 2.13 (→ 2.13.4)
- [ ] Executar trilha complementar completa (→ 2.19.1)
- [ ] Documentar evidências de todos os hops

### 🏭 Produção — Curto/Médio Prazo
- [ ] Aguardar validação completa no lab
- [ ] Planejar janela de manutenção (4-5 horas)
- [ ] Obter aprovação de change management
- [ ] Preparar comunicação para stakeholders
- [ ] Executar trilha COMPLETA: 2.6.4 → 2.19.1 (13 hops)
- [ ] Validar ambiente de produção pós-upgrade

## Referências

- **Docker Hub N8N**: https://hub.docker.com/r/n8nio/n8n/tags
- **Lab (wfdb01)**: 2.13.2 → 2.19.1 (trilha complementar)
- **Produção**: 2.6.4 → 2.19.1 (trilha completa)
- **Ambiente Lab**: wfdb01:/opt/docker_user/n8n
- **Procedimento**: RUNBOOK_PRODUCAO_N8N.md

---

**Análise executada por**: GitHub Copilot (Claude Sonnet 4.5)
**Data**: 2026-04-29
**Sessão**: docs/SESSIONS/2026-04-29/
**Revisão**: Trilhas separadas — Lab (complementar) vs Produção (completa)
