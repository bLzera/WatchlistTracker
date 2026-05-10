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
	@echo "Comandos disponíveis:"
	@echo "  make up          — Subir ambiente dev"
	@echo "  make down        — Parar ambiente dev"
	@echo "  make logs        — Ver logs do Rails"
	@echo "  make setup       — Criar e popular banco de dados"
	@echo "  make migrate     — Rodar migrations pendentes"
	@echo "  make console     — Rails console"
	@echo "  make test        — Rodar todos os testes (RSpec)"
	@echo "  make lint        — RuboCop"
	@echo "  make lint-fix    — RuboCop com autocorreção"
	@echo "  make security    — Brakeman + bundler-audit"
	@echo "  make shell       — Bash dentro do container"
	@echo ""
