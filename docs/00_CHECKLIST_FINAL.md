# Checklist de Infraestrutura e Features — WatchlistTracker

> Última atualização: 2026-05-11

---

## Documentação de Produto (docs/)

| Arquivo | Status | Conteúdo |
|---|---|---|
| `README.md` | ✅ | Visão geral + navegação |
| `movie_app_features.md` | ✅ | O QUÊ fazer (features) |
| `requisitos_funcionais.md` | ✅ | 36 RFs com critérios de aceitação |
| `arquitetura_dados.md` | ✅ | MER + SQL + queries |
| `arquitetura_llm.md` | ✅ | Pipeline TMDB + Claude |
| `ruby_on_rails_architecture.md` | ✅ | Stack Rails com gems e exemplos |
| `GUIA_USO_DOCUMENTACAO.md` | ✅ | Meta-guia da documentação |
| `CONTEXTO_PROJETO.md` | ✅ | Síntese executiva do projeto |
| `infraestrutura_conceitos.md` | ✅ | Guia didático de toda a infraestrutura implementada |
| `API_SPECIFICATION.md` | ❌ | OpenAPI/Swagger — a criar |

---

## Infraestrutura (Fase 0 — concluída)

### Aplicação Rails
- ✅ Rails 8.1 API-only (`backend/`) — gerado via `rails new --api`
- ✅ Gemfile configurado: Devise+JWT, Pundit, Sidekiq, Redis, HTTParty, jsonapi-serializer, dotenv
- ✅ Gems de teste: RSpec, FactoryBot, Faker, Shoulda-matchers, VCR, WebMock, DatabaseCleaner, SimpleCov
- ✅ `config/database.yml` usando `DATABASE_URL` por ambiente, nomes `watchlist_*`
- ✅ `.rubocop.yml` com rubocop-rails-omakase + rubocop-rspec

### Testes
- ✅ `spec/rails_helper.rb` — SimpleCov (mínimo 80%), integração com support files
- ✅ `spec/support/database_cleaner.rb` — `:transaction` para specs de modelo, `:truncation` para request specs
- ✅ `spec/support/factory_bot.rb` — FactoryBot.lint no suite
- ✅ `spec/support/vcr.rb` — VCR + WebMock, sem HTTP real no CI
- ✅ `spec/support/auth_helpers.rb` — helpers JWT para specs autenticadas
- ✅ `spec/support/shared_contexts/` — contextos reutilizáveis

### Containerização
- ✅ `backend/Dockerfile` — multi-stage (builder + runtime), usuário não-root, jemalloc
- ✅ `backend/Dockerfile.dev` — desenvolvimento com live reload
- ✅ `docker-compose.yml` — dev (web, sidekiq, postgres, redis, mailhog)
- ✅ `docker-compose.staging.yml` — staging mesmo servidor (porta 3001, DB separado)
- ✅ `docker-compose.prod.yml` — produção (restart policy, logs JSON)
- ✅ `nginx/nginx.conf` — proxy reverso prod+staging, WebSocket (Action Cable), SSL

### CI/CD (GitHub Actions)
- ✅ `.github/workflows/ci.yml`:
  - `security`: brakeman + bundler-audit
  - `lint`: RuboCop com cache
  - `test`: RSpec com postgres+redis como services, artefato de cobertura
- ✅ `.github/workflows/deploy.yml`:
  - Build imagem Docker → push para ghcr.io
  - Push `main` → deploy automático para staging
  - Tag `v*.*.*` → deploy para produção com aprovação manual (GitHub Environments)
- ❌ Notificações de deploy (Slack/email) — Fase 2+

### Infrastructure as Code (Terraform)
- ✅ Provider: `digitalocean/digitalocean ~> 2.40`
- ✅ State local (`terraform.tfstate` no `.gitignore` — fazer backup manual após cada apply)
- ✅ `modules/server`: `digitalocean_droplet` + `digitalocean_firewall` + cloud-init
- ✅ `modules/networking`: `digitalocean_reserved_ip` (IP estático para DNS)
- ✅ `environments/production/`: main.tf + variables.tf + outputs.tf + terraform.tfvars.example

### DX
- ✅ `Makefile` — atalhos para dev, teste, lint, console, migrate, staging
- ✅ `backend/.env.example` — todas as variáveis documentadas
- ✅ `.gitignore` — env files, terraform state, cobertura, cassetes VCR
- ✅ `README.md` raiz — setup rápido, tabela de comandos, estrutura do repo

---

## Features MVP (Fase 1)

### Auth (RF-001..004) — em andamento

#### Implementado
- ✅ Model `User` (Devise: database_authenticatable, registerable, recoverable, validatable, confirmable, lockable, jwt_authenticatable)
- ✅ Model `JwtDenylist` (estratégia de revogação de token)
- ✅ Migration `users` — campos name, confirmable, lockable
- ✅ Migration `jwt_denylist` — jti + exp com índice único
- ✅ `config/initializers/devise.rb` — JWT (24h), lockable (5 tentativas / 1h), confirmação, recuperação de senha
- ✅ `config/initializers/cors.rb` — `expose: ["Authorization"]` para o frontend receber o JWT
- ✅ `ApplicationController` — Pundit + `authenticate_user!` + error handlers (403, 404)
- ✅ `config/routes.rb` — namespace `api/v1` + rotas Devise customizadas
- ✅ `app/views/devise/mailer/` — templates HTML customizados (usam `FRONTEND_URL` em vez de URL helpers do Rails)
- ✅ `Api::V1::RegistrationsController` — RF-001: POST /api/v1/auth/signup
- ✅ `Api::V1::SessionsController` — RF-002: POST /api/v1/auth/sign_in + DELETE /api/v1/auth/sign_out
- ✅ `Api::V1::PasswordsController` — RF-003: POST/PUT /api/v1/auth/password
- ✅ `Api::V1::ConfirmationsController` — RF-001: POST/GET /api/v1/auth/confirmation
- ✅ `Api::V1::UsersController` — RF-004: GET/PATCH /api/v1/users/me
- ✅ `UserSerializer` — serializa atributos públicos do usuário (jsonapi-serializer)
- ✅ `ApplicationPolicy` + `UserPolicy` (Pundit)
- ✅ `spec/factories/users.rb` — traits :unconfirmed e :locked
- ✅ `spec/models/user_spec.rb` — validações, módulos Devise, factory

#### Testes — estado atual (40 exemplos, todos passando)

| Spec | Total | Passando | Falhando |
|---|---|---|---|
| `user_spec.rb` (model) | 11 | 11 | 0 |
| `registrations_spec.rb` (RF-001) | 6 | 6 | 0 |
| `sessions_spec.rb` (RF-002) | 7 | 7 | 0 |
| `passwords_spec.rb` (RF-003) | 5 | 5 | 0 |
| `confirmations_spec.rb` (RF-001 reenvio/confirmação) | 3 | 3 | 0 |
| `profile_spec.rb` (RF-004) | 8 | 8 | 0 |
| **TOTAL** | **40** | **40** | **0** |

#### Falhas resolvidas (2026-05-11)

Os 2 testes do `GET /api/v1/auth/confirmation` falhavam porque o helper de request spec `get "...", params: {...}, as: :json` promovia a requisição GET para POST silenciosamente — o request chegava no roteador como POST e caía no `confirmations#create` (que sempre retorna 200 "e-mail reenviado"), nunca no `#show`. A hipótese antiga (isolamento de pool de conexão) estava errada.

**Diagnóstico real:** confirmado via `warn` no controller — `request.method` chegava como `POST` mesmo com `get` no teste.

**Fix:** remover `as: :json` dos GETs (params já vão por query string em GET, não há body JSON pra serializar). Aplicado em `spec/requests/auth/confirmations_spec.rb`.

#### Pendência: coverage

**Cobertura atual:** 70.97% (abaixo dos 80% mínimos do SimpleCov). O gap não vinha dos testes que falhavam — mesmo com eles passando o coverage continua baixo. Falta cobrir caminhos não-felizes em controllers de auth e provavelmente o `JwtDenylist` / policies. A resolver na próxima sessão.

---

## Próximos Passos

### Imediato — subir coverage para ≥ 80%
- Auditar `coverage/index.html` por arquivo
- Adicionar specs para caminhos não-felizes (erros de validação, autorização, JWT inválido/expirado, denylist)
- Cobrir `UserPolicy` / `ApplicationPolicy` explicitamente

### Semana 3 — Integração TMDB/OMDb (RF-009..011)
- [ ] Service `TmdbClient` + `OmdbClient`
- [ ] Model `Movie` (cache local)
- [ ] Endpoint `GET /api/v1/search`
- [ ] VCR cassetes para as chamadas externas

### Semana 4-5 — CRUD de Listas e Itens (RF-005..015)
- [ ] Models: `List`, `ListMember`, `ListItem`
- [ ] Policies Pundit para cada model
- [ ] Controllers REST completos
- [ ] Specs de request cobrindo caminhos felizes + erros de autorização

### Semana 6 — Real-time (RF-027)
- [ ] Action Cable channel `ListChannel`
- [ ] Broadcast em cada mutação de lista
- [ ] Specs de channel

### Semana 7-8 — IA (RF-028..031)
- [ ] Service `AnthropicClient`
- [ ] Model `ResumoIa` com JSONB
- [ ] Sidekiq job `GenerateEpisodeSummaryJob`
- [ ] Pipeline: marcar episódio → buscar contexto → gerar → cachear

### Semana 9-12 — Frontend React + Deploy
- [ ] Scaffold React em `frontend/`
- [ ] `terraform apply` → provisionar Droplet + IP reservado
- [ ] Configurar DNS, SSL (Certbot), segredos GitHub
- [ ] Primeiro deploy de produção via tag `v0.1.0`

---

## Segredos GitHub necessários

| Secret | Descrição |
|---|---|
| `DO_SSH_PRIVATE_KEY` | Chave privada SSH para o usuário `deploy` no Droplet |
| `DO_SERVER_IP` | IP reservado do Droplet (output do `terraform apply`) |
| `GITHUB_TOKEN` | Automático — usado para push no ghcr.io |

Vars de app (`ANTHROPIC_API_KEY`, `DATABASE_URL`, etc.) ficam no servidor em `/opt/watchlist/prod/.env` e `/opt/watchlist/staging/.env`.
