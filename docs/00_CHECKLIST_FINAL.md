# Checklist de Infraestrutura — WatchlistTracker

> Última atualização: 2026-05-10

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
| `API_SPECIFICATION.md` | ❌ | OpenAPI/Swagger — a criar |

---

## Infraestrutura (implementado em 2026-05-10)

### Aplicação Rails
- ✅ Rails 8.1 API-only (`backend/`) — gerado via `rails new --api`
- ✅ Gemfile configurado: Devise+JWT, Pundit, Sidekiq, Redis, HTTParty, jsonapi-serializer, dotenv
- ✅ Gems de teste: RSpec, FactoryBot, Faker, Shoulda-matchers, VCR, WebMock, DatabaseCleaner, SimpleCov
- ✅ `config/database.yml` usando `DATABASE_URL` por ambiente
- ✅ `.rubocop.yml` com rubocop-rails-omakase + rubocop-rspec

### Testes
- ✅ `spec/spec_helper.rb` + `spec/rails_helper.rb` com SimpleCov (mínimo 80%)
- ✅ `spec/support/factory_bot.rb` — FactoryBot.lint no suite completo
- ✅ `spec/support/vcr.rb` — VCR + WebMock, sem HTTP real no CI
- ✅ `spec/support/auth_helpers.rb` — helpers JWT para specs autenticadas
- ✅ `spec/support/database_cleaner.rb` — transaction/truncation por tipo de spec
- ✅ `spec/support/shared_contexts/` — contextos reutilizáveis (authenticated_user, authenticated_owner)
- ✅ Estrutura de diretórios: `spec/{models,requests/{auth,lists,items,ai},services,jobs,channels,factories}`
- ❌ Testes E2E (Cypress/Playwright) — Fase 2+

### Containerização
- ✅ `backend/Dockerfile` — multi-stage (builder + runtime), usuário não-root, jemalloc
- ✅ `backend/Dockerfile.dev` — imagem de desenvolvimento com live reload
- ✅ `docker-compose.yml` — ambiente dev (web, sidekiq, postgres, redis, mailhog)
- ✅ `docker-compose.staging.yml` — staging no mesmo servidor (porta 3001, DB separado)
- ✅ `docker-compose.prod.yml` — produção (restart policy, logs JSON)
- ✅ `nginx/nginx.conf` — proxy reverso prod+staging, WebSocket (Action Cable), SSL

### CI/CD (GitHub Actions)
- ✅ `.github/workflows/ci.yml`:
  - `security`: brakeman (SAST) + bundler-audit (CVE check)
  - `lint`: RuboCop com cache
  - `test`: RSpec com postgres+redis como services, cobertura artefato
- ✅ `.github/workflows/deploy.yml`:
  - Build imagem Docker → push para ghcr.io
  - Push `main` → deploy automático para staging
  - Tag `v*.*.*` → deploy para produção com aprovação manual (GitHub Environments)
- ❌ Notificações de deploy (Slack/email) — Fase 2+

### Infrastructure as Code (Terraform)
- ✅ Provider: `digitalocean/digitalocean ~> 2.40`
- ✅ State local (`terraform.tfstate` no `.gitignore` — fazer backup manual após cada apply)
- ✅ `modules/server`: `digitalocean_droplet` + `digitalocean_firewall` + cloud-init (instala Docker automaticamente)
- ✅ `modules/networking`: `digitalocean_reserved_ip` (IP estático para DNS)
- ✅ `environments/production/`: main.tf + variables.tf + outputs.tf + terraform.tfvars.example
- ❌ Staging em servidor separado — não planejado (staging usa mesmo Droplet)

### DX (Developer Experience)
- ✅ `Makefile` — atalhos para dev, teste, lint, console, migrate, staging
- ✅ `backend/.env.example` — todas as variáveis documentadas
- ✅ `backend/.env.development` — valores padrão para dev local
- ✅ `.gitignore` — env files, terraform state, cobertura, cassetes VCR
- ✅ `README.md` raiz — setup rápido em 3 comandos, tabela de comandos, estrutura do repo

---

## Próximos Passos (Implementação de Features)

Seguir o cronograma de 12 semanas definido em `docs/README.md`.

**Semana 1-2 — Auth (RF-001..004)**
- [ ] Model `User` com Devise + devise-jwt
- [ ] Controllers: `registrations`, `sessions`, `passwords`, `confirmations`
- [ ] Specs de request para RF-001 (registro), RF-002 (login), RF-003 (senha), RF-004 (perfil)
- [ ] Factory `:user`

**Semana 3 — Integração TMDB/OMDb (RF-009..011)**
- [ ] Service `TmdbClient` + `OmdbClient`
- [ ] Model `Movie` (cache local)
- [ ] Endpoint `GET /api/v1/search`
- [ ] VCR cassetes para as chamadas externas

**Semana 4-5 — CRUD de Listas e Itens (RF-005..015)**
- [ ] Models: `List`, `ListMember`, `ListItem`
- [ ] Policies Pundit para cada model
- [ ] Controllers REST completos
- [ ] Specs de request cobrindo caminhos felizes + erros de autorização

**Semana 6 — Real-time (RF-027)**
- [ ] Action Cable channel `ListChannel`
- [ ] Broadcast em cada mutação de lista
- [ ] Specs de channel

**Semana 7-8 — IA (RF-028..031)**
- [ ] Service `AnthropicClient`
- [ ] Model `ResumoIa` com JSONB
- [ ] Sidekiq job `GenerateEpisodeSummaryJob`
- [ ] Pipeline: marcar episódio → buscar contexto → gerar → cachear

**Semana 9-12 — Frontend React + Deploy**
- [ ] Scaffold do projeto React em `frontend/`
- [ ] `terraform apply` → provisionar Droplet + IP reservado
- [ ] Configurar DNS, SSL (Certbot), segredos GitHub
- [ ] Primeiro deploy de produção via tag `v0.1.0`

---

## Segredos GitHub necessários

Configure em `Settings → Secrets and variables → Actions`:

| Secret | Descrição |
|---|---|
| `DO_SSH_PRIVATE_KEY` | Chave privada SSH para o usuário `deploy` no Droplet |
| `DO_SERVER_IP` | IP reservado do Droplet (output do `terraform apply`) |
| `GITHUB_TOKEN` | Automático — usado para push no ghcr.io |

Vars de aplicação (`ANTHROPIC_API_KEY`, `DATABASE_URL`, etc.) ficam no servidor em `/opt/watchlist/prod/.env` e `/opt/watchlist/staging/.env` — nunca em secrets do GitHub.
