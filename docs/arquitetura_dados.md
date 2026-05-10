# 🗄️ Arquitetura de Dados - Movie & TV Series Tracker

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

### 2.4 MOVIES (cache de filmes/séries buscadas)
```sql
CREATE TABLE movies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    imdb_id VARCHAR(20) UNIQUE NOT NULL, -- tt0000000
    title VARCHAR(500) NOT NULL,
    year INTEGER,
    type VARCHAR(50) NOT NULL, -- film, series, episode
    poster_url VARCHAR(500),
    rating_imdb DECIMAL(3,1),
    sinopse TEXT,
    genres TEXT[], -- ARRAY de gêneros
    runtime_minutes INTEGER, -- para filmes
    total_seasons INTEGER, -- para séries
    total_episodes INTEGER, -- para séries
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (type IN ('film', 'series', 'episode'))
);

CREATE INDEX idx_movies_imdb_id ON movies(imdb_id);
CREATE INDEX idx_movies_title ON movies(title);
```

### 2.5 EPISODES (episódios de séries)
```sql
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    series_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    imdb_id VARCHAR(20),
    temporada INTEGER NOT NULL,
    episódio INTEGER NOT NULL,
    título VARCHAR(500),
    sinopse TEXT,
    aired_date DATE,
    runtime_minutes INTEGER,
    rating_imdb DECIMAL(3,1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(series_id, temporada, episódio)
);

CREATE INDEX idx_episodes_series_id ON episodes(series_id);
```

### 2.6 LIST_ITEMS (itens nas listas)
```sql
CREATE TABLE list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'not_watched', 
    -- not_watched, watching, watched, paused, abandoned
    rating_pessoal DECIMAL(3,1), -- 1-10
    notas TEXT,
    current_episode VARCHAR(20), -- T{x}E{y} para séries
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    watched_at TIMESTAMP, -- data quando completou
    watched_date DATE, -- data manual que assistiu
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    UNIQUE(list_id, movie_id),
    CHECK (status IN ('not_watched', 'watching', 'watched', 'paused', 'abandoned')),
    CHECK (rating_pessoal >= 1 AND rating_pessoal <= 10)
);

CREATE INDEX idx_list_items_list_id ON list_items(list_id);
CREATE INDEX idx_list_items_movie_id ON list_items(movie_id);
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

### 2.11 RESUMOS_IA
```sql
CREATE TABLE resumos_ia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    episodio_id UUID NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- quem pediu
    sinopse_expandida TEXT NOT NULL,
    plot_points JSONB, -- array de strings com plot points
    personagens JSONB, -- array de {nome, importancia, mudanças}
    conexoes_anterior TEXT, -- conexão com episódio anterior
    indicadores JSONB, -- array de {tipo: spoiler|morte|emocional|crucial, descricao}
    modelo_ia VARCHAR(100), -- qual IA foi usada (claude, gpt4, etc)
    token_usage INTEGER, -- quantos tokens usou
    gerado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(episodio_id) -- um resumo por episódio
);

CREATE INDEX idx_resumos_ia_episodio_id ON resumos_ia(episodio_id);
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

### 4.1 Cache de Filmes/Séries (OMDb)
- **O quê:** Dados de filmes/séries da API OMDb
- **Onde:** Tabela MOVIES
- **Duração:** Indefinido (primeira busca cria, depois reutiliza)
- **Invalidação:** Atualizar anualmente (yearly)

### 4.2 Cache de Episódios
- **O quê:** Dados de episódios (título, sinopse, aired_date)
- **Onde:** Tabela EPISODES
- **Duração:** Indefinido
- **Invalidação:** Anual

### 4.3 Cache de Resumos IA
- **O quê:** Resumos gerados pela IA
- **Onde:** Tabela RESUMOS_IA
- **Duração:** Indefinido (salvo uma vez)
- **Invalidação:** Regenerar se usuário solicitar

### 4.4 Cache de Buscas (Redis - opcional fase 2)
- **O quê:** Resultados de buscas recentes
- **Onde:** Redis (na VPS)
- **Duração:** 24 horas
- **Invalidação:** TTL automático

---

## 5. Fluxos de Dados

### Fluxo 1: Usuário Busca Filme
```
1. Usuário digita "Breaking Bad" em campo de busca
2. Frontend debounce 300ms
3. Frontend chama GET /api/search?q=Breaking%20Bad
4. Backend verifica cache (Redis) por "Breaking Bad"
5. Se não em cache, chama OMDb API
6. Se em OMDb, salva em tabela MOVIES (se não existe)
7. Retorna para frontend com poster, título, etc
8. Frontend exibe resultado
9. Usuário clica em "Breaking Bad"
10. Frontend obtém detalhes completos de movies.id
11. Mostra opção "Adicionar à Lista"
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

### Fluxo 5: Gerar Resumo IA com Conexões
```
1. Usuário marca T2E5 assistido
2. App oferece: "Gerar resumo inteligente?"
3. Usuário clica "Sim"
4. Backend executa:
   a) SELECT episode WHERE series_id = X AND temp = 2 AND ep = 5
   b) SELECT resumo_anterior WHERE series_id = X AND temp = 2 AND ep = 4
   c) Monta prompt para IA:
      ```
      Série: Breaking Bad
      Episódio: T2E5 - "Half Measures"
      Sinopse oficial: "Walter..."
      
      Contexto da série: "Breaking Bad é sobre..."
      
      Episódio anterior (T2E4 "Down"):
      - Resumo: "Walter finally..."
      - Plot points: [...]
      
      Por favor gere resumo com conexões
      ```
   d) Chama Claude API com contexto
   e) Recebe resumo estruturado em JSON:
      ```json
      {
        "sinopse_expandida": "...",
        "plot_points": ["...", "..."],
        "personagens": [...],
        "conexoes": "T2E5 resolve a trama do traficante iniciada em T2E3...",
        "indicadores": [...]
      }
      ```
   f) Salva em RESUMOS_IA com unique(episodio_id)
5. Retorna para frontend
6. Frontend exibe resumo com seção especial "Conexões com T2E4"
```

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

