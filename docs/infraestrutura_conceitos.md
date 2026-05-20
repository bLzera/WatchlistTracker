# Conceitos da Infraestrutura — WatchlistTracker

> Guia didático de tudo que foi implementado na Fase 0 do projeto, organizado em duas categorias: **Backend** (ambiente do código) e **DevOps** (ambiente de execução e entrega).

---

## Índice

- [Parte 1 — Backend](#parte-1--backend)
  - [1. Rails API-only](#1-rails-api-only)
  - [2. Gemfile e Bundler](#2-gemfile-e-bundler)
  - [3. database.yml](#3-configdatabaseyml)
  - [4. RuboCop](#4-rubocop--rubocopyml)
  - [5. Estrutura de Testes (RSpec)](#5-estrutura-de-testes-rspec)
- [Parte 2 — DevOps](#parte-2--devops)
  - [1. Docker e Dockerfile](#1-docker-e-o-dockerfile)
  - [2. Docker Compose](#2-docker-compose--orquestração-local)
  - [3. Nginx](#3-nginx--reverse-proxy)
  - [4. GitHub Actions](#4-github-actions--cicd)
  - [5. Terraform](#5-terraform--infrastructure-as-code)
- [Fluxo completo](#fluxo-completo)

---

# Parte 1 — Backend

> *Tudo que configura o ambiente do código em si: dependências, banco, testes e qualidade.*

---

## 1. Rails API-only

**O que é:** O comando `rails new backend --api --database=postgresql --skip-test` cria uma aplicação Rails sem a camada de visualização (HTML, CSS, assets). Ela só fala JSON.

**Por que:** O frontend será uma SPA React separada consumindo a API via HTTP. Não faz sentido carregar ActionView, layouts e toda a maquinaria de renderização de HTML no servidor.

**O que muda na prática:**
- `ApplicationController` herda de `ActionController::API` em vez de `ActionController::Base` — remove cookies, sessions, flash e outros middlewares que só fazem sentido em apps com HTML.
- A pasta `app/views/` existe só para e-mails (mailer templates).
- `rack-cors` passa a ser necessário para liberar o frontend (outro domínio) a fazer requisições.

**Conceito:** Separação de responsabilidades. O servidor cuida apenas de dados e regras de negócio. O cliente cuida de tudo que o usuário vê. Isso facilita escalar cada parte de forma independente e permite múltiplos clientes (web, mobile, etc.) consumindo a mesma API.

---

## 2. Gemfile e Bundler

**O que é:** O `Gemfile` é a lista de dependências da aplicação Ruby. O Bundler lê esse arquivo, instala versões compatíveis entre si e gera o `Gemfile.lock` — o registro exato de qual versão de cada gem foi instalada.

**Por que:** Sem um sistema de dependências, cada desenvolvedor e cada servidor poderia ter versões diferentes das mesmas bibliotecas, causando bugs difíceis de reproduzir. O `Gemfile.lock` elimina isso: garante que todos (devs, CI, produção) usem exatamente as mesmas versões.

### O operador `~>` (pessimistic version constraint)

```ruby
gem "rails", "~> 8.1.3"   # aceita 8.1.3 até 8.1.x — NÃO aceita 8.2
gem "pg",    "~> 1.1"      # aceita 1.1, 1.2, 1.9 — NÃO aceita 2.0
gem "puma",  ">= 5.0"      # qualquer versão 5 ou superior
```

O `~>` protege contra breaking changes em versões major/minor, mas permite patches de segurança automáticos.

### Grupos de gems

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
end
```

Gems dentro de grupos só são carregadas no ambiente correspondente. Em produção, `BUNDLE_WITHOUT="development"` faz o Bundler ignorar esses grupos — o container fica menor e mais seguro porque não carrega ferramentas de debug ou teste.

### Referência de gems implementadas

| Gem | Categoria | O que faz |
|---|---|---|
| `devise` | Auth | Autenticação completa: cadastro, login, e-mail de confirmação, recuperação de senha |
| `devise-jwt` | Auth | Integra Devise com tokens JWT para APIs stateless |
| `pundit` | Autorização | Define políticas de acesso: "este usuário pode editar esta lista?" |
| `bcrypt` | Segurança | Algoritmo de hash para senhas (usado internamente pelo Devise) |
| `sidekiq` | Jobs | Processa tarefas assíncronas (ex: gerar resumo IA) em background usando Redis |
| `redis` | Cache/Queue | Driver para comunicar com o servidor Redis |
| `rack-cors` | HTTP | Libera requisições cross-origin (frontend em outro domínio) |
| `jsonapi-serializer` | Serialização | Formata objetos Ruby em JSON estruturado para a resposta da API |
| `httparty` | HTTP client | Faz requisições HTTP para TVMaze, OMDb, MediaWiki e Anthropic |
| `dotenv-rails` | Config | Carrega variáveis do arquivo `.env` no ambiente Rails |
| `rspec-rails` | Teste | Framework de testes BDD para Rails |
| `factory_bot_rails` | Teste | Cria objetos de teste com dados realistas |
| `faker` | Teste | Gera dados falsos (nomes, e-mails, textos) para factories |
| `shoulda-matchers` | Teste | One-liners para testar validações e associações de models |
| `webmock` | Teste | Intercepta e simula chamadas HTTP externas |
| `vcr` | Teste | Grava respostas HTTP reais e as reproduz nos testes seguintes |
| `database_cleaner-active_record` | Teste | Garante isolamento entre testes limpando o banco |
| `simplecov` | Qualidade | Mede a porcentagem de código coberta pelos testes |
| `brakeman` | Segurança | Análise estática que detecta vulnerabilidades no código Ruby/Rails |
| `bundler-audit` | Segurança | Verifica se alguma gem tem CVE (vulnerabilidade pública) conhecida |
| `rubocop-rails-omakase` | Style | Conjunto de regras de estilo do Rails core team |
| `rubocop-rspec` | Style | Regras de estilo específicas para arquivos RSpec |

---

## 3. `config/database.yml`

**O que é:** Arquivo de configuração que diz ao ActiveRecord (ORM do Rails) como se conectar ao banco de dados em cada ambiente.

### Por que usar `DATABASE_URL`

```yaml
# Antes (gerado pelo rails new):
development:
  database: app_development
  username: app
  password: ...

# Depois (implementado):
default: &default
  adapter: postgresql
  url: <%= ENV["DATABASE_URL"] %>

development:
  <<: *default
  database: watchlist_development
```

Em vez de espalhar host, porta, usuário e senha em campos separados, tudo vai em uma única URL. Isso segue o padrão 12-factor (metodologia para apps cloud-native): a configuração vem do ambiente, não do código. Em desenvolvimento, o Docker Compose injeta essa URL. Em produção, ela está em um arquivo `.env` no servidor.

### Por que remover `cache:`, `queue:`, `cable:`

O Rails 8 por padrão usa o "Solid Stack" — `solid_cache`, `solid_queue`, `solid_cable` — que armazena cache, fila de jobs e WebSocket dentro do próprio banco PostgreSQL, sem precisar de Redis. Optamos por Redis + Sidekiq porque já temos Redis no projeto e o Sidekiq tem um ecossistema mais maduro, com dashboard de monitoramento e maior adoção na comunidade.

---

## 4. RuboCop — `.rubocop.yml`

**O que é:** Analisador estático de código Ruby. Lê o código sem executar e aponta inconsistências de estilo, possíveis bugs e complexidade desnecessária.

**Por que:** Sem um linter, cada desenvolvedor escreve com seu próprio estilo. Com dois devs no projeto isso já causa inconsistência. O RuboCop padroniza o estilo automaticamente, e o CI bloqueia código que não passa nas regras.

```yaml
inherit_gem:
  rubocop-rails-omakase: rubocop.yml  # herda as regras do Rails core team

require:
  - rubocop-rspec                      # regras adicionais para specs

AllCops:
  Exclude:
    - "db/**/*"   # migrations geradas automaticamente — não faz sentido lint
    - "bin/**/*"  # scripts gerados pelo Rails
```

**Conceito — análise estática vs dinâmica:** Análise estática lê o código sem rodá-lo. É rápida e pega problemas antes de você escrever um teste. Análise dinâmica (testes) executa o código e verifica o comportamento. As duas se complementam.

---

## 5. Estrutura de Testes (RSpec)

### 5.1 `spec_helper.rb` vs `rails_helper.rb`

Dois arquivos com papéis distintos:

- **`spec_helper.rb`** — configurações puras do RSpec, sem Rails. Controla aleatoriedade dos testes, persistência de exemplos, comportamento de mocks.
- **`rails_helper.rb`** — carrega o Rails e todo o suporte de testes. Todo spec que testa código Rails começa com `require "rails_helper"`.

```ruby
# Linha crítica do rails_helper.rb
abort("Rails is in prod — aborting") if Rails.env.production?
```

Essa verificação impede acidentalmente rodar os testes apontando para o ambiente de produção — o que limparia dados reais.

### 5.2 SimpleCov — Cobertura de Código

**O que é:** Instrumenta o Ruby para registrar quais linhas foram executadas durante os testes. Ao final, gera um relatório mostrando a porcentagem do código "tocada" pelos testes.

```ruby
SimpleCov.start "rails" do
  minimum_coverage 80          # CI falha se cair abaixo disso
  add_filter "/spec/"          # não conta o próprio código de teste
  add_filter "/config/"        # configurações não precisam de teste
  add_group "Services", "app/services"  # agrupa no relatório por tipo
end
```

**Por que 80%:** É o equilíbrio clássico — alto o suficiente para forçar disciplina, mas não tão alto a ponto de exigir testes frágeis para cobrir código trivial.

**Conceito importante:** Cobertura de código não garante que os testes são bons. Um teste pode executar uma linha sem realmente verificar o resultado. É uma métrica de piso (nenhuma linha sem teste), não de teto (não substitui testes bem escritos).

### 5.3 FactoryBot — Fábricas de Dados

**O que é:** Em vez de criar objetos de teste manualmente (`User.create(email: "...", password: "...")` em cada teste), você define uma "fábrica" uma vez e a reutiliza em toda a suite.

**Por que não usar fixtures:** Fixtures são arquivos YAML com dados estáticos. Com factories, você cria objetos dinamicamente, pode customizar atributos específicos por teste e o Faker gera dados realistas. Testes ficam mais expressivos e menos frágeis.

```ruby
# spec/support/factory_bot.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods  # permite chamar create(:user) diretamente
end
```

**`FactoryBot.lint`:** Executa todas as factories antes da suite começar, verificando que cada factory consegue criar um objeto válido. Captura inconsistências entre a factory e as validações do model antes de qualquer teste rodar.

### 5.4 VCR + WebMock — Gravação de Chamadas HTTP

**O problema:** Testes chamam APIs externas (TVMaze, OMDb, MediaWiki, Claude). Isso é lento, custa dinheiro, falha quando não há internet e os resultados podem mudar (uma série pode ter mais episódios amanhã).

**A solução — VCR (Video Cassette Recorder):**

1. Na primeira execução real, VCR deixa a requisição passar e grava a resposta em um arquivo `.yml` (chamado "cassete").
2. Nas execuções seguintes, VCR intercepta a requisição e retorna a resposta gravada — sem tocar a rede.

```ruby
VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Substitui chaves reais por placeholders antes de salvar o cassete
  config.filter_sensitive_data("<OMDB_API_KEY>") { ENV["OMDB_API_KEY"] }
  config.filter_sensitive_data("<ANTHROPIC_API_KEY>") { ENV["ANTHROPIC_API_KEY"] }
  # TVMaze e MediaWiki não usam chave — não há nada a filtrar.
end

# Bloqueia qualquer chamada HTTP não coberta por cassete
WebMock.disable_net_connect!(allow_localhost: true)
```

**A filtragem** substitui chaves de API reais pela string `<OMDB_API_KEY>` (ou outras) nos cassetes antes de salvá-los — permite commitar os cassetes no git sem vazar credenciais.

**`allow_localhost: true`** permite que os testes se conectem ao banco de dados e ao Redis (que rodam em localhost), bloqueando apenas conexões à internet.

### 5.5 DatabaseCleaner — Isolamento de Testes

**O problema:** Testes compartilham o mesmo banco. Se um teste cria um usuário e não limpa depois, o próximo pode falhar por violação de unique constraint.

**Duas estratégias:**

```ruby
DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
```

| Estratégia | Como funciona | Velocidade | Quando usar |
|---|---|---|---|
| `transaction` | Abre transaction, executa, faz rollback | Rápido | 99% dos testes |
| `truncation` | Apaga todas as linhas de todas as tabelas | Lento | Testes com múltiplas connections (JS/feature specs) |

A `truncation` é necessária quando o teste usa múltiplas connections ao banco, porque transações não são visíveis entre connections diferentes.

**Conceito:** Isolamento de testes — cada teste deve ser independente e o resultado não deve depender da ordem de execução ou do estado deixado por outros testes.

### 5.6 AuthHelpers — Autenticação nos Testes

```ruby
module AuthHelpers
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
  end

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
```

**Por que:** A maioria dos endpoints requer autenticação. Em vez de repetir a lógica de gerar um token JWT em cada spec, ela é extraída para um helper. O módulo é incluído apenas nos specs de request (`type: :request`), que são os que realmente fazem chamadas HTTP.

**Conceito — Bearer Token:** O cliente manda o token no header `Authorization: Bearer <token>`. O servidor valida o token sem precisar consultar o banco — toda a informação do usuário está codificada no JWT. Isso é autenticação stateless: o servidor não precisa guardar sessões.

---

# Parte 2 — DevOps

> *Tudo que define como o código roda, onde roda e como chega lá.*

---

## 1. Docker e o Dockerfile

**O que é:** Docker é uma plataforma de containerização. Um container é um processo isolado que carrega seu próprio sistema de arquivos, dependências e configurações — mas compartilha o kernel do sistema operacional do host.

**Por que não instalar direto na máquina:** Sem Docker, cada desenvolvedor precisa instalar Ruby, PostgreSQL e Redis na versão certa, na sua máquina. "Funciona na minha máquina" é o problema clássico. Com Docker, o ambiente é definido em código (o `Dockerfile`) e é idêntico para todos.

### Multi-stage build

Esta é a técnica mais importante do `Dockerfile` de produção:

```dockerfile
# STAGE 1: build — imagem grande com compiladores
FROM ruby:3.3.11-slim AS build
RUN apt-get install build-essential libpq-dev ...   # ferramentas de compilação
COPY Gemfile Gemfile.lock ./
RUN bundle install          # instala gems, compila extensões nativas
COPY . .

# STAGE 2: runtime — imagem pequena, só o necessário para rodar
FROM ruby:3.3.11-slim AS base
# NÃO instala build-essential — economiza centenas de MB
COPY --from=build /usr/local/bundle /usr/local/bundle  # gems já compiladas
COPY --from=build /app /app                            # código da aplicação
```

**Por que:** A imagem final de produção não precisa de compiladores (gcc, make, etc.) — eles só são necessários para compilar extensões nativas das gems (como `pg` e `websocket-driver`). O multi-stage usa uma imagem grande para compilar e copia apenas o resultado para uma imagem menor. A imagem de runtime fica ~300MB menor e tem superfície de ataque menor (menos pacotes = menos vulnerabilidades).

### Usuário não-root

```dockerfile
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 ...
USER 1000:1000
```

Por padrão, processos em containers rodam como root. Se houver uma vulnerabilidade na aplicação e um atacante conseguir executar código, ele teria privilégios de root dentro do container. Rodar como usuário sem privilégios limita o dano potencial.

### jemalloc

```dockerfile
RUN apt-get install libjemalloc2 && \
    ln -s .../libjemalloc.so.2 /usr/local/lib/libjemalloc.so
ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so"
```

`jemalloc` é um alocador de memória alternativo ao padrão do glibc. Aplicações Ruby se beneficiam especialmente porque o GC do Ruby fragmenta a memória. `jemalloc` reduz uso de memória e latência. `LD_PRELOAD` diz ao linker dinâmico para carregar `jemalloc` antes de qualquer outra biblioteca — sobrescrevendo o alocador padrão sem mudar uma linha de código Ruby.

---

## 2. Docker Compose — Orquestração Local

**O que é:** Docker Compose define um conjunto de containers que trabalham juntos como um sistema. Em vez de rodar `docker run ...` com dezenas de flags para cada serviço, você descreve tudo em YAML e sobe tudo com `docker compose up`.

### Healthchecks

```yaml
postgres:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 5s
    retries: 5

web:
  depends_on:
    postgres:
      condition: service_healthy  # espera o healthcheck passar
```

Sem `condition: service_healthy`, o Docker inicia o Rails imediatamente após iniciar o container do Postgres. O Rails tenta conectar ao banco antes dele estar pronto para aceitar conexões e crasha. O healthcheck garante que o Rails só inicia quando o Postgres está realmente respondendo.

### Volumes

```yaml
volumes:
  - ./backend:/app                     # bind mount
  - bundle_cache:/usr/local/bundle     # volume nomeado
```

| Tipo | Comportamento | Uso |
|---|---|---|
| Bind mount (`./backend:/app`) | Código do host mapeado no container em tempo real | Desenvolvimento — alterações aparecem instantaneamente sem rebuild |
| Volume nomeado (`bundle_cache`) | Dados gerenciados pelo Docker, persistem entre restarts | Gems instaladas — evita reinstalar a cada `docker compose down && up` |

Bind mounts **nunca** devem ir para produção — o código deve estar dentro da imagem.

### Três arquivos Compose

```
docker-compose.yml          ← dev (bind mounts, mailhog, portas expostas)
docker-compose.staging.yml  ← staging (imagem de prod, porta 3001, DB separado)
docker-compose.prod.yml     ← produção (restart policy, logs JSON, sem bind mounts)
```

**Conceito — ambiente como código:** Os três arquivos não são redundantes. Cada um especializa o comportamento para o contexto. Em dev você quer código ao vivo e ferramentas de debug. Em produção você quer estabilidade, restart automático em caso de crash e logs estruturados para sistemas de monitoramento.

**Restart policy:**
```yaml
web:
  restart: unless-stopped
```

Se o container crasha (exceção não tratada, OOM, etc.), o Docker o reinicia automaticamente. `unless-stopped` significa: reinicia em qualquer falha, mas não reinicia se você manualmente parou com `docker compose stop`.

### MailHog (dev only)

```yaml
mailhog:
  image: mailhog/mailhog:latest
  ports:
    - "1025:1025"   # SMTP
    - "8025:8025"   # UI web
```

Em desenvolvimento, a aplicação envia e-mails (confirmação de cadastro, recuperação de senha). MailHog é um servidor SMTP "buraco negro" — aceita todos os e-mails e os exibe em uma UI web em `localhost:8025`. Evita enviar e-mails reais para endereços de teste e permite validar o template dos e-mails visualmente.

---

## 3. Nginx — Reverse Proxy

**O que é:** Nginx é um servidor web/proxy que fica na frente da aplicação Rails. O cliente nunca fala diretamente com o Puma (servidor do Rails).

```
Internet → Nginx (443) → Rails/Puma (3000, interno)
```

**Por que:**

- **SSL/TLS:** Nginx gerencia os certificados Let's Encrypt e termina o HTTPS. O Rails recebe HTTP simples internamente — não precisa saber sobre certificados.
- **Múltiplos apps no mesmo servidor:** Um único Nginx roteia para produção (porta 3000) e staging (porta 3001) baseado no `server_name` (domínio).

### WebSocket (Action Cable)

```nginx
location /cable {
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_read_timeout 3600;   # mantém conexão aberta por 1h
}
```

WebSocket começa como HTTP e depois é "upgraded" para um protocolo de conexão persistente. Sem essa configuração, o Nginx fecha a conexão após o timeout padrão (normalmente 60s). O header `Upgrade` sinaliza para o Nginx manter a conexão aberta — essencial para o real-time do Action Cable funcionar.

---

## 4. GitHub Actions — CI/CD

**Conceito geral:**
- **CI (Continuous Integration):** cada mudança no código passa por uma bateria de verificações automáticas antes de ser integrada. Objetivo: encontrar problemas o mais cedo possível.
- **CD (Continuous Delivery/Deployment):** automatiza a entrega do código verificado para os ambientes.

### CI — `ci.yml`

```
security → lint → test   (execução em sequência)
```

Por que sequência e não paralelo? Lint e security são mais rápidos. Se o código tem um problema óbvio de segurança ou estilo, não faz sentido gastar minutos rodando os testes. Falha rápido e barato.

```yaml
test:
  needs: [security, lint]   # só roda se os outros passaram
  services:
    postgres:               # o CI sobe um banco real dentro do runner
      image: postgres:16-alpine
    redis:
      image: redis:7-alpine
```

**Por que usar banco real e não mock:** Com banco mockado (em memória), você pode testar queries que funcionam no mock mas falham em SQL real (tipos, constraints, índices, transações). O banco real garante que o comportamento em produção é o mesmo dos testes.

**Cache do RuboCop:**
```yaml
key: rubocop-${{ runner.os }}-${{ hashFiles('.ruby-version', '.rubocop.yml', 'Gemfile.lock') }}
```

RuboCop analisa arquivo por arquivo e pode ser cacheado. A chave inclui o hash dos arquivos de configuração: se `.rubocop.yml` ou `Gemfile.lock` mudar, o cache é invalidado e o RuboCop roda do zero. Se não mudou, usa o resultado cacheado — economiza 1-2 minutos por PR.

**Artefatos:**
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: backend/coverage/
```

O relatório de cobertura gerado pelo SimpleCov é salvo como artefato do workflow. Você pode baixá-lo diretamente da UI do GitHub para investigar quais linhas não estão cobertas.

### CD — `deploy.yml`

```
push main  → build imagem → deploy staging (automático)
tag v*.*.* → build imagem → deploy produção (aprovação manual)
```

**Build e cache de layers Docker:**
```yaml
- uses: docker/build-push-action@v6
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

O cache de layers no GitHub Actions evita recompilar gems do zero a cada build. Se o `Gemfile.lock` não mudou, a layer de `bundle install` vem do cache — o build cai de ~8 minutos para ~2 minutos.

**Tagging automático da imagem:**
```yaml
tags: |
  type=sha,prefix=sha-            # sha-abc1234 — rastreabilidade exata
  type=ref,event=branch           # main
  type=semver,pattern={{version}} # v1.2.3 (quando é uma tag)
  type=raw,value=latest,enable=${{ startsWith(github.ref, 'refs/tags/v') }}
```

Cada imagem recebe múltiplas tags. A tag `sha-` permite rastrear exatamente qual commit está rodando em produção. A tag `latest` só é atualizada em releases de produção.

**Aprovação manual para produção:**
```yaml
deploy-production:
  environment: production   # este campo é o que força aprovação no GitHub
```

No GitHub você configura o environment `production` com "Required reviewers". Quando o workflow tenta fazer deploy de produção, ele pausa e manda uma notificação pedindo aprovação. Ninguém, nem o próprio dono do repo, pode fazer deploy sem aprovar manualmente. Isso previne deploy acidental.

**O deploy em si:**
```bash
docker compose -f docker-compose.prod.yml pull     # baixa nova imagem
docker compose -f docker-compose.prod.yml up -d    # recria só o que mudou
bundle exec rails db:migrate                        # roda migrations pendentes
docker image prune -f                              # limpa imagens antigas
```

O `up -d` do Compose recria apenas os containers que mudaram. Containers que não mudaram (postgres, redis) ficam intactos.

---

## 5. Terraform — Infrastructure as Code

**Conceito fundamental:** IaC trata infraestrutura (servidores, firewalls, IPs) como código versionado. Em vez de clicar no painel do DigitalOcean para criar um servidor, você declara o que quer em arquivos `.tf` e o Terraform cria, modifica ou destrói para corresponder à declaração.

**Vantagem:** O estado da infraestrutura fica documentado e reproduzível. Se o servidor for destruído por acidente ou migração, você roda `terraform apply` e o mesmo ambiente é recriado em minutos.

### State local

**O que é:** Terraform mantém um arquivo `terraform.tfstate` que registra o estado atual da infraestrutura — quais recursos existem, quais IDs têm no DigitalOcean, quais dependências há entre eles. Sem esse arquivo, o Terraform não sabe o que já criou e tentaria criar tudo do zero novamente.

**Decisão de projeto:** usamos state local (`infrastructure/environments/production/terraform.tfstate`). O arquivo fica na máquina de quem roda o `terraform apply` e está no `.gitignore` — não vai para o repositório porque pode conter dados sensíveis (IPs, IDs internos).

**Cuidado obrigatório:** faça backup manual do `terraform.tfstate` após cada `terraform apply`. Sem ele, recuperar o controle dos recursos existentes no DigitalOcean exige rodar `terraform import` recurso por recurso. Uma cópia em local seguro (fora do repositório) é suficiente para o Fase 1 com dois usuários.

**Por que não usamos remote state:** As opções comuns são DO Spaces ($5/mês mínimo para guardar um arquivo de ~10 KB) e Terraform Cloud (o free tier foi descontinuado). O overhead financeiro e operacional não justifica na Fase 1.

### Módulos

```hcl
# environments/production/main.tf
module "server" {
  source       = "../../modules/server"
  droplet_name = "watchlist-prod"
}

module "networking" {
  source     = "../../modules/networking"
  droplet_id = module.server.droplet_id
}
```

**Por que modularizar:** Módulos são blocos reutilizáveis de infraestrutura. `modules/server` define como criar um Droplet + Firewall. `modules/networking` define como criar um Reserved IP e associá-lo. O `environments/production` compõe esses módulos com valores específicos. Se amanhã você quiser um segundo servidor, cria `environments/staging-server` usando os mesmos módulos com outros valores.

### Firewall

```hcl
# Ingress: só porta 22 (SSH), 80 (HTTP), 443 (HTTPS)
inbound_rule { port_range = "22" }
inbound_rule { port_range = "80" }
inbound_rule { port_range = "443" }

# Egress: tudo liberado (o servidor precisa chamar APIs externas)
outbound_rule { port_range = "all" }
```

**Conceito — princípio do menor privilégio:** O servidor aceita conexões de entrada apenas nas portas necessárias. Portas como 5432 (Postgres) e 6379 (Redis) são internas — só acessíveis entre containers via rede Docker, nunca expostas à internet. Isso elimina a possibilidade de alguém tentar atacar diretamente o banco de dados.

### Cloud-init

```yaml
# cloud-init.yaml.tpl — executado na primeira inicialização do servidor
users:
  - name: deploy
    groups: [docker, sudo]
    ssh_authorized_keys:
      - ${deploy_public_key}   # chave pública injetada pelo Terraform

runcmd:
  - apt-get install docker-ce docker-ce-cli ...
  - systemctl enable docker
  - mkdir -p /opt/watchlist/prod /opt/watchlist/staging
```

**O que é:** Cloud-init é o mecanismo padrão de inicialização de VMs em cloud. Quando o Droplet inicializa pela primeira vez, ele executa esse script — instalando Docker, criando o usuário `deploy`, configurando as chaves SSH e criando os diretórios da aplicação.

**Por que:** O objetivo é chegar a um servidor pronto para receber deploys sem nenhuma intervenção manual. Você roda `terraform apply`, espera 2-3 minutos, e o servidor já tem Docker instalado, usuário criado e diretórios prontos. O CI/CD pode começar a fazer deploy imediatamente.

**`${deploy_public_key}`** é uma interpolação do Terraform — o valor da variável é injetado no arquivo antes de enviá-lo ao Droplet. A chave privada correspondente fica no secret `DO_SSH_PRIVATE_KEY` do GitHub, que o workflow de deploy usa para se autenticar via SSH.

---

## Fluxo completo

```
Dev local
    │  git push / PR
    ▼
GitHub Actions CI
  [security] brakeman + bundler-audit
  [lint]     rubocop
  [test]     rspec + simplecov ≥ 80%
    │  merge para main
    ▼
GitHub Actions CD
  [build]    docker build (multi-stage) → push ghcr.io:sha-xxxx
  [staging]  SSH → docker compose pull + up → rails db:migrate (porta 3001)
    │  criar tag v1.0.0 + aprovação manual
    ▼
  [prod]     SSH → docker compose pull + up → rails db:migrate (porta 3000)
    │
    ▼
DigitalOcean Droplet (provisionado pelo Terraform + cloud-init)
  Nginx (SSL, proxy, WebSocket)
    ├── Rails/Puma :3000  (produção)
    ├── Rails/Puma :3001  (staging)
    ├── Sidekiq           (jobs assíncronos)
    ├── PostgreSQL        (dados)
    └── Redis             (queue + cache)
```

Cada camada resolve um problema específico e se apoia na anterior. A infraestrutura garante que o ambiente é reproduzível; o CI garante que o código que chega lá é correto; o CD garante que a entrega é segura e rastreável.
