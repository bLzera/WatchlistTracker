# 🗄️ Arquitetura de Dados - Movie & TV Series Tracker

> **Decisão arquitetural (2026-05-19):** TMDB foi descartado. Fontes externas atuais:
> - **TVMaze** — catálogo de **séries** (Shows, Episodes). Campo de junção: `tvmaze_id`.
> - **OMDb** — catálogo de **filmes**. Campo de junção: `imdb_id`.
> - **MediaWiki/Wikipedia** — plot detalhado por episódio (TV-only, cache no próprio `episodes`).
>
> O modelo mantém **uma única tabela `media`** com discriminador `kind = 'tv' | 'movie'`, em vez de tabelas separadas, para `list_items` continuar com FK simples (`media_id`).

## 1. Modelo de Entidades Relacional (MER)

```
┌─────────────────┐
│     USERS       │
├─────────────────┤
│ id (PK)         │──────────┐
│ email           │          │
│ password_hash   │          │
│ name            │          │
│ avatar_url      │          │
│ created_at      │          │
│ updated_at      │          │
│ deleted_at      │          │
└─────────────────┘          │
         │                   │
         │ 1:N               │
         ├─────────────────┐ │
         │                 │ │
    ┌────▼──────────────┐  │ │
    │ LISTS             │  │ │
    ├───────────────────┤  │ │
    │ id (PK)           │  │ │
    │ user_id (FK)──────┼──┘ │
    │ name              │    │
    │ description       │    │
    │ type (privada/    │    │
    │   compartilhada)  │    │
    │ created_at        │    │
    │ updated_at        │    │
    │ deleted_at        │    │
    │ archived_at       │    │
    └───────────────────┘    │
            │                │
            │ N:M            │
            │           ┌────▼──────────────┐
            │           │ LIST_MEMBERS      │
            │           ├───────────────────┤
            │           │ list_id (FK)      │
            │           │ user_id (FK)──────┘
            │           │ role (owner/editor/
            │           │        viewer)    │
            │           │ joined_at         │
            │           └───────────────────┘

    ┌───────────────────┐
    │ MOVIES/TV_SERIES  │
    ├───────────────────┤
    │ id (PK)           │────────────┐
    │ imdb_id           │            │ (criado quando busca
    │ title             │            │  primeira vez, salvo
    │ year              │            │  em cache)
    │ type (film/series)│            │
    │ poster_url        │            │
    │ rating_imdb       │            │
    │ sinopse           │            │
    │ genres            │            │
    │ duração/episódios │            │
    │ created_at        │            │
    └───────────────────┘            │
            │                        │
            │ 1:N                    │
            │                    ┌───▼──────────────┐
            │                    │ LIST_ITEMS       │
            │                    ├──────────────────┤
            │                    │ id (PK)          │
            │                    │ list_id (FK)     │
            │                    │ movie_id (FK)────┘
            │                    │ status           │
            │                    │ rating_pessoal   │
            │                    │ notas            │
            │                    │ current_episode  │
            │                    │   (T{x}E{y})    │
            │                    │ added_at         │
            │                    │ watched_at       │
            │                    │ watched_date     │
            │                    └──────────────────┘
            │                            │
            │                    N:M     │
            │                    ┌───────▼──────┐
            │                    │ ITEM_TAGS    │
            │                    ├──────────────┤
            │                    │ item_id (FK) │
            │                    │ tag_id (FK)  │
            │                    └──────────────┘
            │
            │ 1:N
            ├─────────────────────────────┐
            │                             │
        ┌───▼──────────────┐    ┌────────▼─────────┐
        │ EPISÓDIOS        │    │ RESUMOS_IA       │
        ├──────────────────┤    ├──────────────────┤
        │ id (PK)          │    │ id (PK)          │
        │ serie_id (FK)    │    │ episódio_id (FK) │
        │ temporada        │    │ sinopse_expandida│
        │ episódio         │    │ plot_points      │
        │ título           │    │ personagens      │
        │ sinopse_oficial  │    │ conexões         │
        │ aired_date       │    │ indicadores      │
        │ created_at       │    │ gerado_em        │
        └──────────────────┘    └──────────────────┘

┌────────────────┐
│ TAGS           │
├────────────────┤
│ id (PK)        │
│ list_id (FK)   │
│ nome           │
│ cor            │
│ created_at     │
└────────────────┘

┌────────────────────┐
│ COMENTÁRIOS        │
├────────────────────┤
│ id (PK)            │
│ item_id (FK)       │
│ user_id (FK)       │
│ texto              │
│ created_at         │
│ updated_at         │
│ deleted_at         │
└────────────────────┘

┌────────────────────┐
│ VOTOS              │
├────────────────────┤
│ id (PK)            │
│ item_id (FK)       │
│ user_id (FK)       │
│ voto (like/dislike/│
│        neutral)    │
│ created_at         │
│ updated_at         │
└────────────────────┘

┌────────────────────┐
│ ATIVIDADES         │
├────────────────────┤
│ id (PK)            │
│ list_id (FK)       │
│ user_id (FK)       │
│ ação (added/edited/│
│        voted/etc)  │
│ metadata (JSON)    │
│ created_at         │
└────────────────────┘

┌────────────────────┐
│ HISTÓRICO_BUSCAS   │
├────────────────────┤
│ id (PK)            │
│ user_id (FK)       │
│ termo              │
│ resultados_count   │
│ searched_at        │
└────────────────────┘
```

---

## 2. Definição Detalhada de Tabelas

### 2.1 USERS
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    avatar_url VARCHAR(500),
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    theme VARCHAR(20) DEFAULT 'auto', -- light, dark, auto
    notifications_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
```

### 2.2 LISTS
```sql
CREATE TABLE lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL DEFAULT 'private', -- private, shared
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archived_at TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CHECK (type IN ('private', 'shared'))
);

CREATE INDEX idx_lists_owner_id ON lists(owner_id);
CREATE INDEX idx_lists_deleted_at ON lists(deleted_at);
CREATE INDEX idx_lists_archived_at ON lists(archived_at);
```

### 2.3 LIST_MEMBERS (para listas compartilhadas)
```sql
CREATE TABLE list_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'editor', -- owner, editor, viewer
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(list_id, user_id),
    CHECK (role IN ('owner', 'editor', 'viewer'))
);

CREATE INDEX idx_list_members_list_id ON list_members(list_id);
CREATE INDEX idx_list_members_user_id ON list_members(user_id);
```

### 2.4 MEDIA (cache de filmes/séries buscadas)

Cache unificado de séries (TVMaze) e filmes (OMDb). Discriminador `kind` define qual fonte preencheu a linha.

```sql
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kind VARCHAR(10) NOT NULL,        -- 'tv' (TVMaze) | 'movie' (OMDb)
    tvmaze_id INTEGER,                -- preenchido se kind='tv'
    imdb_id VARCHAR(20),              -- preenchido sempre que disponível
    title VARCHAR(500) NOT NULL,
    year INTEGER,
    poster_url VARCHAR(500),
    rating_imdb DECIMAL(3,1),         -- OMDb.imdbRating ou TVMaze.rating.average
    sinopse TEXT,                     -- summary curto (TVMaze) ou Plot (OMDb)
    genres TEXT[],
    runtime_minutes INTEGER,          -- filmes
    total_seasons INTEGER,            -- séries
    total_episodes INTEGER,           -- séries (cacheado, atualiza junto com episodes)
    raw_payload JSONB,                -- payload bruto da API de origem (auditoria/debug)
    fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CHECK (kind IN ('tv', 'movie')),
    CHECK ((kind = 'tv'    AND tvmaze_id IS NOT NULL)
        OR (kind = 'movie' AND imdb_id   IS NOT NULL))
);

-- Unicidade por fonte (uma série por tvmaze_id, um filme por imdb_id)
CREATE UNIQUE INDEX uniq_media_tvmaze ON media(tvmaze_id) WHERE tvmaze_id IS NOT NULL;
CREATE UNIQUE INDEX uniq_media_imdb_movie ON media(imdb_id) WHERE kind = 'movie';
CREATE INDEX idx_media_kind_title ON media(kind, title);
```

> **Observação:** `list_items.media_id` (antes `movie_id`) referencia esta tabela e funciona igual para filmes e séries. Para séries, `list_items.current_episode` continua sendo `'T{x}E{y}'`.

### 2.5 EPISODES (séries — cache TVMaze + Wikipedia)

```sql
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_id UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    tvmaze_id INTEGER UNIQUE NOT NULL,
    season INTEGER NOT NULL,
    number INTEGER NOT NULL,
    name VARCHAR(500),
    summary TEXT,                     -- summary curto da TVMaze (1-2 frases)
    airdate DATE,
    runtime_minutes INTEGER,

    -- Cache Wikipedia (plot detalhado, alimenta o LLM)
    wiki_page_title VARCHAR(500),     -- ex: "Breakage (Breaking Bad)"; NULL se não achou
    wiki_url VARCHAR(500),
    wiki_plot TEXT,                   -- plot completo extraído via prop=extracts
    wiki_fetched_at TIMESTAMP,        -- NULL = nunca tentou; preenchido = já tentou (mesmo que NULL no title)

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(media_id, season, number)
);

CREATE INDEX idx_episodes_media_id ON episodes(media_id);
CREATE INDEX idx_episodes_wiki_pending ON episodes(media_id) WHERE wiki_fetched_at IS NULL;
```

> `episodes` só existe para `media.kind = 'tv'`. Aplicação garante essa invariante; não há FK condicional para mantê-la simples.

### 2.6 LIST_ITEMS (itens nas listas)
```sql
CREATE TABLE list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'not_watched',
    -- not_watched, watching, watched, paused, abandoned
    rating_pessoal DECIMAL(3,1), -- 1-10
    notas TEXT,
    current_episode VARCHAR(20), -- T{x}E{y} para séries (NULL para filmes)
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    watched_at TIMESTAMP,
    watched_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,

    UNIQUE(list_id, media_id),
    CHECK (status IN ('not_watched', 'watching', 'watched', 'paused', 'abandoned')),
    CHECK (rating_pessoal >= 1 AND rating_pessoal <= 10)
);

CREATE INDEX idx_list_items_list_id ON list_items(list_id);
CREATE INDEX idx_list_items_media_id ON list_items(media_id);
CREATE INDEX idx_list_items_status ON list_items(status);
```

### 2.7 TAGS (tags customizados por lista)
```sql
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    color VARCHAR(20) DEFAULT '#A0A0A0', -- hex color
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(list_id, name)
);

CREATE INDEX idx_tags_list_id ON tags(list_id);
```

### 2.8 ITEM_TAGS (associação item-tag)
```sql
CREATE TABLE item_tags (
    item_id UUID NOT NULL REFERENCES list_items(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (item_id, tag_id)
);

CREATE INDEX idx_item_tags_item_id ON item_tags(item_id);
CREATE INDEX idx_item_tags_tag_id ON item_tags(tag_id);
```

### 2.9 COMENTÁRIOS
```sql
CREATE TABLE comentarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES list_items(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    texto TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CHECK (length(texto) <= 500)
);

CREATE INDEX idx_comentarios_item_id ON comentarios(item_id);
CREATE INDEX idx_comentarios_user_id ON comentarios(user_id);
```

### 2.10 VOTOS
```sql
CREATE TABLE votos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES list_items(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    voto VARCHAR(50) NOT NULL, -- like, dislike, neutral
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(item_id, user_id),
    CHECK (voto IN ('like', 'dislike', 'neutral'))
);

CREATE INDEX idx_votos_item_id ON votos(item_id);
CREATE INDEX idx_votos_user_id ON votos(user_id);
```

### 2.11 RESUMOS_IA (TV-only)
```sql
CREATE TABLE resumos_ia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    episode_id UUID NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,  -- quem disparou a geração
    sinopse_expandida TEXT NOT NULL,
    plot_points JSONB,         -- array de strings
    personagens JSONB,         -- array de {nome, papel, mudanca}
    conexoes JSONB,            -- {resolucoes, progressao, prepara_proximo}
    spoiler_tags JSONB,        -- array de {trecho, severidade: leve|forte|crítico}
    contexto_reduzido BOOLEAN DEFAULT FALSE,  -- true = gerado sem wiki_plot
    modelo_ia VARCHAR(100),
    token_usage INTEGER,
    gerado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(episode_id)
);

CREATE INDEX idx_resumos_ia_episode_id ON resumos_ia(episode_id);
```

### 2.12 ATIVIDADES (log para sincronização)
```sql
CREATE TABLE atividades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    acao VARCHAR(100) NOT NULL, 
    -- added_item, edited_item, removed_item, voted, commented, etc
    metadata JSONB, -- dados adicionais (item_id, voto, etc)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_atividades_list_id ON atividades(list_id);
CREATE INDEX idx_atividades_user_id ON atividades(user_id);
CREATE INDEX idx_atividades_created_at ON atividades(created_at);
```

### 2.13 HISTÓRICO_BUSCAS
```sql
CREATE TABLE historico_buscas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    termo VARCHAR(500) NOT NULL,
    resultados_count INTEGER DEFAULT 0,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_historico_buscas_user_id ON historico_buscas(user_id);
CREATE INDEX idx_historico_buscas_searched_at ON historico_buscas(searched_at);
```

---

## 3. Principais Queries

### 3.1 Buscar Listas do Usuário (com Membros)
```sql
SELECT 
    l.id,
    l.name,
    l.description,
    l.type,
    COUNT(li.id) as total_items,
    COUNT(DISTINCT lm.user_id) as total_members,
    l.created_at
FROM lists l
LEFT JOIN list_items li ON l.id = li.list_id AND li.deleted_at IS NULL
LEFT JOIN list_members lm ON l.id = lm.list_id
WHERE l.owner_id = $1 AND l.deleted_at IS NULL AND l.archived_at IS NULL
GROUP BY l.id
ORDER BY l.created_at DESC;
```

### 3.2 Buscar Itens de Lista com Tags
```sql
SELECT 
    li.id,
    m.title,
    m.year,
    m.type,
    li.status,
    li.rating_pessoal,
    li.current_episode,
    ARRAY_AGG(DISTINCT t.name) as tags,
    ARRAY_AGG(DISTINCT t.color) as tag_colors
FROM list_items li
JOIN movies m ON li.movie_id = m.id
LEFT JOIN item_tags it ON li.id = it.item_id
LEFT JOIN tags t ON it.tag_id = t.id
WHERE li.list_id = $1 AND li.deleted_at IS NULL
GROUP BY li.id, m.id
ORDER BY li.added_at DESC;
```

### 3.3 Buscar Atividades Recentes da Lista
```sql
SELECT 
    a.id,
    a.acao,
    u.name as user_name,
    a.metadata,
    a.created_at
FROM atividades a
JOIN users u ON a.user_id = u.id
WHERE a.list_id = $1
ORDER BY a.created_at DESC
LIMIT 50;
```

### 3.4 Buscar Resumo IA do Episódio Anterior
```sql
SELECT ri.* FROM resumos_ia ri
JOIN episodes e ON ri.episodio_id = e.id
WHERE e.series_id = $1 
  AND e.temporada = $2 
  AND e.episodio = $3 - 1
LIMIT 1;
```

### 3.5 Buscar Votos de um Item
```sql
SELECT 
    voto,
    COUNT(*) as count,
    ARRAY_AGG(u.name) as users
FROM votos v
JOIN users u ON v.user_id = u.id
WHERE v.item_id = $1
GROUP BY v.voto;
```

---

## 4. Estratégia de Cache

### 4.1 Catálogo de mídias
- **O quê:** Séries (TVMaze) e filmes (OMDb).
- **Onde:** Tabela `media`.
- **Por quê cachear agressivamente:** OMDb tem só 1000 req/dia no free tier — qualquer hit no cache evita uma chamada externa.
- **Duração:** Indefinida. Re-fetch manual via job admin se metadados ficarem obsoletos (ex: série encerrou e mudou `total_seasons`).

### 4.2 Episódios + plot Wikipedia
- **O quê:** Lista de episódios (TVMaze) + plot detalhado (Wikipedia).
- **Onde:** Tabela `episodes` (campos `wiki_*` para o cache da MediaWiki).
- **Semântica do `wiki_fetched_at`:**
  - `NULL` → nunca tentou, próxima geração de resumo dispara o `WikipediaClient`.
  - `NOT NULL` com `wiki_page_title NOT NULL` → temos plot, usa direto.
  - `NOT NULL` com `wiki_page_title NULL` → já tentamos e falhou; não tenta de novo automaticamente (evita re-bater na MediaWiki em séries sem cobertura).
- **Invalidação:** manual (admin pode zerar `wiki_fetched_at` p/ forçar re-tentativa).

### 4.3 Resumos IA
- **Onde:** Tabela `resumos_ia`. Único por `episode_id`.
- **Invalidação:** explícita (usuário clica "regenerar") — descarta o registro e refaz.

### 4.4 Cache de buscas (Redis — opcional fase 2)
- Resultados de `GET /search` cacheados por 24h por termo.

---

## 5. Fluxos de Dados

### Fluxo 1: Usuário Busca Mídia
```
1. Usuário digita "Breaking Bad" com filtro de tipo (séries|filmes)
2. Frontend debounce 300ms → GET /api/v1/search?q=...&kind=tv (ou movie)
3. Backend roteia para o client correto:
   - kind='tv'    → TvmazeClient.search    (api.tvmaze.com/search/shows)
   - kind='movie' → OmdbClient.search      (omdbapi.com/?s=...&type=movie)
4. Cache local (tabela `media`) é consultado primeiro por chave externa
   (tvmaze_id ou imdb_id). Hit → retorna direto, sem chamada externa.
5. Miss → chamada à API externa → upsert em `media` com raw_payload + fetched_at.
6. Retorna lista de mídias unificadas (mesmo shape p/ tv e movie).
7. Usuário clica → frontend abre detalhes de media.id, oferece "Adicionar à Lista".
```

### Fluxo 2: Adicionar Item à Lista
```
1. Usuário seleciona lista (dropdown)
2. Frontend POST /api/lists/{listId}/items
   payload: { movie_id, status: 'not_watched', current_episode: 'T1E1' }
3. Backend valida:
   - Lista existe e user tem acesso
   - Não existe já (unique check)
4. Insert em LIST_ITEMS
5. Insert em ATIVIDADES (log): { acao: 'added_item', metadata: { item_id, movie_id } }
6. Broadcast via WebSocket a outros membros da lista
7. Frontend mostra "✓ Adicionado!"
8. Outro membro da lista vê novo item em tempo real
```

### Fluxo 3: Marcar Episódio Assistido
```
1. Usuário clica checkbox em T2E5
2. Frontend PUT /api/lists/{listId}/items/{itemId}
   payload: { current_episode: 'T2E5' }
3. Backend atualiza LIST_ITEMS.current_episode = 'T2E5'
4. Backend checa: série tem resumo IA de T2E5?
5. Se não, oferece gerar:
   - Busca episódio em EPISODES
   - Busca resumo do episódio anterior em RESUMOS_IA
   - Chama API IA (Claude/GPT) com contexto
   - Salva resultado em RESUMOS_IA
   - Retorna "Resumo gerado!" para frontend
6. Frontend exibe resumo se foi gerado
```

### Fluxo 4: Sincronização em Tempo Real (WebSocket)
```
1. Usuário A e Usuário B acessam mesma lista
2. Ambos estabelecem WebSocket com backend:
   - A: ws://backend/lists/{listId}?userId=A
   - B: ws://backend/lists/{listId}?userId=B
3. Backend mantém conexão aberta para ambos
4. A adiciona filme → POST /api/lists/{listId}/items
5. Backend salva em DB
6. Backend emite evento via WebSocket:
   - Para A: { type: 'item_added', item: {...} }
   - Para B: { type: 'item_added', item: {...} }
7. Frontend B recebe evento, atualiza UI sem refresh
8. B vê novo item em tempo real (<500ms)
```

### Fluxo 5: Gerar Resumo IA com Conexões (TV-only)

Pipeline canônico está em [`arquitetura_llm.md`](arquitetura_llm.md). Resumo: TVMaze garante os episódios em cache → WikipediaClient resolve `wiki_page_title` e baixa `wiki_plot` → Sidekiq job monta prompt com show + episódio atual + anterior + resumo anterior (se houver) → Claude retorna JSON estruturado → persistência em `resumos_ia` (UNIQUE por `episode_id`) → broadcast Action Cable. Quando Wikipedia não tem cobertura, o registro é salvo com `contexto_reduzido = true` e a UI mostra o aviso.

---

## 6. Considerações de Performance

### Índices Críticos
- `idx_lists_owner_id` - buscas rápidas de listas do usuário
- `idx_list_items_list_id` - buscas rápidas de itens da lista
- `idx_list_members_list_id` - verificar membros
- `idx_atividades_list_id` e `idx_atividades_created_at` - feed de atividades

### N+1 Query Prevention
- Sempre usar JOIN em vez de múltiplas queries
- Usar `LEFT JOIN` para dados opcionais
- `ARRAY_AGG` para consolidar tags e comentários

### Soft Deletes
- Nunca deletar, sempre usar `deleted_at` timestamp
- Verificar `WHERE deleted_at IS NULL` em todas as queries
- Permite auditoria e potencial recovery

### Limites
- Máximo 1000 requisições/dia para API OMDb (plano free)
- Máximo 10.000 itens por lista (antes de paginar)
- Máximo 100 membros por lista

---

## 7. Estrutura de Resposta JSON

### Busca de Filme
```json
{
  "id": "uuid",
  "imdb_id": "tt0903747",
  "title": "Breaking Bad",
  "year": 2008,
  "type": "series",
  "poster_url": "https://...",
  "rating_imdb": 9.5,
  "genres": ["Crime", "Drama", "Thriller"],
  "total_seasons": 5,
  "total_episodes": 62,
  "sinopse": "..."
}
```

### Lista de Itens
```json
[
  {
    "id": "uuid",
    "movie": {
      "id": "uuid",
      "title": "Breaking Bad",
      "year": 2008,
      "type": "series",
      "poster_url": "https://..."
    },
    "status": "watching",
    "rating_pessoal": null,
    "current_episode": "T2E5",
    "tags": ["favoritos", "dica-parceiro"],
    "comentarios_count": 2,
    "votos": {
      "like": 1,
      "dislike": 0,
      "neutral": 0
    },
    "added_at": "2024-01-15T10:30:00Z"
  }
]
```

### Resumo IA
```json
{
  "id": "uuid",
  "episodio": {
    "serie": "Breaking Bad",
    "temporada": 2,
    "episodio": 5,
    "titulo": "Half Measures"
  },
  "sinopse_expandida": "Walter confronts...",
  "plot_points": [
    "Walter finally confronts the drug dealers...",
    "Hank discovers a crucial clue...",
    "Marie's obsession reaches a climax..."
  ],
  "personagens": [
    {
      "nome": "Walter White",
      "importancia": "Protagonista",
      "mudancas": "Toma uma decisão crucial"
    }
  ],
  "conexoes": {
    "episodio_anterior": "T2E4",
    "titulo_anterior": "Down",
    "como_conecta": "T2E5 resolve o conflito com os traficantes que começou em T2E3, respondendo o cliffhanger de T2E4 onde Walter estava em perigo.",
    "progressao_geral": "Passamos da reação de Walter para ação direta, marcando um turning point na série.",
    "prepara_proximo": "As ações de Walter em T2E5 definem o tom para o resto da temporada."
  },
  "indicadores": [
    {
      "tipo": "crucial",
      "descricao": "Decisão que muda o curso da série"
    },
    {
      "tipo": "emocional",
      "descricao": "Momento intenso entre Walter e Skyler"
    }
  ],
  "gerado_em": "2024-01-15T10:35:00Z"
}
```

### Atividades (Feed)
```json
[
  {
    "id": "uuid",
    "user": {
      "id": "uuid",
      "name": "João"
    },
    "acao": "added_item",
    "descricao_legivel": "João adicionou Breaking Bad",
    "metadata": {
      "item_id": "uuid",
      "movie_title": "Breaking Bad"
    },
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": "uuid",
    "user": {
      "id": "uuid",
      "name": "Maria"
    },
    "acao": "voted",
    "descricao_legivel": "Maria votou 👍 em Breaking Bad",
    "metadata": {
      "item_id": "uuid",
      "voto": "like"
    },
    "created_at": "2024-01-15T10:35:00Z"
  }
]
```

