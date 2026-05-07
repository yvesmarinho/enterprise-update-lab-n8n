---
mode: agent
description: Ritual de primeira sessão em um projeto novo ou recém-clonado. Use apenas na primeira vez.
---

# 🌱 Session Start (First Time) — Ritual de Primeira Sessão

> Use este ritual apenas na **primeira sessão** em um projeto novo ou recém-clonado.
> Para sessões subsequentes, use `session-start.prompt.md`.

---

## ▶️ Execução do Ritual

---

### Passo 1 — Verificar Pré-requisitos

Confirmar ferramentas disponíveis:

```bash
uv --version          # deve existir (PEP 723 runner)
git --version
python3 --version     # ≥ 3.10
```

Se `uv` não estiver instalado:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

### Passo 2 — Verificar Configuração MCP

**Ação do agente**: ler `.vscode/mcp.json` e confirmar que os servidores estão configurados:
- `memory`
- `sequential-thinking`
- `filesystem`
- `github`

```
✅ MCP Config OK — memory ✅ | sequential-thinking ✅ | filesystem ✅ | github ✅
```

> Para verificar se os servidores estão *em execução*: `Command Palette → "MCP: List Servers"`. Se não aparecerem: `Command Palette → "MCP: Refresh Servers"`.

---

### Passo 3 — Carregar Regras Copilot

Ler e confirmar carregamento:
1. `.copilot-rules-enterprise-update-lab-n8n.md` (regras específicas do projeto)
2. `.copilot-rules.md` (regras genéricas — sempre prevalece em conflitos)

**Regras P0 que devem estar ativas:**

| Regra | Status |
|-------|--------|
| Nunca heredoc/echo para criar arquivos | ✅ Ativo |
| Nunca cat/grep/find/ls via terminal | ✅ Ativo |
| Git com arquivo de mensagem | ✅ Ativo |
| Docs de sessão em `docs/SESSIONS/YYYY-MM-DD/` | ✅ Ativo |

---

### Passo 4 — Scan de Segurança Inicial

Verificar que nenhum arquivo sensível está exposto:

```
Padrões: *.env, .env*, *.key, *.pem, *secret*, *password*, *token*, *.log
Excluir: .git/, .secrets/
```

**Resultado esperado**: `🟢 LIMPO`

Verificar também:
- `.gitignore` contém `.secrets/`, `*.env`, `*.key`, `.DS_Store`, `__pycache__/`

---

### Passo 5 — Criar Documentação Inicial de Sessão

Criar pasta e arquivos da primeira sessão:

```
docs/SESSIONS/[YYYY-MM-DD]/
├── SESSION_RECOVERY_[YYYY-MM-DD].md   ← "Primeira sessão — projeto inicializado"
└── DAILY_ACTIVITIES_[YYYY-MM-DD].md   ← log do que foi feito
```

**Template SESSION_RECOVERY (primeira sessão)**:
```markdown
# 🔄 Session Recovery — [YYYY-MM-DD]

**Primeira sessão no projeto**

## Objetivo do Projeto
enterprise-update-lab-n8n — Laboratório para atualização de versão do N8N

## Domínio
Infrastructure | DevOps

## Configuração Inicial
- MCP servers: memory, sequential-thinking, filesystem, github
- Regras Copilot: carregadas e ativas
- Segurança: .secrets/ protegido

## Itens P0 para Esta Sessão
[lista do docs/TODO.md]
```

---

### Passo 6 — Verificar Estado do Repositório

```bash
git status
git log --oneline -5
git remote -v
```

Confirmar:
- Branch ativa correta
- Remote configurado
- Nenhum arquivo staged inesperadamente

---

### Passo 7 — Declarar Domínio e Objetivo

```
Modo: INFRASTRUCTURE
Projeto: enterprise-update-lab-n8n
Domínio: DevOps Infrastructure | Python automation
Objetivo desta primeira sessão: [definir com usuário]
```

Carregar Domain Profile:
- `.github/prompts/domain/devops-infrastructure.prompt.md`

---

### Passo 8 — Atualizar TODO.md

Criar ou atualizar `docs/TODO.md` com os primeiros itens de trabalho identificados.

---

### Passo 9 — Relatório de Primeira Sessão

```
🌱 First Session Setup Complete — [YYYY-MM-DD]

✅ Pré-requisitos: uv, git, python3
✅ MCP: 4 servidores configurados e prontos
✅ Regras: copilot-rules carregado
✅ Segurança: scan OK, .secrets/ protegido
✅ Docs: estrutura de sessão criada
✅ Domain Profile: devops-infrastructure

Projeto pronto para iniciar trabalho.
```

---

*Session Start First Prompt — enterprise-update-lab-n8n*
