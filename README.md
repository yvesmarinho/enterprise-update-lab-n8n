# Enterprise Update Lab N8N

> Laboratório para atualização de versão do N8N para evitar transtornos na produção

**Domínio**: infrastructure | **Linguagem**: python
**Criado em**: 2026-03-20T18:44:10Z

---

## 🚀 Início Rápido

```bash
# Instalar dependências
make install-deps

# Iniciar desenvolvimento
make dev
```

## 📚 Documentação

- [Índice](docs/INDEX.md)
- [Tarefas](docs/TODO.md)
- [Constituição do Projeto](.specify/memory/constitution.md)

## 🏗️ Estrutura

Consulte os [documentos de arquitetura](docs/) para detalhes.

## 🧭 Governança

Este projeto segue o fluxo Speckit `constitution -> plan -> tasks -> implement`.
Os gates de segurança, rollback, compatibilidade e evidências são definidos na
constituição e devem ser atendidos antes de avançar de fase.
As atualizações de n8n devem ser executadas de forma sequencial, versão a versão,
partindo da 2.6.4 até a última disponível, sem salto entre versões intermediárias.
O alvo derivado de latest deve ser resolvido e congelado por rodada no plano,
com precedência de tags oficiais e fallback em release notes oficiais.
