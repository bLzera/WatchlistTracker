# Backend Rails do WatchlistTracker — Guia para quem nunca viu Ruby

> Público-alvo: alguém com bom conhecimento de web (HTTP, MVC, ORM, middleware, autenticação) mas zero exposição a Ruby/Rails. O objetivo é traçar paralelos com o que você já conhece (Node/Express, Django, Spring, Laravel, etc.) e mostrar exatamente por onde uma requisição passa **neste projeto**.

---

## 1. Contexto rápido: o que é Ruby e o que é Rails

- **Ruby** é uma linguagem dinâmica, interpretada, orientada a objetos. Tudo (literalmente tudo, incluindo números e `nil`) é um objeto com métodos. Sintaxe enxuta: sem ponto-e-vírgula, sem chaves para blocos de método (usa `def ... end`), parênteses opcionais em chamadas.
- **Rails** é um framework MVC opinativo (o equivalente espiritual de Django ou Laravel). Aqui ele está rodando em **modo API-only** (`config/application.rb`), ou seja: sem views HTML, sem asset pipeline, sem cookies de sessão por padrão — só JSON entrando e saindo.
- **Versão:** Rails 8.1.3 sobre Ruby (ver `.ruby-version`). PostgreSQL como banco, Puma como servidor HTTP, Redis previsto para Sidekiq (filas).

### Convenções que dominam tudo
Rails é **convention over configuration** levado ao extremo. Vale memorizar:
- O nome do arquivo dita o nome da classe: `app/models/user.rb` → `class User`. `app/controllers/api/v1/users_controller.rb` → `class Api::V1::UsersController`.
- Pluralização importa: model `User` (singular) ↔ tabela `users` (plural) ↔ controller `UsersController` (plural).
- Diretórios padrão fazem autoload — você nunca escreve `require` para código do próprio app. Mencionou `User` em qualquer lugar? O Rails encontra `app/models/user.rb` sozinho via Zeitwerk.

---

## 2. A pilha em uma frase

`Cliente HTTP → Puma → Rack (config.ru) → Middleware stack → Roteador (routes.rb) → Controller → (Policy + Model + Serializer) → JSON → Cliente`

Agora cada peça em detalhe, com os arquivos reais.

---

## 3. Camada de entrada: Puma e Rack

### `backend/config/puma.rb`
Puma é o servidor HTTP multithread (análogo a Gunicorn/uvicorn no Python, ou ao próprio `node`/PM2). Ele aceita a conexão TCP, parseia o HTTP cru e entrega um objeto de requisição padronizado para a camada de cima.

### `backend/config.ru`
Esse `.ru` é "rackup". **Rack** é a especificação de baixo nível que todo framework web Ruby implementa — pense nele como o **WSGI do Python** ou o `http.Handler` do Go. Um app Rack é qualquer coisa que responda a `call(env)` e retorne `[status, headers, body]`. O Rails inteiro, por baixo, é um app Rack gigante.

O `config.ru` apenas carrega o app (`Rails.application`) e o entrega ao Puma.

---

## 4. Middleware stack

Antes da requisição chegar no seu código, ela passa por uma fila de middlewares Rack — exatamente como `app.use(...)` no Express ou o middleware chain do Django.

Neste projeto, dois middlewares notáveis são adicionados via initializers:

### `backend/config/initializers/cors.rb`
Liga o `rack-cors` para liberar requisições cross-origin do frontend. Expõe o header `Authorization` (essencial porque o token JWT trafega ali).

### Middleware do `devise-jwt`
Inserido automaticamente quando a gem é carregada. **Esse é o middleware que olha o header `Authorization: Bearer <token>`, decodifica o JWT, e prepara o `current_user`** antes mesmo do controller rodar. Se o token estiver inválido, ele já corta aqui com 401.

Para listar a stack completa, em dev você roda `bin/rails middleware`.

---

## 5. Roteador: `config/routes.rb`

```ruby
namespace :api do
  namespace :v1 do
    devise_scope :user do
      post   "auth/signup",  to: "registrations#create"
      post   "auth/sign_in", to: "sessions#create"
      ...
    end
    scope :users do
      get   "me", to: "users#me"
      patch "me", to: "users#update_me"
    end
  end
end
```

Leitura:
- `namespace :api` aninha tanto a **URL** (`/api/...`) quanto o **módulo Ruby** (`Api::...`). Dois níveis = `/api/v1/...` e classe `Api::V1::AlgumaCoisaController`.
- `"users#me"` é a sintaxe `controller#action`: chama o método `me` do `UsersController`.
- `devise_for :users, skip: :all` registra o Devise mas **descarta as rotas padrão dele** — o time preferiu definir manualmente cada endpoint dentro de `/api/v1/auth/...` para manter o versionamento limpo.
- Verbo + path → controller + action é resolvido aqui. Equivalente direto ao `urls.py` do Django ou ao `routes/web.php` do Laravel.

Para inspecionar todas as rotas: `bin/rails routes`.

---

## 6. Controller: onde sua lógica de request mora

### `backend/app/controllers/application_controller.rb`
```ruby
class ApplicationController < ActionController::API
  include Pundit::Authorization
  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError,   with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
end
```

Pontos-chave:
- **`ActionController::API`** é a classe base enxuta (sem helpers de view). Todo controller herda dela via `ApplicationController` — exatamente o padrão "BaseController" que você já viu em outras stacks.
- **`before_action :authenticate_user!`** é o hook do Devise (parecido com decorator `@login_required` ou middleware de auth). Roda ANTES de qualquer action de controller-filho. Se não houver usuário válido, devolve 401 e a action nunca executa.
- **`rescue_from`** é o try/catch global do Rails: erros desse tipo borbulhando da action são capturados aqui e convertidos em resposta JSON estruturada. Pundit nega autorização → 403. Active Record não acha o registro → 404.

### `backend/app/controllers/api/v1/users_controller.rb`
```ruby
class UsersController < ApplicationController
  def me
    render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
           status: :ok
  end

  def update_me
    if current_user.update(user_params)
      render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

Observe três idiomas Rails:
1. **`current_user`** é injetado pelo Devise — vem do JWT decodificado no middleware.
2. **`render json: ...`** é como o controller devolve resposta. Não tem `return` — é só a última expressão avaliada.
3. **Strong parameters** (`params.require(...).permit(...)`) é a defesa contra mass-assignment: o cliente pode mandar `{ user: { name, email, is_admin } }`, mas só `name` e `email` passam. Sem isso, atacantes poderiam setar qualquer coluna.

---

## 7. Autorização: Pundit

### `backend/app/policies/user_policy.rb`
```ruby
class UserPolicy < ApplicationPolicy
  def show?   = record == user
  def update? = record == user
end
```

Pundit é uma gem leve de autorização baseada em **policy objects**. Convenção: para o model `User`, existe `UserPolicy`; cada action expõe um método terminado em `?` (`show?`, `update?`, `destroy?`). Dentro:
- `user` = usuário corrente.
- `record` = o objeto sendo acessado.

Para usar, o controller chama `authorize(@user)` (ou no recurso relevante) e Pundit dispara automaticamente o método correspondente à action atual. Se retornar `false`, levanta `Pundit::NotAuthorizedError` — capturada lá no `ApplicationController` e virada em 403.

Análogos: `@PreAuthorize` do Spring Security, gates/policies do Laravel, `permission_classes` do DRF.

---

## 8. Model + ORM: Active Record

### `backend/app/models/user.rb`
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :confirmable, :lockable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true, length: { maximum: 100 }
end
```

Active Record é o ORM do Rails — clássico **padrão Active Record** (Martin Fowler). Diferente do Data Mapper do Hibernate/SQLAlchemy, **o objeto é a linha**: `user.save`, `user.update(...)`, `user.destroy` agem na própria instância.

O que esse arquivo está dizendo:
- Herda de `ApplicationRecord` (que herda de `ActiveRecord::Base`) — ganha automaticamente acesso à tabela `users` (inferida pelo nome plural da classe).
- **`devise :modulos...`** é uma chamada de método (DSL) que mistura comportamentos: hash de senha, confirmação por email, lockout após N falhas, geração de JWT, etc. Cada símbolo (`:database_authenticatable`) ativa um módulo.
- **`validates`** define validações declarativas que rodam antes de salvar. Falha → `user.save` retorna `false` e os erros vão para `user.errors`.

O schema real está em `backend/db/schema.rb` (gerado por migrations em `backend/db/migrate/`). Migrations são versionadas tipo Flyway/Alembic.

---

## 9. Serializer: formatação do JSON de saída

### `backend/app/serializers/user_serializer.rb`
```ruby
class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :email, :confirmed_at, :created_at
end
```

Usa a gem **`jsonapi-serializer`** (sucessora da `fast_jsonapi`). Lista de atributos = whitelist do que vaza para o cliente. Crucial para nunca expor `encrypted_password`, `reset_password_token` etc.

No projeto, o controller extrai `serializable_hash[:data][:attributes]` para devolver um objeto flat em vez do envelope JSON:API completo — uma customização local.

---

## 10. Autenticação na prática (fluxo JWT)

1. Cliente faz `POST /api/v1/auth/sign_in` com email/senha.
2. `SessionsController#create` (subclasse de `Devise::SessionsController`) valida credenciais via bcrypt.
3. `devise-jwt` gera um JWT assinado com `ENV["DEVISE_JWT_SECRET_KEY"]`, contendo `sub` (id do user) e `jti` (id único do token).
4. Token volta no header `Authorization` da resposta (CORS expõe esse header).
5. Cliente armazena o token e o envia em toda request subsequente como `Authorization: Bearer <token>`.
6. Em cada request, o middleware do `devise-jwt` valida assinatura + expira + consulta `JwtDenylist` (tabela em `app/models/jwt_denylist.rb`) pra confirmar que o `jti` não foi revogado.
7. Logout (`DELETE /api/v1/auth/sign_out`) insere o `jti` no `JwtDenylist` → token vira inválido mesmo antes de expirar.

Tudo stateless do lado do servidor, exceto o denylist (necessário pra suportar logout real).

---

## 11. Anatomia completa de UMA request

Vamos seguir `PATCH /api/v1/users/me` com body `{ "user": { "name": "Novo Nome" } }` e header `Authorization: Bearer <jwt>`:

| # | Camada | Arquivo | O que acontece |
|---|---|---|---|
| 1 | Socket TCP | (Puma) | Puma aceita a conexão, parseia HTTP, monta `env` Rack. |
| 2 | Rack entrypoint | `config.ru` | Entrega `env` ao `Rails.application`. |
| 3 | Middleware CORS | `config/initializers/cors.rb` | Adiciona headers CORS, deixa passar. |
| 4 | Middleware JWT | (gem `devise-jwt`) | Decodifica o Bearer token, valida assinatura, checa `JwtDenylist`, popula `warden` com o user. |
| 5 | Router | `config/routes.rb` | Casa `PATCH /api/v1/users/me` → `Api::V1::UsersController#update_me`. |
| 6 | Base controller | `app/controllers/application_controller.rb` | Roda `before_action :authenticate_user!`. JWT já preencheu o user, passa. |
| 7 | Action | `app/controllers/api/v1/users_controller.rb` | `user_params` filtra os campos permitidos (strong params). |
| 8 | Model + DB | `app/models/user.rb` → PostgreSQL via `pg` | `current_user.update(...)` roda validações (`name` presente, ≤100 chars) → `UPDATE users SET name = $1 WHERE id = $2`. |
| 9 | Serializer | `app/serializers/user_serializer.rb` | Monta hash apenas com atributos whitelisted. |
| 10 | Render | (Action Controller) | `render json:` serializa pra string JSON, seta `Content-Type: application/json`. |
| 11 | Middleware retorno | (mesma pilha, inverso) | Headers CORS finais, logging. |
| 12 | Puma → socket | (Puma) | Resposta HTTP 200 sai pelo fio. |

Se algo der errado:
- JWT inválido → passo 4 já responde 401, nada mais executa.
- Pundit (caso fosse usado aqui) → 403 via `rescue_from`.
- `update` retorna `false` → controller cai no `else` e devolve 422 com `errors`.
- Exceção não tratada em prod → middleware `ActionDispatch::ShowExceptions` devolve 500 genérico.

---

## 12. Outros diretórios que você vai encontrar

| Path | Análogo | O que tem |
|---|---|---|
| `app/jobs/` | tasks Celery, BullMQ | Jobs em background (Sidekiq + Redis). Vazio por enquanto. |
| `app/mailers/` | nodemailer wrappers | Templates de email (confirmação Devise, reset de senha). Em dev mira o MailHog. |
| `config/initializers/` | bootstrap files | Código que roda uma vez na inicialização (`devise.rb`, `cors.rb`, etc.). |
| `config/environments/` | NODE_ENV configs | `development.rb`, `production.rb`, `test.rb`. Define cache, logs, eager loading. |
| `db/migrate/` | Flyway/Alembic | Migrations versionadas. `bin/rails db:migrate` aplica. |
| `db/schema.rb` | dump declarativo | Estado atual do schema (regenerado a cada migrate). |
| `spec/` | suite de testes | RSpec + FactoryBot + WebMock/VCR. Equivalente a Jest+supertest. Rodar com `bundle exec rspec`. |
| `Gemfile` | `package.json` | Dependências. Resolvidas pelo Bundler em `Gemfile.lock`. |
| `bin/` | npm scripts | `bin/rails`, `bin/rake`, `bin/setup`. Wrappers oficiais. |
| `lib/tasks/` | scripts de manutenção | Rake tasks customizadas. |

---

## 13. Mapa mental de equivalências

| Conceito | Rails | Express/Node | Django | Laravel |
|---|---|---|---|---|
| Servidor HTTP | Puma | http / Express adapter | Gunicorn | PHP-FPM |
| Spec base | Rack | (próprio) | WSGI/ASGI | (próprio) |
| Roteador | `config/routes.rb` | `app.get(...)` | `urls.py` | `routes/*.php` |
| Controller base | `ApplicationController` | controller class | `View` class | `Controller` |
| Before/after filter | `before_action` | middleware | `dispatch()` hooks | middleware |
| ORM | Active Record | Prisma/Sequelize | Django ORM | Eloquent |
| Migration | `db/migrate/*.rb` | Prisma migrate | Django migrations | Laravel migrations |
| Auth | Devise + JWT | Passport | django-allauth | Sanctum/Passport |
| Authz | Pundit | casl | django-guardian | Gates/Policies |
| Serializer | jsonapi-serializer | class-transformer | DRF Serializer | API Resources |
| Bg jobs | Sidekiq | BullMQ | Celery | Queues |
| Test framework | RSpec | Jest+supertest | pytest+APIClient | PHPUnit |

---

## 14. Comandos que você vai querer rodar

Dentro de `backend/`:

```bash
bin/rails server          # sobe o Puma na porta 3000
bin/rails console         # REPL com a aplicação carregada — IMPRESCINDÍVEL pra debugar
bin/rails routes          # tabela de todas as rotas registradas
bin/rails db:migrate      # aplica migrations pendentes
bin/rails db:rollback     # desfaz a última
bundle exec rspec         # roda a suite de testes
bundle install            # instala gems do Gemfile
```

O `rails console` é um superpoder: você abre, digita `User.last.update(name: "X")` e mexe direto no banco como se estivesse no controller.

---

## 15. Para onde olhar depois

Em ordem de "abre e lê para entender mais profundo":

1. `backend/Gemfile` — inventário do que está em jogo.
2. `backend/config/routes.rb` — mapa de todas as URLs.
3. `backend/app/controllers/application_controller.rb` — política base de toda request.
4. `backend/app/models/user.rb` + `backend/db/schema.rb` — modelo de domínio atual.
5. `backend/config/initializers/devise.rb` — toda a configuração de auth.
6. `backend/spec/requests/` — testes de request mostram exemplos reais de chamada ponta-a-ponta.

Com isso, qualquer feature nova é uma combinação previsível: rota → controller → policy → model (talvez migration) → serializer → spec.
