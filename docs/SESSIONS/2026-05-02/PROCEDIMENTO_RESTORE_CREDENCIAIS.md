# PROCEDIMENTO DE RESTORE DE CREDENCIAIS N8N

**Data**: 2026-05-02
**Backup origem**: `/opt/docker_user/n8n/n8n_storage/backups/credentials/20250424/`
**Total de credenciais**: 30 arquivos JSON

---

## 🎯 MÉTODO RECOMENDADO: Interface Web (Mais Seguro)

### ✅ Vantagens
- ✅ Método oficial do N8N
- ✅ Valida credenciais automaticamente
- ✅ Detecta duplicatas
- ✅ Mantém histórico/auditoria
- ✅ Sem risco de corromper banco

### 📝 Passo a Passo

#### 1. **Copiar backups para máquina local**

```bash
# Na sua máquina local
mkdir -p ~/n8n_credentials_restore
~/.local/bin/ssh-wf001 "tar -czf - -C /opt/docker_user/n8n/n8n_storage/backups/credentials/20250424 ." | tar -xzf - -C ~/n8n_credentials_restore
ls ~/n8n_credentials_restore/*.json | wc -l  # Deve mostrar 30
```

#### 2. **Acessar interface de importação**

1. Abrir navegador: https://workflow.vya.digital
2. Login com suas credenciais
3. Ir em: **Settings** (⚙️) → **Credentials**
4. Clicar em **Import Credentials** (botão no canto superior direito)

#### 3. **Importar arquivos JSON**

- **Opção A** - Um por vez:
  - Arrastar/soltar arquivo JSON
  - N8N valida e importa automaticamente
  - Repetir para cada credencial

- **Opção B** - Em lote (se N8N suporta):
  - Selecionar múltiplos arquivos
  - Importar todos de uma vez

#### 4. **Validar após importação**

```bash
# Verificar quantidade de credenciais importadas
# (precisa de API key ou login via browser)
curl -s https://workflow.vya.digital/rest/credentials | jq '. | length'
```

---

## ⚡ MÉTODO ALTERNATIVO: Script Automático (via API)

**REQUISITO**: N8N precisa ter API Key configurada.

### Verificar se API está habilitada

```bash
~/.local/bin/ssh-wf001 "cd /opt/docker_user/n8n && grep N8N_API_KEY .env"
```

Se **não** existir, adicionar:

```bash
~/.local/bin/ssh-wf001 "cd /opt/docker_user/n8n && echo 'N8N_API_KEY=your-secure-api-key-here' | sudo tee -a .env"
~/.local/bin/ssh-wf001 "cd /opt/docker_user/n8n && docker compose restart n8n_editor"
```

Depois executar:

```bash
python3 .tmp/restore_credentials.py
```

---

## 🔧 MÉTODO AVANÇADO: Restore Direto no Banco (NÃO RECOMENDADO)

**⚠️ USAR APENAS EM ÚLTIMO CASO**

**Riscos**:
- ❌ Pode corromper banco de dados
- ❌ Pode causar conflitos de ID
- ❌ Requer N8N parado
- ❌ Necessita backup completo do banco antes

**Procedimento** (se absolutamente necessário):

```bash
# 1. BACKUP DO BANCO (OBRIGATORIO!)
# Senha: consultar .secrets/.env (variavel DB_POSTGRESDB_PASSWORD) — nunca em texto claro
~/.local/bin/ssh-wf001 'cd /opt/docker_user/n8n && source .env && PGPASSWORD="$DB_POSTGRESDB_PASSWORD" pg_dump -h 82.197.64.145 -U n8n_user -d n8n_db > /tmp/n8n_db_backup_$(date +%Y%m%d_%H%M%S).sql'

# 2. PARAR N8N
~/.local/bin/ssh-wf001 "cd /opt/docker_user/n8n && docker compose down"

# 3. Gerar e executar SQL de INSERT
# (Script SQL seria gerado analisando JSONs e criando INSERT statements)

# 4. REINICIAR N8N
~/.local/bin/ssh-wf001 "cd /opt/docker_user/n8n && docker compose up -d"
```

---

## 📋 HISTÓRICO DE PROBLEMAS COM .bkp

Baseado no comentário "temos histórico de problemas para restaurar arquivos bkp":

### Possíveis problemas anteriores:

1. **Formato encriptado diferente**: Versões antigas do N8N usavam formato diferente
2. **Chave de encriptação mudou**: `N8N_ENCRYPTION_KEY` diferente invalidou backups
3. **Versão incompatível**: Backup de versão mais nova restaurado em versão mais antiga
4. **Permissões de arquivo**: Arquivos sem permissão de leitura
5. **Path incorreto**: Importação procurando no diretório errado

### Solução atual:

✅ **Pasta `20250424` contém JSONs DESENCRIPTADOS** (formato aberto)
- Mais fácil de importar
- Não depende de `N8N_ENCRYPTION_KEY`
- Compatível com qualquer versão do N8N

---

## 🎯 RECOMENDAÇÃO FINAL

**Para sua situação atual (upgrade em andamento)**:

1. **AGORA** - Desabilitar os 4 workflows com erro (para limpar logs)
2. **CONCLUIR** - Upgrade completo até N8N 2.19.1
3. **DEPOIS** - Restaurar credenciais via interface web (método mais seguro)
4. **POR ÚLTIMO** - Reativar workflows e validar funcionamento

**Motivo**: Evitar conflitos de schema durante upgrade + credenciais restauradas em versão final.

---

**Quer que eu gere o script de download dos backups ou prefere continuar o upgrade primeiro?**
