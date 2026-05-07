---
mode: agent
description: Ritual de início de sessão recorrente. Execute no começo de cada sessão de trabalho.
---

# 🚀 Session Start — Ritual de Início de Sessão

> Execute este ritual **no início de cada sessão** (não da primeira — para primeira sessão use `session-start-first.prompt.md`).

---

## ▶️ Execução do Ritual

Execute os passos abaixo em ordem. Confirme cada etapa antes de avançar.

---

### Passo 1 — Verificar Configuração MCP

**Ação do agente**: ler `.vscode/mcp.json` e confirmar que os servidores abaixo estão configurados e **não comentados**:

| Servidor | Propósito |
|----------|-----------|
| `memory` | Memória persistente entre sessões |
| `sequential-thinking` | Raciocínio estruturado |
| `filesystem` | Acesso controlado a arquivos |
| `github` | Integração com GitHub (issues, PRs, code search) |

Resultado esperado:
```
✅ MCP Config OK — memory ✅ | sequential-thinking ✅ | filesystem ✅ | github ✅
```

Se algum servidor estiver ausente ou comentado no arquivo → reportar e instruir o usuário a descomentar e executar `Command Palette → "MCP: Refresh Servers"`.

> **Nota**: verificar se os servidores estão *em execução* no VS Code requer ação manual do usuário: `Command Palette → "MCP: List Servers"`. O agente verifica apenas a configuração em arquivo.

---

### Passo 2 — Recuperar Contexto da Sessão Anterior

Leia os seguintes arquivos na ordem indicada:

1. `docs/TODO.md` — estado atual de todas as tarefas
2. `docs/INDEX.md` — mapa de arquivos importantes
3. `docs/SESSIONS/[YYYY-MM-DD mais recente]/FINAL_STATUS_*.md` — estado final da última sessão
4. `docs/SESSIONS/[YYYY-MM-DD mais recente]/DAILY_ACTIVITIES_*.md` — atividades detalhadas
5. `.copilot-rules-enterprise-update-lab-n8n.md` — regras ativas do projeto
6. `.copilot-rules.md` — regras genéricas (Camada 1, sempre prevalecem)

**Ao final deste passo, declare:**
```
✅ Contexto recuperado. Última sessão: [data].
Itens pendentes de alta prioridade: [lista dos P0/P1 do TODO.md].
Regras ativas carregadas: .copilot-rules.md [N] linhas, [N] seções.
```

---

### Passo 3 — Carregar Regras Copilot

Confirmar que `.copilot-rules-enterprise-update-lab-n8n.md` está ativo e suas regras P0 estão na memória:

| Regra | Verificado |
|-------|-----------|
| P0: Nunca heredoc/echo para criar arquivos | ✅ |
| P0: Nunca cat/grep/find/ls via terminal (usar ferramentas nativas) | ✅ |
| P0: Mover arquivos com Python stdlib (shutil.move) | ✅ |
| P0: Git com arquivo de mensagem (≥6 linhas) | ✅ |
| P1: Docs de sessão em `docs/SESSIONS/YYYY-MM-DD/` | ✅ |

---

### Passo 4 — Scan de Segurança

Verificar ausência de credenciais ou arquivos sensíveis fora de `.secrets/`:

Padrões a verificar (excluindo `.git/` e `.secrets/`):
```
*.env, .env*, *.key, *.pem, *.crt, *.p12
*secret*, *password*, *token*, *credentials*, *.log
```

**Resultado esperado**: `🟢 LIMPO — nenhum arquivo sensível fora de .secrets/`

Se encontrar algo: **PARAR e reportar antes de continuar.**

Verificar também:
- `.secrets/` está no `.gitignore` ✅
- Nenhum valor real em `.env.example` (apenas placeholders)

---

### Passo 5 — Verificar Estado do Projeto

```bash
git status          # arquivos modificados não commitados
git log --oneline -5   # últimos 5 commits
```

**Interpretar:**
- Arquivos inesperadamente modificados → investigar antes de continuar
- Branch ativa diferente do esperado → confirmar com usuário
- Muitos commits não pushados → sugerir `git push` antes de iniciar

---

### Passo 6 — Criar Documentos de Sessão e Carregar Protocolo

Criar os arquivos de sessão do dia (se ainda não existirem):

**Caminho**: `docs/SESSIONS/[YYYY-MM-DD]/`

Arquivos a criar:
1. `SESSION_RECOVERY_[YYYY-MM-DD].md` — resumo do contexto recuperado
2. `DAILY_ACTIVITIES_[YYYY-MM-DD].md` — log de atividades (será preenchido durante a sessão)

**Template SESSION_RECOVERY**:
```markdown
# 🔄 Session Recovery — [YYYY-MM-DD]

**Sessão anterior**: [data]
**Branch**: [branch ativa]
**Status geral**: [resumo breve]

## Contexto Recuperado
[resumo do que foi feito anteriormente]

## Itens P0 para Esta Sessão
[lista do TODO.md]
```

**Protocolo de Documentação Incremental**:

Durante a sessão, o agente deve **atualizar incrementalmente** `DAILY_ACTIVITIES_[YYYY-MM-DD].md`.

**Regras de documentação durante a sessão**:

1. **Quando documentar**: Após completar atividades significativas (>= 10 linhas de código, decisões técnicas, criação/modificação de documentação estrutural)

2. **Formato obrigatório**: Usar template canônico com separador `---` e campos estruturados:
   ```markdown
   ---

   ### [Título da Atividade]

   **HH:MM — [STATUS]**

   **Objetivo**: [O que foi feito]
   **Contexto**: [Por que foi necessário]
   **Passos executados**:
   1. [Passo 1 com ferramenta usada]
   2. [Passo 2 com comando executado]

   **Resultado**: [Outcome — sucesso/bloqueio/aprendizado]
   **Arquivos modificados/criados**:
   - path/to/file.py (+N/-N)

   **Commits**: [hash] [mensagem]
   ```

---

### Passo 7 — Declarar Modo Ativo

```
Modo: INFRASTRUCTURE
Projeto: enterprise-update-lab-n8n
Domínio: DevOps Infrastructure
Perfil ativo: devops-infrastructure.prompt.md
```

---

### Passo 8 — Relatório de Início de Sessão

Apresentar ao usuário:

```
🚀 Session Start Complete — [YYYY-MM-DD]

✅ MCP: memory, sequential-thinking, filesystem, github
✅ Contexto: [N] sessões anteriores recuperadas
✅ Regras: .copilot-rules-enterprise-update-lab-n8n.md carregado
✅ Segurança: scan OK, .secrets/ protegido
✅ Docs: SESSION_RECOVERY e DAILY_ACTIVITIES criados

Pendentes P0: [lista resumida]

Pronto para começar.
```

---

## 🛑 Se Algo Falhar

- **MCP server não disponível** → instruir usuário a executar `MCP: Refresh Servers`
- **Arquivo sensível detectado** → PARAR e mover para `.secrets/` antes de continuar
- **Sessão anterior incompleta** → reportar e perguntar se deve criar `FINAL_STATUS` retroativo
