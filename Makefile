.PHONY: up down logs test lint console migrate setup build shell help

# ─── desenvolvimento local ────────────────────────────────────────────────
up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f web

build:
	docker compose build

shell:
	docker compose run --rm web bash

# ─── banco de dados ───────────────────────────────────────────────────────
setup:
	docker compose run --rm web bundle exec rails db:create db:schema:load db:seed

migrate:
	docker compose run --rm web bundle exec rails db:migrate

rollback:
	docker compose run --rm web bundle exec rails db:rollback

console:
	docker compose run --rm web bundle exec rails console

# ─── testes ───────────────────────────────────────────────────────────────
test:
	docker compose run --rm -e RAILS_ENV=test web bundle exec rspec

test-file:
	docker compose run --rm -e RAILS_ENV=test web bundle exec rspec $(FILE)

# ─── qualidade de código ──────────────────────────────────────────────────
lint:
	docker compose run --rm web bundle exec rubocop

lint-fix:
	docker compose run --rm web bundle exec rubocop -a

security:
	docker compose run --rm web bin/brakeman --no-pager
	docker compose run --rm web bin/bundler-audit check --update

# ─── staging (no servidor remoto) ────────────────────────────────────────
staging-logs:
	ssh deploy@$(DO_SERVER_IP) "cd /opt/watchlist && docker compose -f docker-compose.staging.yml logs -f"

staging-console:
	ssh deploy@$(DO_SERVER_IP) "cd /opt/watchlist && docker compose -f docker-compose.staging.yml exec web_staging bundle exec rails console"

# ─── ajuda ────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════"
	@echo " WatchlistTracker — visão geral da infra"
	@echo "═══════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo " 3 stacks Docker independentes, uma por ambiente:"
	@echo ""
	@echo " ┌─ DEV (sua máquina) — docker-compose.yml"
	@echo " │   web + sidekiq → postgres + redis  (+ mailhog solto)"
	@echo " │   Rails em http://localhost:3000  ·  MailHog em :8025"
	@echo " │"
	@echo " ├─ STAGING (servidor) — docker-compose.staging.yml"
	@echo " │   web_staging + sidekiq_staging → postgres_staging"
	@echo " │   Reusa o redis do stack de prod (network externa)"
	@echo " │   ⚠ exige stack de prod já no ar pra network existir"
	@echo " │   Rails em :3001"
	@echo " │"
	@echo " └─ PROD (servidor) — docker-compose.prod.yml"
	@echo "     web + sidekiq → postgres + redis"
	@echo "     Rails em :3000 · nginx no host faz TLS e proxy reverso"
	@echo ""
	@echo " Deps em todos: web e sidekiq esperam postgres+redis healthy."
	@echo ""
	@echo "─── DEV: comandos locais ──────────────────────────────────────────────"
	@echo "  make build       — Buildar imagem Rails (Dockerfile.dev)"
	@echo "  make up          — Subir os 5 containers de dev"
	@echo "  make down        — Parar dev"
	@echo "  make logs        — Logs do Rails em tempo real"
	@echo "  make shell       — Bash no container web"
	@echo "  make console     — Rails console"
	@echo ""
	@echo "─── DEV: banco ────────────────────────────────────────────────────────"
	@echo "  make setup       — db:create + db:schema:load + db:seed (1ª vez)"
	@echo "  make migrate     — Rodar migrations pendentes"
	@echo "  make rollback    — Reverter última migration"
	@echo ""
	@echo "─── DEV: testes e qualidade ───────────────────────────────────────────"
	@echo "  make test        — RSpec completo (coverage ≥ 80%)"
	@echo "  make test-file FILE=spec/... — Rodar 1 arquivo"
	@echo "  make lint        — RuboCop"
	@echo "  make lint-fix    — RuboCop com autocorreção"
	@echo "  make security    — Brakeman + bundler-audit"
	@echo ""
	@echo "─── STAGING / PROD: deploy ────────────────────────────────────────────"
	@echo "  Staging:  git push origin main           (CI faz deploy automático)"
	@echo "  Prod:     git tag v0.x.0 && git push --tags  (+ aprovação no GH)"
	@echo "  make staging-logs     — Logs do staging via SSH"
	@echo "  make staging-console  — Rails console no staging"
	@echo ""
	@echo " Setup inicial (1ª vez em máquina nova):"
	@echo "   cp backend/.env.example backend/.env.development"
	@echo "   make build && make up && make setup"
	@echo ""
