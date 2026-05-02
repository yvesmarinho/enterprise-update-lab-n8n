# 📝 TODO — Enterprise Update Lab N8N

**Last Updated**: 2026-05-02
**Status**: 🔴 Bloqueado — Schema PostgreSQL contaminado

---

## 🔴 Bloqueadores Críticos (P0)

- [ ] **Limpar schema PostgreSQL contaminado** (bloqueador para HOP 1A retry)
  - Executar: `DROP TABLE IF EXISTS secrets_provider_connection CASCADE;`
  - Validar: tabela removida e schema consistente
  - Documentar estado antes e depois da limpeza
  - Prioridade: P0 — sem isso, nenhum hop pode prosseguir

- [ ] **Verificar status do restore de credenciais** (bloqueador para workflows)
  - Query: `SELECT COUNT(*) FROM credentials_entity;`
  - Esperado: 61 credenciais (ou próximo disso)
  - Se incompleto: retry do restore ou import manual via interface
  - Prioridade: P0 — workflows podem estar quebrados sem credenciais

---

## 🟠 Em Progresso

- [x] Transformar pendencias herdadas em plano operacional objetivo da sessao 2026-03-25
- [x] Iniciar stack n8n no host remoto e validar saude curta sem erros criticos
- [x] Rebaselinar trilha operacional para runtime atual `2.13.2` antes de novo hop
- [x] Executar hop controlado `2.13.2 -> 2.13.3` com gate oficial de 15 minutos (sessão 2026-04-29)
- [x] Mapear versões N8N disponíveis (2.6.0 até 2.19.1) e definir trilhas Lab vs Produção (sessão 2026-04-29)
- [x] Executar trilha complementar LAB completa: 2.13.2 → 2.19.1 (8 hops, 100% sucesso) (sessão 2026-04-29)
- [x] Criar script de automação upgrade_n8n_hop.py para upgrades controlados (sessão 2026-04-29)
- [ ] Validação funcional extensiva no N8N Lab 2.19.1 (workflows críticos, performance, integrações)
- [x] Planejar trilha COMPLETA em Produção: 2.6.4 → 2.19.1 (14 hops, não 13)
- [x] Executar pre-pull de todas as 14 imagens da trilha (otimização de tempo) — 2026-05-02
- [ ] **Retry HOP 1A: 2.6.4 → 2.7.0** (pendente limpeza de schema) — 2026-05-02 FAILED
- [ ] Executar HOP 1B: 2.7.0 → 2.7.5 (bloqueado por HOP 1A)
- [ ] Completar trilha de 12 hops restantes: 2.7.5 → 2.19.1
- [x] Analisar causa raiz de falha no hop 2.7.0 — 2026-05-02 COMPLETO
- [x] Executar rollback para 2.6.4 após falha de migration — 2026-05-02 COMPLETO
- [x] Download de 61 credenciais de backup para restore — 2026-05-02 COMPLETO
- [ ] Validar baseline de metricas da rodada (p95, throughput, critical_error_count)
- [ ] Em caso de NO-GO, executar rollback imediato e consolidar evidencia tecnica do bloqueio
- [ ] Consolidar amostra quantitativa final (p95/throughput) para o proximo gate de tentativa
- [x] Preparar fechamento final da sessão 2026-03-24 com evidências operacionais válidas
- [x] Abrir sessão 2026-03-25 com plano de investigação de DB init failure no hop 2.7.5
- [x] Analisar historico de atualizacoes anteriores e extrair melhor pratica para proxima tentativa
- [x] Revalidar encerramento da sessao 2026-03-24 sob solicitacao (end.session)
- [x] Validar permissao DDL (CREATE/ALTER/INDEX) do usuario efetivo do n8n no schema alvo
- [ ] Validar estado da tabela de migracoes e ultimo migration id aplicado na baseline 2.6.4
- [ ] Executar tentativa controlada com captura completa de stacktrace de inicializacao de DB
- [ ] Revisar alinhamento minimo do compose com referencia oficial `n8n-hosting/withPostgresAndWorker`
- [ ] Executar pre-check reforcado (DB, migracoes, compose, prontidao de rollback)

---

## 🔵 Pendente

- [ ] Configurar estrutura inicial do projeto
- [ ] Adicionar testes unitários
- [ ] Documentar APIs
- [ ] Atualizar RUNBOOK com lições aprendidas da sessão 2026-05-02:
  - Procedimento de limpeza de schema contaminado
  - Pre-check de tabelas órfãs antes de upgrades
  - Procedimento de restore de credenciais testado
  - Otimização de pre-pull de imagens

---

## ✅ Concluído

- [x] Scaffold inicial gerado (2026-03-20T18:44:10Z)
- [x] Atualizacao global das especificacoes da feature 002 concluida (2026-03-23)
- [x] Commit inicial consolidando baseline documental da sessao (2026-03-23)
- [x] Sessao 2026-03-24 iniciada com documentos de abertura criados
- [x] Executar rodada final de análise cruzada (spec/plan/tasks) da feature 002
- [x] Consolidar evidências documentais dos checkpoints para handoff operacional
- [x] Preparar handoff operacional controlado da feature 002
- [x] Remediar bloqueios G1/G2/G3/I1 da análise cruzada final da feature 002
- [x] Reexecutar análise cruzada final após remediação com resultado PASS
- [x] Iniciar execução operacional controlada por checkpoints da atualização
- [x] Coletar primeira janela real de evidências do CP-001-BASELINE
- [x] Executar remediação operacional de falhas de ativação/autenticação do CP-001
- [x] Reexecutar janela oficial de 15 minutos com `critical_error_count=0` no CP-001
- [x] Iniciar processo de atualização com primeiro hop e pre-pull da imagem alvo
- [x] Padronizar execução remota com `~/.local/bin/ssh-wfdb01` conforme `.secrets/ssh.json`
- [x] Validar objetivamente hop 2.6.4 -> 2.7.5 e aplicar rollback para 2.6.4 após NO-GO
- [x] Revalidar oficialmente o gate de 15 minutos no hop 2.7.5 (resultado: NO-GO)
- [x] Executar analise de gap tecnico 2.6.4 -> 2.7.5 para confirmar existencia de migracoes de banco
- [x] Analisar historico de atualizacoes anteriores e extrair melhor pratica para proxima tentativa
- [x] Revalidar encerramento da sessao 2026-03-24 sob solicitacao (end.session)
- [x] Sessão 2026-04-29: Upgrade completo N8N Lab 2.13.2 → 2.19.1 (8 hops, 100% sucesso)
- [x] Documentação completa trilha Lab (DAILY_ACTIVITIES, SESSION_REPORT, VERSION_UPDATE_ANALYSIS)
- [x] Mapeamento versões N8N: 60+ versões de 2.6.0 até 2.19.1 (14 séries minor)
- [x] Criação script automação: scripts/upgrade_n8n_hop.py (~350 linhas)
- [x] Definição clara de duas trilhas: Lab (complementar 8 hops) vs Produção (completa 14 hops)
- [x] Sessão 2026-05-02: Pre-pull de 14 imagens Docker (redução de ~15min/hop)
- [x] Sessão 2026-05-02: Tentativa HOP 1A executada (2.6.4 → 2.7.0) — FAILED
- [x] Sessão 2026-05-02: Análise de causa raiz — schema contaminado identificado
- [x] Sessão 2026-05-02: Rollback completo para 2.6.4 executado com sucesso
- [x] Sessão 2026-05-02: Download de 61 credenciais de backup concluído
- [x] Sessão 2026-05-02: Documentação completa de falha criada (ANALISE_FALHA_HOP_2.6.4-2.7.0_2026-05-02.md)

---

## 🔵 Pendente (Feature 002)

- [x] Validar e fechar rodada final de análise cruzada (spec/plan/tasks)
- [ ] Consolidar evidências operacionais reais dos checkpoints na fase de execução (tentativa de hop 2.7.5 em NO-GO e rollback executado)
- [x] Preparar handoff para execução operacional em ambiente controlado

---

## 🔵 Pendente (Fechamento de Repositorio)

- [x] Criar commit inicial consolidando baseline documental da sessao
