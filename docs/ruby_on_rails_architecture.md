# 🚂 Movie & TV Series Tracker com Ruby on Rails

## 1. Análise de Viabilidade

### 1.1 Por que Rails é Bom para Este Projeto?

| Aspecto | Rails | Next.js |
|--------|-------|---------|
| **API REST** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐⭐⭐ Excelente |
| **Banco de Dados** | ⭐⭐⭐⭐⭐ ActiveRecord é incrível | ⭐⭐⭐⭐ Setup manual |
| **WebSocket (Real-time)** | ⭐⭐⭐⭐⭐ Action Cable nativo | ⭐⭐⭐⭐ Precisa socket.io |
| **Autenticação** | ⭐⭐⭐⭐⭐ Devise/JWT fácil | ⭐⭐⭐⭐ nextauth.js |
| **Jobs Background** | ⭐⭐⭐⭐⭐ Sidekiq/Resque nativo | ⭐⭐⭐⭐ Precisa Bull/Agenda |
| **Admin Panel** | ⭐⭐⭐⭐⭐ RailsAdmin/ActiveAdmin | ⭐⭐⭐ Precisa fazer ou usar third-party |
| **Documentação** | ⭐⭐⭐⭐⭐ Muito boa | ⭐⭐⭐⭐⭐ Excelente |
| **Comunidade** | ⭐⭐⭐⭐⭐ Enorme e ativa | ⭐⭐⭐⭐⭐ Crescente |
| **Curva de Aprendizado** | ⭐⭐⭐⭐ (conventions > configs) | ⭐⭐⭐⭐⭐ (já sabe React) |
| **Deploy VPS** | ⭐⭐⭐⭐⭐ Simples (Puma + Nginx) | ⭐⭐⭐⭐ (Next.js server) |

### 1.2 Vantagens Rails para Este Projeto

✅ **WebSocket nativo (Action Cable)** - crucial para sincronização casal
✅ **Background jobs (Sidekiq)** - para gerar resumos sem bloquear
✅ **ORM poderoso (ActiveRecord)** - relações complexas (listas, membros, tags)
✅ **Migrations** - controlar evolução do banco
✅ **Generators** - scaffold rápido
✅ **Convention over Configuration** - menos código boilerplate
✅ **Gems úteis** - para praticamente tudo (JWT, TMDB, Claude, etc)

### 1.3 Desvantagens Rails

❌ Startup mais lento (milissegundos)
❌ Ruby é mais lento que Node (mas não importa para vocês 2)
❌ Menos popular entre startups recentes
❌ Deploy requer conhecimento de DevOps (Puma, Nginx, systemd)

**Veredito:** Rails é **melhor escolha** para este projeto

---

## 2. Stack Técnico Recomendado (Rails)

### 2.1 Backend

```
Ruby on Rails 7+ (ou 8+)
├── Web Server
│   ├── Puma (padrão, muito bom)
│   └── Unicorn (alternativa, menos usado)
│
├── Banco de Dados
│   ├── PostgreSQL (recomendado)
│   └── Migrations (versionamento)
│
├── Autenticação & Authorization
│   ├── Devise (registro/login)
│   ├── JWT (tokens para API)
│   └── Pundit (autorização por recurso)
│
├── API
│   ├── Rails default (actionpack)
│   └── Serializers (fast_jsonapi ou blueprinter)
│
├── Real-time
│   ├── Action Cable (WebSocket nativo)
│   └── Turbo (opcional, para HTML over the wire)
│
├── Background Jobs
│   ├── Sidekiq (para gerar resumos IA)
│   └── Redis (queue)
│
├── External APIs
│   ├── httparty ou rest-client (TMDB, OMDb, Claude)
│   └── anthropic-ruby (oficial Claude SDK)
│
├── Testing
│   ├── RSpec (testes)
│   ├── Factory Bot (dados de teste)
│   └── WebMock (mock de APIs)
│
└── Admin & Tooling
    ├── Rails Console (debug)
    ├── RailsAdmin (opcional)
    └── Gem: awesome_print (melhor output)
```

### 2.2 Frontend

```
Escolha 1: React com Rails como API (recomendado)
├── React 19
├── TypeScript
├── Vite (build tool rápido, integra com Rails)
├── TailwindCSS
├── shadcn/ui
└── Socket.io-client (ou Action Cable JS client)

Escolha 2: HTMX + Turbo (mais "railsy")
├── Hotwire (Turbo + Stimulus)
├── TailwindCSS
├── Stimulus JS (vanilla JS integrado)
└── Action Cable (WebSocket)

Escolha 3: Inertia.js (best of both worlds)
├── React 19
├── TypeScript
├── Rails + React seamless integration
├── Vite
└── Action Cable para real-time
```

**Minha recomendação:** React com Rails como API pura
- Separação clara de conceitos
- Mais simples de entender inicialmente
- Fácil de manter/escalar

---

## 3. Comparação: Next.js vs Rails

### Estrutura de Pastas Rails

```
app/
├── models/              # Lógica de dados (User, List, Movie, etc)
│   ├── user.rb
│   ├── list.rb
│   ├── movie.rb
│   ├── list_item.rb
│   └── concerns/        # Mixins compartilhados
│
├── controllers/         # Endpoints da API
│   ├── api/
│   │   ├── lists_controller.rb
│   │   ├── items_controller.rb
│   │   ├── summaries_controller.rb
│   │   └── searches_controller.rb
│   └── pages_controller.rb
│
├── jobs/               # Background jobs (Sidekiq)
│   └── generate_episode_summary_job.rb
│
├── services/           # Lógica complexa
│   ├── tmdb_service.rb
│   ├── claude_service.rb
│   └── episode_summary_generator.rb
│
├── channels/           # WebSocket (Action Cable)
│   └── list_channel.rb
│
├── serializers/        # JSON responses
│   ├── list_serializer.rb
│   └── item_serializer.rb
│
└── policies/           # Authorization (Pundit)
    ├── list_policy.rb
    └── item_policy.rb

config/
├── routes.rb          # Rotas da API
├── database.yml       # Conexão DB
└── cable.yml          # WebSocket

db/
├── migrate/           # Migrations do banco
├── schema.rb          # Schema current
└── seeds.rb           # Dados iniciais

spec/                  # Testes
├── models/
├── controllers/
├── services/
└── jobs/
```

### Estrutura de Pastas Next.js (para comparação)

```
app/
├── api/
│   ├── lists/
│   ├── items/
│   ├── summaries/
│   └── search/
│
├── (auth)/
│   └── login/
│
└── dashboard/

lib/
├── db.ts
├── tmdb.ts
├── claude.ts
└── auth.ts

components/
├── Lists/
├── Items/
└── Shared/

types/
├── models.ts
└── api.ts
```

**Diferença:** Rails é mais opinionado (melhor para equipes pequenas)

---

## 4. Mudanças Específicas na Arquitetura

### 4.1 Autenticação

**Next.js + NextAuth:**
```javascript
// pages/api/auth/[...nextauth].js
export const authOptions = {
  providers: [Credentials({ ... })]
}
```

**Rails + Devise + JWT:**
```ruby
# config/routes.rb
devise_for :users
namespace :api do
  resources :sessions, only: [:create, :destroy]
end

# app/controllers/api/sessions_controller.rb
class Api::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user.authenticate(params[:password])
      render json: { 
        token: JsonWebToken.encode(user_id: user.id),
        user: UserSerializer.new(user)
      }
    else
      render json: { error: 'Invalid credentials' }, status: 401
    end
  end
end
```

**Fluxo:**
1. Frontend faz POST `/api/sessions` com email + password
2. Backend retorna JWT token
3. Frontend salva token em localStorage
4. Frontend envia `Authorization: Bearer {token}` em todas as requisições
5. Backend valida token em cada request

### 4.2 WebSocket / Real-time

**Next.js + Socket.io:**
```javascript
// pages/api/socket.js (Next.js API Route)
import { Server } from 'socket.io'

export default function handler(req, res) {
  if (res.socket.server.io) {
    return res.status(200).json({ ok: true })
  }

  const io = new Server(res.socket.server)
  res.socket.server.io = io

  io.on('connection', (socket) => {
    socket.on('join_list', (listId) => {
      socket.join(`list_${listId}`)
    })

    socket.on('item_added', (data) => {
      io.to(`list_${data.listId}`).emit('item_added', data)
    })
  })
}

// Frontend
const socket = io()
socket.emit('join_list', listId)
socket.on('item_added', (item) => {
  // update UI
})
```

**Rails + Action Cable:**
```ruby
# config/routes.rb
mount ActionCable.server => '/cable'

# app/channels/list_channel.rb
class ListChannel < ApplicationCable::Channel
  def subscribed
    list = List.find(params[:list_id])
    stream_for list
  end

  def item_added(data)
    list = List.find(data['list_id'])
    ListChannel.broadcast_to(list, { 
      type: 'item_added',
      item: ItemSerializer.new(Item.find(data['item_id']))
    })
  end
end

# Frontend (usando action-cable-vue ou socket.io)
const consumer = createConsumer()
consumer.subscriptions.create(
  { channel: 'ListChannel', list_id: listId },
  {
    received(data) {
      if (data.type === 'item_added') {
        // update UI
      }
    }
  }
)
```

**Vantagem Rails:** Action Cable é nativo, integrado, excelente suporte

### 4.3 Background Jobs (Gerar Resumos IA)

**Next.js + Bull (job queue):**
```javascript
// lib/queue.js
import Bull from 'bull'

const summaryQueue = new Bull('summaries', {
  redis: { host: '127.0.0.1', port: 6379 }
})

summaryQueue.process(async (job) => {
  const { episodeId } = job.data
  // gerar resumo
})

// pages/api/items/[id]/generate-summary.js
export default async function handler(req, res) {
  const { id } = req.query
  
  await summaryQueue.add({ episodeId: id }, {
    delay: 0,
    attempts: 3
  })

  res.status(202).json({ message: 'Generating summary...' })
}
```

**Rails + Sidekiq:**
```ruby
# Gemfile
gem 'sidekiq'

# app/jobs/generate_episode_summary_job.rb
class GenerateEpisodeSummaryJob < ApplicationJob
  queue_as :default

  def perform(episode_id)
    episode = Episode.find(episode_id)
    
    # Buscar dados
    prev_episode = episode.previous
    prev_summary = prev_episode.resume_ia if prev_episode
    series = episode.series
    
    # Gerar resumo
    summary_data = ClaudeService.generate_summary(
      series: series,
      current_episode: episode,
      prev_episode: prev_episode,
      prev_summary: prev_summary
    )
    
    # Salvar
    episode.create_resume_ia!(summary_data)
  end
end

# app/controllers/api/summaries_controller.rb
class Api::SummariesController < ApplicationController
  def create
    episode = Episode.find(params[:episode_id])
    GenerateEpisodeSummaryJob.perform_later(episode.id)
    
    render json: { message: 'Generating summary...' }, status: 202
  end
end

# config/sidekiq.yml
---
:concurrency: 5
:timeout: 25
:pidfile: tmp/pids/sidekiq.pid
:logfile: log/sidekiq.log
:queues:
  - default
  - mailers
```

**Vantagem Rails:** Sidekiq é melhor que Bull, mais confiável e com mais features

### 4.4 Integração com APIs Externas

**Next.js:**
```javascript
// lib/tmdb.ts
import axios from 'axios'

export const getTmdbEpisode = async (seriesId: number, season: number, episode: number) => {
  const response = await axios.get(
    `https://api.themoviedb.org/3/tv/${seriesId}/season/${season}/episode/${episode}`,
    {
      headers: {
        'Authorization': `Bearer ${process.env.TMDB_API_KEY}`
      }
    }
  )
  return response.data
}

// lib/claude.ts
export const generateSummary = async (prompt: string) => {
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': process.env.ANTHROPIC_API_KEY,
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2000,
      messages: [{ role: 'user', content: prompt }]
    })
  })
  return response.json()
}
```

**Rails:**
```ruby
# Gemfile
gem 'httparty'
gem 'anthropic-ruby' # ou usar HTTParty também

# app/services/tmdb_service.rb
class TmdbService
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'

  def self.get_episode(series_id, season, episode)
    get(
      "/tv/#{series_id}/season/#{season}/episode/#{episode}",
      headers: {
        'Authorization' => "Bearer #{ENV['TMDB_API_KEY']}"
      }
    )
  end
end

# app/services/claude_service.rb
class ClaudeService
  def self.generate_summary(series:, current_episode:, prev_episode:, prev_summary:)
    client = Anthropic::Client.new(api_key: ENV['ANTHROPIC_API_KEY'])
    
    prompt = build_prompt(
      series: series,
      current_episode: current_episode,
      prev_episode: prev_episode,
      prev_summary: prev_summary
    )
    
    response = client.messages.create(
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2000,
      messages: [
        { role: 'user', content: prompt }
      ]
    )
    
    JSON.parse(response['content'][0]['text'])
  end

  private

  def self.build_prompt(series:, current_episode:, prev_episode:, prev_summary:)
    # ... montar prompt como antes
  end
end

# app/models/episode.rb
class Episode < ApplicationRecord
  belongs_to :series, class_name: 'Movie'
  has_one :resume_ia
  
  def self.find_or_fetch(series_id, season, episode)
    where(series_id: series_id, temporada: season, episodio: episode).first_or_create! do |ep|
      tmdb_data = TmdbService.get_episode(series.tmdb_id, season, episode)
      ep.assign_attributes(
        titulo: tmdb_data['name'],
        sinopse: tmdb_data['overview'],
        aired_date: tmdb_data['air_date']
      )
    end
  end
end
```

**Vantagem Rails:** ActiveRecord integra com Services naturalmente, migrations automáticas

---

## 5. Modelo de Dados Rails (Migrations)

### 5.1 Estrutura de Migrations

```ruby
# db/migrate/20240115100001_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :name
      t.string :avatar_url
      t.boolean :email_verified, default: false
      t.datetime :email_verified_at
      t.string :theme, default: 'auto'
      t.boolean :notifications_enabled, default: true
      
      t.timestamps
      t.datetime :deleted_at
    end
    
    add_index :users, :email, unique: true
    add_index :users, :deleted_at
  end
end

# db/migrate/20240115100002_create_lists.rb
class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists, id: :uuid do |t|
      t.references :owner, foreign_key: { to_table: :users }, type: :uuid
      t.string :name, null: false
      t.text :description
      t.string :type_list, null: false, default: 'private' # 'private' ou 'shared'
      
      t.timestamps
      t.datetime :archived_at
      t.datetime :deleted_at
    end
    
    add_index :lists, :owner_id
    add_index :lists, :deleted_at
    add_index :lists, :archived_at
  end
end

# db/migrate/20240115100003_create_movies.rb
class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies, id: :uuid do |t|
      t.string :imdb_id, null: false
      t.integer :tmdb_id
      t.string :title, null: false
      t.integer :year
      t.string :media_type, null: false # 'film', 'series'
      t.string :poster_url
      t.decimal :rating_imdb, precision: 3, scale: 1
      t.text :sinopse
      t.string :genres, array: true, default: []
      t.integer :runtime_minutes # filmes
      t.integer :total_seasons # séries
      t.integer :total_episodes # séries
      
      t.timestamps
    end
    
    add_index :movies, :imdb_id, unique: true
    add_index :movies, :tmdb_id
  end
end

# db/migrate/20240115100004_create_episodes.rb
class CreateEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :episodes, id: :uuid do |t|
      t.references :series, foreign_key: { to_table: :movies }, type: :uuid
      t.string :imdb_id
      t.integer :temporada, null: false
      t.integer :episodio, null: false
      t.string :titulo
      t.text :sinopse
      t.date :aired_date
      t.integer :runtime_minutes
      t.decimal :rating_imdb, precision: 3, scale: 1
      
      t.timestamps
    end
    
    add_index :episodes, [:series_id, :temporada, :episodio], unique: true
  end
end

# db/migrate/20240115100005_create_list_items.rb
class CreateListItems < ActiveRecord::Migration[7.0]
  def change
    create_table :list_items, id: :uuid do |t|
      t.references :list, foreign_key: true, type: :uuid
      t.references :movie, foreign_key: true, type: :uuid
      t.string :status, default: 'not_watched' # not_watched, watching, watched, paused, abandoned
      t.decimal :rating_pessoal, precision: 3, scale: 1
      t.text :notas
      t.string :current_episode # T2E5
      t.datetime :watched_at
      t.date :watched_date
      
      t.timestamps
      t.datetime :deleted_at
    end
    
    add_index :list_items, :list_id
    add_index :list_items, :movie_id
    add_index :list_items, :status
    add_index :list_items, [:list_id, :movie_id], unique: true
  end
end

# ... mais migrations para: list_members, tags, comentarios, votos, resumos_ia, etc
```

### 5.2 Modelos Rails (Models)

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :lists, foreign_key: 'owner_id', dependent: :destroy
  has_many :list_items, through: :lists
  has_many :comentarios, dependent: :destroy
  has_many :votos, dependent: :destroy
  
  devise :database_authenticatable, :registerable
  validates :email, presence: true, uniqueness: true
  
  def own_list?(list)
    list.owner_id == id
  end
end

# app/models/list.rb
class List < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :list_members, dependent: :destroy
  has_many :members, through: :list_members, source: :user
  has_many :list_items, dependent: :destroy
  has_many :movies, through: :list_items
  has_many :tags, dependent: :destroy
  has_many :comentarios, through: :list_items
  has_many :atividades, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }
  
  def shared?
    type_list == 'shared'
  end
  
  def private?
    type_list == 'private'
  end
  
  def visible_to?(user)
    owner_id == user.id || members.include?(user)
  end
end

# app/models/movie.rb
class Movie < ApplicationRecord
  has_many :list_items, dependent: :destroy
  has_many :lists, through: :list_items
  has_many :episodes, foreign_key: 'series_id'
  
  validates :imdb_id, uniqueness: true
  
  def self.find_or_fetch(imdb_id)
    where(imdb_id: imdb_id).first_or_create! do |movie|
      # Buscar OMDb e/ou TMDB
      omdb_data = OmdbService.get_movie(imdb_id)
      movie.assign_attributes(
        title: omdb_data['Title'],
        year: omdb_data['Year'].to_i,
        media_type: omdb_data['Type'],
        poster_url: omdb_data['Poster'],
        rating_imdb: omdb_data['imdbRating'].to_f,
        sinopse: omdb_data['Plot']
      )
    end
  end
  
  def series?
    media_type == 'series'
  end
  
  def film?
    media_type == 'film'
  end
end

# app/models/episode.rb
class Episode < ApplicationRecord
  belongs_to :series, class_name: 'Movie', foreign_key: 'series_id'
  has_one :resume_ia, dependent: :destroy
  
  def previous
    series.episodes
      .where('(temporada < ? OR (temporada = ? AND episodio < ?))',
             temporada, temporada, episodio)
      .order(temporada: :desc, episodio: :desc)
      .first
  end
  
  def next_episode
    series.episodes
      .where('(temporada > ? OR (temporada = ? AND episodio > ?))',
             temporada, temporada, episodio)
      .order(temporada: :asc, episodio: :asc)
      .first
  end
end

# app/models/resume_ia.rb
class ResumeIa < ApplicationRecord
  belongs_to :episode
  
  def self.find_or_generate(episode_id)
    find_by(episode_id: episode_id) || generate_for(episode_id)
  end
  
  def self.generate_for(episode_id)
    episode = Episode.find(episode_id)
    
    # Buscar dados
    prev_episode = episode.previous
    prev_summary = prev_episode.resume_ia if prev_episode
    
    # Gerar
    summary_data = ClaudeService.generate_summary(
      series: episode.series,
      current_episode: episode,
      prev_episode: prev_episode,
      prev_summary: prev_summary
    )
    
    create!(
      episode: episode,
      sinopse_expandida: summary_data['sinopse_expandida'],
      plot_points: summary_data['plot_points'],
      personagens: summary_data['personagens'],
      conexoes: summary_data['conexoes'],
      indicadores: summary_data['indicadores'],
      modelo_ia: 'claude-3.5-sonnet',
      token_usage: summary_data[:tokens_used]
    )
  end
end

# app/models/list_member.rb
class ListMember < ApplicationRecord
  belongs_to :list
  belongs_to :user
  
  validates :role, inclusion: { in: ['owner', 'editor', 'viewer'] }
  validates :list_id, uniqueness: { scope: :user_id }
  
  ROLES = ['owner', 'editor', 'viewer'].freeze
end

# app/models/tag.rb
class Tag < ApplicationRecord
  belongs_to :list
  has_many :item_tags, dependent: :destroy
  has_many :list_items, through: :item_tags
  
  validates :name, presence: true, uniqueness: { scope: :list_id }
end

# app/models/comentario.rb
class Comentario < ApplicationRecord
  belongs_to :list_item
  belongs_to :user
  
  validates :texto, presence: true, length: { maximum: 500 }
end

# app/models/voto.rb
class Voto < ApplicationRecord
  belongs_to :list_item
  belongs_to :user
  
  validates :voto, inclusion: { in: ['like', 'dislike', 'neutral'] }
  validates :list_item_id, uniqueness: { scope: :user_id }
end
```

---

## 6. Controllers Rails (API)

```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  
  namespace :api do
    namespace :v1 do
      resources :lists do
        resources :items do
          post :generate_summary, on: :member
        end
        resources :members
      end
      
      resources :movies, only: [:index, :show] do
        get :search, on: :collection
      end
      
      resources :episodes, only: [:show] do
        get :summary, on: :member
      end
      
      resources :users, only: [:show, :update]
      post '/sessions', to: 'sessions#create'
      delete '/sessions', to: 'sessions#destroy'
    end
  end
end

# app/controllers/api/v1/lists_controller.rb
module Api
  module V1
    class ListsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list, only: [:show, :update, :destroy]
      before_action :authorize_list!, only: [:show, :update, :destroy]
      
      # GET /api/v1/lists
      def index
        lists = current_user.lists.not_deleted.not_archived
        render json: lists, each_serializer: ListSerializer
      end
      
      # POST /api/v1/lists
      def create
        list = current_user.lists.build(list_params)
        
        if list.save
          # Log activity
          Atividade.create(
            list: list,
            user: current_user,
            acao: 'list_created'
          )
          
          # Broadcast via WebSocket
          ListChannel.broadcast_to(list, {
            type: 'list_created',
            list: ListSerializer.new(list)
          })
          
          render json: list, serializer: ListSerializer, status: :created
        else
          render json: { errors: list.errors }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/lists/:id
      def update
        if @list.update(list_params)
          Atividade.create(
            list: @list,
            user: current_user,
            acao: 'list_updated'
          )
          
          ListChannel.broadcast_to(@list, {
            type: 'list_updated',
            list: ListSerializer.new(@list)
          })
          
          render json: @list, serializer: ListSerializer
        else
          render json: { errors: @list.errors }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/lists/:id
      def destroy
        @list.soft_delete
        
        ListChannel.broadcast_to(@list, {
          type: 'list_deleted'
        })
        
        head :no_content
      end
      
      private
      
      def set_list
        @list = List.find(params[:id])
      end
      
      def authorize_list!
        authorize @list, with: ListPolicy
      end
      
      def list_params
        params.require(:list).permit(:name, :description, :type_list)
      end
    end
  end
end

# app/controllers/api/v1/items_controller.rb
module Api
  module V1
    class ItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_list
      before_action :set_item, only: [:show, :update, :destroy, :generate_summary]
      before_action :authorize_list!
      before_action :authorize_item!, only: [:update, :destroy]
      
      # GET /api/v1/lists/:list_id/items
      def index
        items = @list.list_items.not_deleted.includes(:movie)
        
        # Aplicar filtros
        items = items.where(status: params[:status]) if params[:status].present?
        
        # Aplicar ordenação
        items = apply_sorting(items, params[:sort_by])
        
        render json: items, each_serializer: ItemSerializer
      end
      
      # POST /api/v1/lists/:list_id/items
      def create
        movie = Movie.find_or_fetch(params[:imdb_id])
        item = @list.list_items.build(
          movie: movie,
          status: params[:status] || 'not_watched',
          current_episode: params[:current_episode]
        )
        
        if item.save
          Atividade.create(
            list: @list,
            user: current_user,
            acao: 'item_added',
            metadata: { item_id: item.id, movie_title: movie.title }
          )
          
          ListChannel.broadcast_to(@list, {
            type: 'item_added',
            item: ItemSerializer.new(item)
          })
          
          render json: item, serializer: ItemSerializer, status: :created
        else
          render json: { errors: item.errors }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/lists/:list_id/items/:id
      def update
        if @item.update(item_params)
          Atividade.create(
            list: @list,
            user: current_user,
            acao: 'item_updated',
            metadata: { item_id: @item.id }
          )
          
          ListChannel.broadcast_to(@list, {
            type: 'item_updated',
            item: ItemSerializer.new(@item)
          })
          
          render json: @item, serializer: ItemSerializer
        else
          render json: { errors: @item.errors }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/lists/:list_id/items/:id/generate_summary
      def generate_summary
        return render json: { error: 'Not a series' }, status: 400 unless @item.movie.series?
        
        # Enqueue background job
        GenerateEpisodeSummaryJob.perform_later(@item.id)
        
        render json: { message: 'Generating summary...' }, status: 202
      end
      
      # DELETE /api/v1/lists/:list_id/items/:id
      def destroy
        @item.soft_delete
        
        ListChannel.broadcast_to(@list, {
          type: 'item_deleted',
          item_id: @item.id
        })
        
        head :no_content
      end
      
      private
      
      def set_list
        @list = List.find(params[:list_id])
      end
      
      def set_item
        @item = @list.list_items.find(params[:id])
      end
      
      def authorize_list!
        authorize @list, with: ListPolicy
      end
      
      def authorize_item!
        authorize @item, with: ItemPolicy
      end
      
      def item_params
        params.require(:item).permit(:status, :rating_pessoal, :notas, :current_episode, :watched_date)
      end
      
      def apply_sorting(items, sort_by)
        case sort_by
        when 'title_asc'
          items.joins(:movie).order('movies.title ASC')
        when 'title_desc'
          items.joins(:movie).order('movies.title DESC')
        when 'rating_desc'
          items.order(rating_pessoal: :desc)
        when 'added_recent'
          items.order(created_at: :desc)
        else
          items.order(created_at: :asc)
        end
      end
    end
  end
end

# app/controllers/api/v1/movies_controller.rb
module Api
  module V1
    class MoviesController < ApplicationController
      # GET /api/v1/movies/search?q=breaking
      def search
        term = params[:q]
        return render json: [] if term.blank?
        
        # Buscar no banco primeiro
        cached = Movie
          .where('title ILIKE ?', "%#{term}%")
          .limit(10)
        
        # Se poucos resultados, buscar na API
        if cached.count < 10
          api_results = OmdbService.search(term)
          # Salvar novos filmes no banco
          api_results.each do |movie_data|
            Movie.find_or_fetch(movie_data['imdbID'])
          end
        end
        
        movies = Movie
          .where('title ILIKE ?', "%#{term}%")
          .limit(20)
        
        render json: movies, each_serializer: MovieSerializer
      end
    end
  end
end
```

---

## 7. Serializers (JSON)

```ruby
# app/serializers/list_serializer.rb
class ListSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :type_list, :created_at, :archived_at

  has_many :list_items, serializer: ItemSerializer
  has_many :members, serializer: UserSerializer
  
  attribute :total_items do
    object.list_items.not_deleted.count
  end
  
  attribute :is_owner do
    # Verificar se current_user é dono (passar na inicialização)
    current_user = scope&.current_user
    current_user && object.owner_id == current_user.id
  end
end

# app/serializers/item_serializer.rb
class ItemSerializer < ActiveModel::Serializer
  attributes :id, :status, :rating_pessoal, :notas, :current_episode, :watched_at, :added_at

  belongs_to :movie, serializer: MovieSerializer
  
  has_many :comentarios, serializer: ComentarioSerializer
  has_many :votos, serializer: VotoSerializer
  
  attribute :tags do
    object.tags.map { |tag| { id: tag.id, name: tag.name, color: tag.color } }
  end
end

# app/serializers/movie_serializer.rb
class MovieSerializer < ActiveModel::Serializer
  attributes :id, :imdb_id, :tmdb_id, :title, :year, :media_type, :poster_url, :rating_imdb, :genres, :total_seasons, :total_episodes
end

# app/serializers/resume_ia_serializer.rb
class ResumeIaSerializer < ActiveModel::Serializer
  attributes :id, :sinopse_expandida, :plot_points, :personagens, :conexoes, :indicadores, :gerado_em
end
```

---

## 8. Background Jobs (Sidekiq)

```ruby
# Gemfile
gem 'sidekiq'
gem 'redis'

# app/jobs/generate_episode_summary_job.rb
class GenerateEpisodeSummaryJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3, dead: true

  def perform(item_id)
    item = ListItem.find(item_id)
    episode = parse_episode(item.current_episode)
    
    # Atualizar progress (opcional)
    ActionCable.server.broadcast("item_#{item_id}", {
      type: 'summary_generating',
      progress: 'Fetching episode data...'
    })
    
    # Buscar/criar episódio
    episode_record = Episode.find_or_fetch(
      item.movie_id,
      episode[:season],
      episode[:episode]
    )
    
    # Gerar/buscar resumo
    summary = ResumeIa.find_or_generate(episode_record.id)
    
    # Broadcast final
    ActionCable.server.broadcast("item_#{item_id}", {
      type: 'summary_generated',
      summary: ResumeIaSerializer.new(summary).as_json
    })
  rescue => e
    Rails.logger.error("Error generating summary: #{e.message}")
    raise
  end

  private

  def parse_episode(episode_string)
    # Parse "T2E5" -> { season: 2, episode: 5 }
    match = episode_string.match(/T(\d+)E(\d+)/)
    { season: match[1].to_i, episode: match[2].to_i }
  end
end

# Executar sidekiq
# bundle exec sidekiq -c 5 -v
```

---

## 9. Real-time com Action Cable

```ruby
# config/cable.yml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: "app_"

# app/channels/list_channel.rb
class ListChannel < ApplicationCable::Channel
  def subscribed
    list = List.find(params[:list_id])
    
    # Verificar autorização
    unless list.visible_to?(current_user)
      reject
      return
    end
    
    stream_for list
  end

  def unsubscribed
    # Cleanup quando user desconecta
  end
  
  # Frontend pode chamar: consumer.subscriptions.subscriptions[0].send({ type: 'typing', user: 'João' })
  def typing(data)
    ListChannel.broadcast_to(list, {
      type: 'user_typing',
      user_id: current_user.id,
      user_name: current_user.name
    })
  end
end

# Frontend (React com action-cable-react ou socket.io)
import consumer from './cable'

useEffect(() => {
  const subscription = consumer.subscriptions.create(
    { channel: 'ListChannel', list_id: listId },
    {
      connected() {
        console.log('Connected to list')
      },
      received(data) {
        console.log('Received:', data)
        if (data.type === 'item_added') {
          setItems([...items, data.item])
        }
      }
    }
  )
  
  return () => subscription.unsubscribe()
}, [listId])
```

---

## 10. Deploy Rails em VPS

### 10.1 Setup Puma + Nginx

```bash
# 1. Instalar dependências
sudo apt-get update
sudo apt-get install -y ruby-full postgresql nodejs npm

# 2. Clonar repo
git clone seu-repo /var/www/app
cd /var/www/app

# 3. Instalar gems
bundle install --deployment

# 4. Setup banco
bundle exec rails db:create db:migrate

# 5. Compilar assets
bundle exec rails assets:precompile

# 6. Criar systemd service para Puma
sudo nano /etc/systemd/system/puma.service

[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/app
ExecStart=/usr/local/bin/puma -c /var/www/app/config/puma.rb
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target

sudo systemctl start puma
sudo systemctl enable puma

# 7. Setup Nginx como reverse proxy
sudo nano /etc/nginx/sites-available/app

upstream puma {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  server_name seu-dominio.com;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  location /cable {
    proxy_pass http://puma;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}

sudo systemctl restart nginx

# 8. Sidekiq para background jobs
sudo nano /etc/systemd/system/sidekiq.service

[Unit]
Description=Sidekiq Background Job Processor
After=network.target redis-server.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/app
ExecStart=/usr/local/bin/bundle exec sidekiq -c 5
Restart=on-failure

[Install]
WantedBy=multi-user.target

# 9. Redis
sudo apt-get install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

---

## 11. Gems Essenciais

```ruby
# Gemfile

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.0"

# API & JSON
gem "active_model_serializers", "~> 0.10"
gem "blueprinter" # Alternativa a active_model_serializers

# Autenticação
gem "devise"
gem "devise-jwt"
gem "jwt"

# Autorização
gem "pundit"

# Real-time
gem "actioncable-react-rails" # Ou socket.io-rails

# Background jobs
gem "sidekiq", "~> 7.0"
gem "sidekiq-scheduler" # Para jobs agendados

# APIs externas
gem "httparty"
gem "anthropic-ruby"

# Validação
gem "validates_presence_of"

# Admin (opcional)
gem "rails_admin"

# Testing
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "webmock"
end

# Development
group :development do
  gem "web-console"
  gem "awesome_print"
  gem "better_errors"
  gem "binding_of_caller"
end

gem "rack-cors" # Para CORS (se frontend separado)
```

---

## 12. Comparação Final: Rails vs Next.js

| Feature | Rails | Next.js |
|---------|-------|---------|
| **Real-time (WebSocket)** | ⭐⭐⭐⭐⭐ Action Cable | ⭐⭐⭐⭐ Socket.io |
| **Background Jobs** | ⭐⭐⭐⭐⭐ Sidekiq | ⭐⭐⭐⭐ Bull |
| **ORM/Database** | ⭐⭐⭐⭐⭐ ActiveRecord | ⭐⭐⭐⭐ Prisma |
| **Auth** | ⭐⭐⭐⭐⭐ Devise | ⭐⭐⭐⭐ NextAuth |
| **Migrations** | ⭐⭐⭐⭐⭐ Built-in | ⭐⭐⭐⭐ Prisma Migrate |
| **Admin Panel** | ⭐⭐⭐⭐⭐ RailsAdmin | ⭐⭐⭐ Terceiros |
| **Testing** | ⭐⭐⭐⭐⭐ RSpec | ⭐⭐⭐⭐ Jest/Cypress |
| **Documentação** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐⭐⭐ Excelente |
| **Deploy** | ⭐⭐⭐⭐ Puma + Nginx | ⭐⭐⭐⭐ Next.js Server |
| **Startup Speed** | ⭐⭐⭐ (some ms) | ⭐⭐⭐⭐⭐ (instant) |
| **Comunidade** | ⭐⭐⭐⭐⭐ Enorme | ⭐⭐⭐⭐⭐ Crescente |

---

## Conclusão

**Rails é a melhor escolha para este projeto** porque:

1. ✅ Action Cable (WebSocket) é nativo e excelente
2. ✅ Sidekiq + Redis para background jobs (gerar resumos)
3. ✅ ActiveRecord para relacionamentos complexos
4. ✅ Migrations para controlar evolução
5. ✅ Community gems para tudo (Devise, Pundit, etc)
6. ✅ Deploy simples (Puma + Nginx)
7. ✅ Menos boilerplate que Next.js + Express

**Vocês devem usar:**
- **Backend:** Ruby on Rails 7+
- **Frontend:** React 19 + Vite (separado, mas fácil de integrar)
- **Database:** PostgreSQL
- **Real-time:** Action Cable
- **Background Jobs:** Sidekiq + Redis
- **Deploy:** VPS (Digital Ocean, Linode) com Puma + Nginx

Isso coloca o projeto em terreno muito bem mapeado, com documentação excelente e gems maduras.

