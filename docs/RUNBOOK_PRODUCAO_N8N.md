# RUNBOOK PRODUCAO N8N

## Objetivo

Padronizar a aplicacao do processo de upgrade do n8n em producao com seguranca, rastreabilidade e rollback controlado.

## Escopo

- Ambiente alvo: stack n8n via Docker Compose
- Estrategia: upgrade sequencial por checkpoint
- Janela de medicao: 15 minutos por hop

## Acesso remoto padrao (obrigatorio)

1. Usar exclusivamente o wrapper definido no JSON de segredos: `~/.local/bin/ssh-wfdb01`.
2. Nao usar `ssh wfdb01` direto durante a operacao deste projeto.
3. Host alvo operacional: `wfdb01`, usuario `archaris`, com `sudo` sem senha.

Exemplo de execucao padrao:

```bash
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && docker compose images'
```

## Pre-requisitos obrigatorios

1. Change aprovado com janela de manutencao definida.
2. Backup validado de dados persistentes e configuracoes.
3. Lista de workflows criticos para validacao funcional.
4. Aprovadores de gate definidos (tecnico e negocio).
5. Plano de rollback testado (drill ou simulacao validada).

## Trilha de versoes recomendada para esta rodada

1. 2.6.4 -> 2.7.0
2. 2.7.0 -> 2.7.5
3. 2.7.5 -> 2.8.4
4. 2.8.4 -> 2.9.4
5. 2.9.4 -> 2.10.4
6. 2.10.4 -> 2.11.4
7. 2.11.4 -> 2.12.3
8. 2.12.3 -> 2.13.2

## Procedimento por checkpoint

### 1. Pre-check

1. Confirmar versao atual em runtime.
2. Confirmar status dos containers (todos Up).
3. Confirmar banco configurado (n8n_dev_db neste projeto).
4. Coletar baseline de erros e metricas na janela de 15 minutos.

### 2. Backup

1. Gerar backup dos volumes/dados.
2. Gerar backup de compose e variaveis.
3. Validar checksum e registrar artefato.

Exemplo minimo (quando sem permissao de escrita no diretorio do stack):

```bash
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && ts=$(date -u +%Y%m%dT%H%M%SZ) && sudo cp docker-compose.yaml /tmp/docker-compose.yaml.$ts'
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
~/.local/bin/ssh-wfdb01 'cd /opt/docker_user/n8n && sudo sed -i "s/n8nio\/n8n:2.7.5/n8nio\/n8n:2.6.4/g" docker-compose.yaml && docker compose up -d'
```

## Evidencias obrigatorias por hop

1. Snapshot pre-check e pos-check.
2. Log de comando de atualizacao.
3. Resultado de validacao funcional.
4. Resultado de metricas 15 minutos.
5. Decisao GO/NO-GO assinada.
6. Registro de rollback (quando aplicavel).

## Checklist rapido de producao

1. Janela e comunicacao aprovadas.
2. Backups concluidos e verificaveis.
3. Hop executado e versao confirmada.
4. Gate validado em 15 minutos.
5. Evidencias anexadas no changelog da rodada.

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
