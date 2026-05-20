# Plano — Documentação da API com rswag

> Plano de implementação combinado em 2026-05-20. Atualizar conforme executar.

## Objetivo

Documentar a API REST do backend no padrão **OpenAPI 3.0** usando a gem **rswag**, que permite que os próprios specs RSpec gerem a especificação. Resultado: um `swagger.yaml` versionado + Swagger UI navegável em `/api-docs`.

## Por que rswag e não YAML à mão

- Specs viram doc + teste de contrato no mesmo lugar.
- Doc não dessincroniza do código (se o endpoint muda e a spec não, o teste falha).
- Frontend lê o `swagger.yaml` direto do repo.

Trade-off aceito: mais código nos specs e curva de aprendizado da DSL do rswag.

## Passos

### 1. Adicionar gems ao `backend/Gemfile`
- `rswag-api` (geral) — serve o `swagger.yaml`.
- `rswag-ui` (geral) — serve o Swagger UI em `/api-docs`.
- `rswag-specs` (`:development, :test`) — DSL para specs.

### 2. Rodar gerador
```bash
bundle install
rails g rswag:install
```
Cria `spec/swagger_helper.rb`, monta engines em `config/routes.rb`, cria `swagger/v1/`.

### 3. Migrar specs de auth para DSL rswag
Reescrever, **um por vez** (rodando RSpec entre cada um para garantir que continuam verdes):

- [ ] `spec/requests/auth/registrations_spec.rb` (RF-001 signup)
- [ ] `spec/requests/auth/sessions_spec.rb` (RF-002 sign_in/out)
- [ ] `spec/requests/auth/passwords_spec.rb` (RF-003 reset)
- [ ] `spec/requests/auth/confirmations_spec.rb` (RF-001 confirmação)
- [ ] `spec/requests/auth/profile_spec.rb` (RF-004 /users/me)

### 4. Gerar e versionar `swagger.yaml`
```bash
bundle exec rake rswag:specs:swaggerize
```
Commitar `swagger/v1/swagger.yaml` no git (fonte oficial para o frontend).

### 5. Documentar acesso
- Atualizar `infraestrutura_conceitos.md` com seção sobre rswag.
- README do backend: como rodar Swagger UI local (`localhost:3000/api-docs`) e como regenerar.
- Atualizar `00_CHECKLIST_FINAL.md` marcando `API_SPECIFICATION.md` como ✅ (substituído por `swagger/v1/swagger.yaml`).

## Decisões já tomadas

- **`swagger.yaml` versionado** (não gitignorado): frontend pode ler do GitHub sem rodar suíte.
- **rswag em produção também**: a UI fica disponível em prod (`/api-docs`). Se quisermos restringir depois, basta proteger a rota.
- **Não rodar `bundle install` automaticamente**: provavelmente via container Docker — confirmar com o usuário antes.

## Riscos

- Migração pode quebrar specs verdes (52 passando, coverage 93.22%). Mitigação: migrar um arquivo por vez, rodar suíte entre cada.
- DSL do rswag é verbosa para casos com muitas variações de payload. Aceitável no MVP.

## Próximos endpoints a documentar (após auth)

Conforme forem implementados nas próximas semanas:
- Search (TVMaze + OMDb): `GET /api/v1/search`
- Listas: `GET/POST/PATCH/DELETE /api/v1/lists`
- Itens: `GET/POST/PATCH/DELETE /api/v1/lists/:id/items`
- Resumos IA: `POST /api/v1/episodes/:id/summary`
