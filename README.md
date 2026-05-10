# WatchlistTracker

App colaborativo para casais gerenciarem listas de filmes e séries, com resumos de episódio gerados por IA que conectam narrativamente episódios consecutivos.

## Stack

- **Backend:** Ruby on Rails 8 (API-only) · PostgreSQL · Redis · Sidekiq · Action Cable
- **Auth:** Devise + JWT + Pundit
- **IA:** Anthropic Claude via TMDB/OMDb
- **Deploy:** DigitalOcean (Droplet) via Docker + Terraform
- **CI/CD:** GitHub Actions

---

## Requisitos locais

- [Docker](https://docs.docker.com/get-docker/) + Docker Compose
- `make` (já incluso no Linux/macOS)

---

## Setup rápido (dev)

```bash
# 1. Clonar e entrar no projeto
git clone <repo-url> && cd WatchlistTracker

# 2. Copiar variáveis de ambiente
cp backend/.env.example backend/.env.development
# Edite .env.development com suas chaves de API (TMDB, OMDB, Anthropic)

# 3. Subir e inicializar
make setup   # cria BD + roda migrations + seeds
make up      # sobe todos os serviços

# 4. Acessar
# API:     http://localhost:3000
# MailHog: http://localhost:8025 (e-mails em dev)
```

---

## Comandos úteis

| Comando          | Descrição                        |
|------------------|----------------------------------|
| `make up`        | Subir ambiente dev               |
| `make down`      | Parar                            |
| `make logs`      | Logs do Rails em tempo real      |
| `make test`      | Rodar RSpec (coverage ≥ 80%)     |
| `make lint`      | RuboCop                          |
| `make lint-fix`  | RuboCop com autocorreção         |
| `make security`  | Brakeman + bundler-audit         |
| `make console`   | Rails console                    |
| `make migrate`   | Rodar migrations                 |
| `make shell`     | Bash no container Rails          |
| `make help`      | Lista completa                   |

---

## Estrutura do monorepo

```
WatchlistTracker/
├── backend/          # Rails 8 API
│   ├── app/
│   ├── spec/         # RSpec (models, requests, services, jobs, channels)
│   ├── Dockerfile    # Produção (multi-stage)
│   └── Dockerfile.dev
├── frontend/         # React (fase 2)
├── infrastructure/   # Terraform → DigitalOcean
│   ├── modules/
│   └── environments/production/
├── nginx/            # Config Nginx (prod + staging)
├── .github/workflows/
│   ├── ci.yml        # Lint + Security + RSpec
│   └── deploy.yml    # Build → Staging (main) / Prod (tag)
├── docker-compose.yml          # Dev
├── docker-compose.staging.yml  # Staging
├── docker-compose.prod.yml     # Produção
└── Makefile
```

---

## CI/CD

- **Pull Request / push para `main`:** CI executa lint (RuboCop), security (Brakeman + bundler-audit) e testes (RSpec com cobertura mínima de 80%).
- **Push para `main`:** deploy automático para staging (porta 3001 no servidor).
- **Tag `v*.*.*`:** deploy para produção com aprovação manual configurada no GitHub Environments.

---

## Infraestrutura (Terraform)

```bash
cd infrastructure/environments/production

# Copiar e preencher variáveis
cp terraform.tfvars.example terraform.tfvars

# Configurar estado remoto (DigitalOcean Spaces)
export AWS_ACCESS_KEY_ID=<spaces-key>
export AWS_SECRET_ACCESS_KEY=<spaces-secret>

terraform init
terraform plan
terraform apply
```

Após o `apply`, o output `server_ip` é o IP estático para apontar o DNS.

---

## Documentação

Toda a documentação de produto e arquitetura está em [`docs/`](./docs/).

| Arquivo | Conteúdo |
|---|---|
| `docs/CONTEXTO_PROJETO.md` | Síntese do projeto |
| `docs/requisitos_funcionais.md` | 36 RFs com critérios de aceitação |
| `docs/arquitetura_dados.md` | Modelo de dados |
| `docs/arquitetura_llm.md` | Pipeline de IA |
| `docs/ruby_on_rails_architecture.md` | Stack Rails detalhado |
