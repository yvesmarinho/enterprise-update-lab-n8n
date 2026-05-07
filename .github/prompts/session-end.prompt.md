---
mode: agent
description: Ritual de encerramento de sessão. Execute ao finalizar o trabalho do dia.
---

# 🏁 Session End — Ritual de Encerramento de Sessão

> Execute este ritual **ao final de cada sessão** antes de sair do editor.
> Garante rastreabilidade, preserva contexto e mantém o repositório sincronizado.

---

## ▶️ Execução do Ritual

---

### Passo 1 — Consolidar Atividades do Dia

Atualizar `docs/SESSIONS/[YYYY-MM-DD]/DAILY_ACTIVITIES_[YYYY-MM-DD].md` com:

- Todas as tarefas executadas nesta sessão (concluídas e abandonadas)
- Decisões tomadas (com justificativa)
- Problemas encontrados e como foram resolvidos
- Artefatos criados ou modificados (com caminho)

**Formato recomendado para cada atividade:**
```markdown
### ✅ [Título da Atividade]

**Artefatos criados/modificados**:
| Arquivo | O que mudou |
|---------|-------------|
| `caminho/arquivo.py` | [descrição] |

**Destaques**: [pontos importantes para a próxima sessão]
```

---

### Passo 2 — Atualizar TODO.md

Em `docs/TODO.md`:

1. **Marcar concluídos**: `[ ]` → `[x]` para tudo finalizado nesta sessão
2. **Adicionar pendentes novos**: itens descobertos durante o trabalho
3. **Atualizar prioridades**: reordenar se necessário
4. **Atualizar o cabeçalho**:

```markdown
**Last Updated**: [YYYY-MM-DD] — [Título] ✅ Concluído
```

---

### Passo 3 — Criar FINAL_STATUS (se encerramento de sprint/milestone)

Se esta sessão encerrar uma fase importante, criar:
`docs/SESSIONS/[YYYY-MM-DD]/FINAL_STATUS_[YYYY-MM-DD].md`

```markdown
# 📊 Final Status — [YYYY-MM-DD]

**Branch**: [nome]
**Sessão**: [início] → [fim]

## Tarefas Concluídas Esta Sessão
- ✅ [descrição]

## Estado Geral
| Item | Título | Status |
|-----|--------|--------|
| 001 | ... | ✅ Concluído |
| 002 | ... | 🔄 Em progresso |
| 003 | ... | 🔵 Pendente |

## Próximas Ações (P0 para próxima sessão)
1. [ação]

## Decisões Técnicas desta Sessão
- [decisão]

## Contexto para Recuperação
[o que a próxima sessão precisa saber para continuar sem fricção]
```

---

### Passo 4 — Verificar Qualidade do Código (se aplicável)

Antes de commitar código Python:

```bash
uv run pytest                          # testes passando?
uv run black --check scripts/         # formatação OK?
uv run flake8 scripts/                # lint OK?
```

Se houver falhas: corrigir antes de commitar ou documentar como `TODO` rastreado.

---

### Passo 5 — Session Security Review & Scan Final

#### 5.1 — Session Documentation Security Review

**CRÍTICO**: Revisar documentos de sessão antes de commitar para garantir que nenhum dado sensível foi exposto:

**Arquivos a revisar**:
- `docs/SESSIONS/[YYYY-MM-DD]/DAILY_ACTIVITIES_[YYYY-MM-DD].md`
- `docs/SESSIONS/[YYYY-MM-DD]/SESSION_RECOVERY_[YYYY-MM-DD].md`
- `docs/SESSIONS/[YYYY-MM-DD]/FINAL_STATUS_[YYYY-MM-DD].md` (se existir)

**Checklist de segurança para session docs**:

- [ ] ❌ **Credenciais**: Sem senhas, API keys, tokens, certificados
- [ ] ❌ **IPs/URLs**: Sem IPs privados, URLs de produção, endpoints internos
- [ ] ❌ **Dados pessoais**: Sem emails reais, nomes de clientes, CPF/CNPJ
- [ ] ❌ **Vulnerabilidades**: Sem descrição de falhas de segurança não corrigidas
- [ ] ✅ **Exemplos sanitizados**: Usar `user@example.com`, `192.0.2.1`, `api.exemplo.local`
- [ ] ✅ **Placeholders**: Usar `<TOKEN>`, `<API_KEY>`, `***` em exemplos

**Resultado esperado**:
```
🟢 Session docs security review: PASSED
   ✅ No credentials found
   ✅ No internal IPs/URLs exposed
   ✅ All examples sanitized
```

---

#### 5.2 — Source Code & Staging Area Security Scan

Último check antes do commit:

```
Padrões: *.env, .env*, *.key, *.pem, *secret*, *password*, *token*, *.log
Excluir: .git/, .secrets/
```

**Se encontrar algo**: remover do staging, adicionar ao `.gitignore`, corrigir antes de prosseguir.

---

### Passo 6 — Preparar Commit

**Regra P0**: usar arquivo de mensagem. Nunca `git commit -m "..."`.

```bash
# Verificar o que vai ser commitado
git status
git diff --staged

# Preparar mensagem de commit
cat > /tmp/git-msg.txt << 'EOF'
[tipo]: [descrição curta]

Artefatos criados/modificados:
- caminho/arquivo1.py: [o que mudou]
- caminho/arquivo2.md: [o que mudou]

Decisões: [se houver]
Pendente: [o que ficou para próxima sessão]
EOF

# Revisar a mensagem
cat /tmp/git-msg.txt
```

**Tipos de commit** (Conventional Commits):
| Tipo | Quando usar |
|------|-------------|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Apenas documentação |
| `refactor:` | Refatoração sem mudança de comportamento |
| `chore:` | Tarefas de manutenção (deps, config) |

---

### Passo 7 — Commitar e Fazer Push

```bash
# Adicionar e commitar
git add -A
git commit -F /tmp/git-msg.txt

# Verificar o commit
git log --oneline -3

# Push
git push origin [branch]

# Confirmar push bem-sucedido
git status
```

---

### Passo 8 — Atualizar INDEX.md (se novos arquivos criados)

Se novos arquivos importantes foram criados, atualizar `docs/INDEX.md`:

```markdown
## [Seção relevante]
- [`caminho/arquivo.ext`](../caminho/arquivo.ext) — [descrição]
```

---

## ✅ Checklist de Encerramento

### Documentação
- [ ] `DAILY_ACTIVITIES_[data].md` completo
- [ ] `docs/TODO.md` atualizado
- [ ] `FINAL_STATUS_[data].md` criado (se fase encerrada)
- [ ] `docs/INDEX.md` atualizado (se novos arquivos)

### Qualidade
- [ ] Testes passando (se código modificado)
- [ ] Session docs security review: 🟢 PASSED
- [ ] Scan de segurança final: 🟢 LIMPO

### Git
- [ ] `git status` revisado
- [ ] Mensagem preparada em `/tmp/git-msg.txt`
- [ ] `git commit -F /tmp/git-msg.txt` executado
- [ ] `git push` executado
- [ ] `git status` pós-push: "up to date"

---

## 🔄 Contexto para Próxima Sessão

Deixar registrado em `FINAL_STATUS` ou `DAILY_ACTIVITIES`:

1. **Onde parou**: arquivo + linha se possível
2. **Próximo passo imediato**: o que fazer ao abrir
3. **Decisões pendentes**: o que precisa de confirmação
4. **Riscos/bloqueios**: o que pode impedir progresso

---

*Session End Prompt — enterprise-update-lab-n8n*
