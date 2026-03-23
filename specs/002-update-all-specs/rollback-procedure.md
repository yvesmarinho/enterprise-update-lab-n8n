# Rollback Procedure - 002-update-all-specs

## Objetivo

Definir politica obrigatoria de rollback, backup e restore drill para cada transicao de versao intermediaria.

## Politica por checkpoint

Para cada transicao from_version -> to_version:

### 1. Backup pre-checkpoint

- Exportar configuracao do stack e variaveis de ambiente.
- Gerar snapshot dos dados persistentes e validar checksum.
- Registrar artefato de backup com timestamp.

### 2. Janela de execucao controlada

- Executar transicao em janela aprovada.
- Registrar resultado de pre-check, validacao funcional e validacao de desempenho.

### 3. Trigger de rollback

- Acionar rollback se qualquer gate falhar:
  - regressao funcional em workflow critico;
  - regressao de desempenho acima do limite;
  - erro critico em credenciais, integracoes, fila ou armazenamento.

### 4. Execucao de rollback

- Restaurar snapshot de dados.
- Restaurar stack e variaveis de ambiente da versao anterior.
- Revalidar saude do ambiente e workflows criticos.

### 5. Rollback drill obrigatorio

- Executar rollback drill controlado (ou simulacao validada) antes da promocao do proximo checkpoint.
- Registrar evidencias e aprovacao go/no-go.

## Evidencias minimas obrigatorias

- backup_artifact
- restore_artifact
- rollback_trigger_record
- rollback_execution_record
- rollback_drill_record
- gate_decision_record
