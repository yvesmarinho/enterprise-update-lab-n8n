# Quickstart - Planejamento de Atualizacao Sequencial de Especificacoes

## 1. Confirmar contexto base

- Validar objetivo em docs/objetivo.yaml
- Validar politica MCP em docs/mcp-questions.yaml
- Validar principios em .specify/memory/constitution.md

## 2. Confirmar politica de versao-alvo

- Resolver "latest" no planejamento
- Registrar versao-alvo congelada para a rodada
- Bloquear alteracoes de alvo sem change-control aprovado

## 3. Definir trilha versao a versao

- Montar sequencia 2.6.4 -> ... -> versao-alvo congelada
- Definir um checkpoint por transicao de versao
- Associar responsaveis por gate para cada checkpoint

## 4. Definir evidencias obrigatorias por checkpoint

- Pre-check
- Validacao funcional
- Validacao de desempenho
- Pos-check
- Rollback drill (ou simulacao validada)
- Decisao go/no-go documentada

## 5. Definir baseline e metricas operacionais

- Coletar baseline antes da primeira transicao da rodada
- Medir p95 de execucao de workflows criticos por checkpoint
- Medir throughput medio por janela de 15 minutos por checkpoint
- Bloquear promocao se regressao for maior que 10%

## 6. Verificar consistencia de especificacoes

- Conferir alinhamento semantico entre objetivo, mcp-questions, constituicao e spec
- Garantir ausencia de contradicoes na estrategia de upgrade
- Garantir rastreabilidade requisito -> tarefa -> evidencia

## 7. Saida esperada desta fase

- Plan.md preenchido
- Research.md consolidado
- Data-model.md com entidades e validacoes
- Contrato de consistencia definido em contracts/
