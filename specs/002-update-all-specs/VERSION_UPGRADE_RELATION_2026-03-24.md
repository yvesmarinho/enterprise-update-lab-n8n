# Version Upgrade Relation - 2026-03-24

## Fonte canonica

- Source URL: <https://api.github.com/repos/n8n-io/n8n/releases?per_page=100>
- Timestamp de consulta (UTC): 2026-03-24
- Politica aplicada: upgrade sequencial sem salto de major, com checkpoints por transicao e passagem inicial pela primeira minor da major alvo.

## Estado atual

- Runtime atual observado: 2.6.4
- Erro persistente (15 min): 0 na ultima coleta oficial registrada
- Resultado do primeiro hop: 2.6.4 -> 2.7.5 executado, reprovado no gate e revertido para 2.6.4

## Alvos de versao

- Alvo estavel recomendado para a rodada: 2.13.2
- Ultima versao publicada observada: 2.14.0
- Politica operacional desta rodada: promover ate 2.13.2 (stable), avaliando 2.14.0 em rodada controlada posterior.

## Relacao de versoes que devem ser atualizadas

1. 2.6.4 -> 2.7.0
2. 2.7.0 -> 2.7.5
3. 2.7.5 -> 2.8.4
4. 2.8.4 -> 2.9.4
5. 2.9.4 -> 2.10.4
6. 2.10.4 -> 2.11.4
7. 2.11.4 -> 2.12.3
8. 2.12.3 -> 2.13.2

## Evidencia de inicio do processo

- Primeiro hop selecionado: 2.6.4 -> 2.7.5
- Acao executada: pre-pull de imagem n8nio/n8n:2.7.5
- Acao executada: disparo de alteracao de compose para 2.7.5 e subida de servicos
- Confirmacao objetiva: hop aplicado em runtime com todos os servicos em 2.7.5
- Resultado do gate do hop: NO-GO (`ERRORS_2M=24`, `ERRORS_15M=36`)
- Erro principal observado: `There was an error initializing DB`
- Acao corretiva executada: rollback completo para 2.6.4 com sucesso
- Proximo hop recomendado apos revisao de estrategia: `2.6.4 -> 2.7.0`

## Gate por hop (minimo)

Para cada transicao:

1. Pre-check de saude e backup
2. Validacao funcional dos workflows criticos
3. Coleta de metricas em 15 minutos (erro critico, p95, throughput)
4. Decisao GO/NO-GO
5. Rollback drill controlado ou simulacao validada
