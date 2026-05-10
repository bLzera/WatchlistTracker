# 🤖 Arquitetura de Dados para Geração de Resumos com LLM

## 1. Fontes de Dados Disponíveis

### 1.1 OMDb API (Já Integrada)
**O que fornece:**
- Informações básicas do filme/série
- Sinopse oficial (plot)
- Rating IMDb
- Elenco
- Gêneros
- Duração

**Limitações:**
- ❌ NÃO fornece dados de episódios específicos (para séries)
- ❌ Sinopse é genérica, não diferencia por episódio
- ❌ Informações limitadas sobre trama episódio a episódio

**Exemplo:**
```json
{
  "Title": "Breaking Bad",
  "Type": "series",
  "totalSeasons": "5",
  "Plot": "A high school chemistry teacher turned meth cook..."
}
```

### 1.2 TMDB API (The Movie Database)
**O que fornece:**
- Dados de episódios específicos (temporada + episódio)
- Sinopse de cada episódio
- Data de lançamento
- Diretor/roteirista do episódio
- Imagens por episódio
- Classificação por episódio

**Vantagens para nós:**
- ✅ EPISÓDIOS específicos (crucial!)
- ✅ Sinopse por episódio
- ✅ Metadados de produção
- ✅ API gratuita com bom limite (40 req/s)

**Exemplo:**
```json
{
  "id": 349232,
  "season_number": 2,
  "episode_number": 5,
  "name": "Half Measures",
  "overview": "Walter and Jesse face an ultimatum...",
  "air_date": "2009-04-26",
  "still_path": "/abc.jpg",
  "vote_average": 9.1,
  "crew": [
    {"job": "Director", "name": "Peter Medak"},
    {"job": "Writer", "name": "Sam Catlin"}
  ]
}
```

---

## 2. Arquitetura de Dados Recomendada

### 2.1 Pipeline de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Usuário marca: "Assistiu T2E5"                            │
│                                                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  1. BUSCAR DADOS DO EPISÓDIO                               │
│     Backend faz query:                                     │
│     SELECT * FROM episodes WHERE series_id = X            │
│            AND temp = 2 AND ep = 5                         │
│                                                             │
│  Se não encontrado no banco:                               │
│  → Chama TMDB API para buscar episódio T2E5                │
│  → Salva em tabela EPISODES (cache)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  2. BUSCAR DADOS DO EPISÓDIO ANTERIOR (T2E4)              │
│     SELECT * FROM episodes WHERE series_id = X            │
│            AND temp = 2 AND ep = 4                         │
│                                                             │
│  Se não encontrado:                                        │
│  → Chama TMDB API                                          │
│  → Salva em EPISODES                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  3. BUSCAR RESUMO ANTERIOR (SE EXISTIR)                    │
│     SELECT * FROM resumos_ia WHERE episodio_id =           │
│                (T2E4 episode_id)                            │
│                                                             │
│  Se já foi gerado antes:                                   │
│  → Reutiliza resumo anterior (cache hit)                   │
│  → Passa para o prompt da LLM                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  4. BUSCAR CONTEXTO DA SÉRIE INTEIRA                       │
│     SELECT * FROM movies WHERE id = X (a série)            │
│                                                             │
│  Dados já em cache (salvo quando usuário adicionou):       │
│  → Title, Plot geral, Gêneros, Rating IMDb, etc            │
│  → Isso vai no prompt como "contexto da série"             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  5. MONTAR PROMPT E CHAMAR LLM                             │
│     Com dados:                                             │
│     - Sinopse do T2E5 (TMDB)                               │
│     - Sinopse do T2E4 (TMDB)                               │
│     - Resumo IA anterior (banco)                           │
│     - Contexto geral da série (banco)                      │
│                                                             │
│     → Claude API (ou OpenAI GPT)                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  6. RECEBER RESPOSTA ESTRUTURADA DA LLM                    │
│     JSON com:                                              │
│     - sinopse_expandida                                    │
│     - plot_points[]                                        │
│     - personagens[]                                        │
│     - conexoes (como conecta com anterior)                 │
│     - indicadores[]                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  7. SALVAR NO BANCO (CACHE)                                │
│     INSERT INTO resumos_ia                                 │
│     (episodio_id, sinopse, plot_points, conexoes, ...)     │
│     UNIQUE(episodio_id) → garante um resumo por episódio   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  8. RETORNAR PARA FRONTEND                                 │
│     Usuário vê resumo completo                             │
│     Próxima vez que abrir, lê do banco (sem IA!)          │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Detalhamento de Cada Passo

### Passo 1: Buscar Dados do Episódio Atual (T2E5)

**Query ao Banco:**
```sql
SELECT * FROM episodes 
WHERE series_id = 'uuid-breaking-bad' 
  AND temporada = 2 
  AND episodio = 5;
```

**Se encontrar no banco:** ✅ Usa dados cached
**Se não encontrar:** 🔄 Chama TMDB API

**Chamada TMDB:**
```javascript
// GET https://api.themoviedb.org/3/tv/{series_tmdb_id}/season/2/episode/5
const episodeData = await fetch(
  `https://api.themoviedb.org/3/tv/${BREAKING_BAD_TMDB_ID}/season/2/episode/5`,
  {
    headers: { 'Authorization': `Bearer ${TMDB_API_KEY}` }
  }
);

// Retorna:
{
  "id": 62863,
  "name": "Half Measures",
  "overview": "Walter and Jesse face off when Jesse discovers...",
  "season_number": 2,
  "episode_number": 5,
  "air_date": "2009-04-26",
  "still_path": "/images/half-measures.jpg",
  "vote_average": 9.1,
  "director": "Peter Medak",
  "writer": "Sam Catlin"
}
```

**Salva no Banco:**
```sql
INSERT INTO episodes 
(series_id, imdb_id, temporada, episodio, titulo, sinopse, aired_date)
VALUES 
('uuid-breaking-bad', 'tt1319221', 2, 5, 'Half Measures', 'Walter and Jesse...', '2009-04-26')
ON CONFLICT DO NOTHING; -- Se já existe, não duplica
```

---

### Passo 2: Buscar Episódio Anterior (T2E4)

**Mesma lógica que Passo 1:**
```sql
SELECT * FROM episodes 
WHERE series_id = 'uuid-breaking-bad' 
  AND temporada = 2 
  AND episodio = 4;
```

**Se não existe:**
```javascript
// GET /tv/{series_id}/season/2/episode/4
const prevEpisodeData = await TMDB.getEpisode(series_id, 2, 4);
```

**Resultado esperado:**
```json
{
  "id": 62862,
  "name": "Down",
  "overview": "Hank and Gomez continue their investigation...",
  "episode_number": 4
}
```

---

### Passo 3: Buscar Resumo do Episódio Anterior (T2E4)

**Query ao Banco:**
```sql
SELECT * FROM resumos_ia 
WHERE episodio_id = (
  SELECT id FROM episodes 
  WHERE series_id = 'uuid-breaking-bad' 
    AND temporada = 2 
    AND episodio = 4
);
```

**Dois cenários:**

**Cenário A: Resumo já foi gerado antes** ✅
```json
{
  "id": "uuid-resumo-t2e4",
  "episodio_id": "uuid-t2e4",
  "sinopse_expandida": "Hank and Gomez investigate the dealer...",
  "plot_points": ["Hank finds clue", "Walt sees photo", "Jesse is arrested"],
  "personagens": [...],
  "conexoes": null, // T2E4 não precisa de conexão (não usaremos)
  "gerado_em": "2024-01-10"
}
```
→ **Reutiliza este resumo!** (economia de API calls)

**Cenário B: Resumo NÃO foi gerado** ❌
```
SELECT * FROM resumos_ia WHERE ... → vazio
```
→ **Teremos que gerar resumo de T2E4 primeiro**
→ Ou usar apenas a sinopse do TMDB como contexto

---

### Passo 4: Buscar Contexto da Série

**Query ao Banco:**
```sql
SELECT * FROM movies 
WHERE id = 'uuid-breaking-bad';
```

**Dados esperados (já cached):**
```json
{
  "id": "uuid-breaking-bad",
  "imdb_id": "tt0903747",
  "title": "Breaking Bad",
  "year": 2008,
  "type": "series",
  "rating_imdb": 9.5,
  "sinopse": "A high school chemistry teacher, Walter White, struggling with his career...",
  "genres": ["Crime", "Drama", "Thriller"],
  "total_seasons": 5,
  "total_episodes": 62
}
```

---

### Passo 5: Montar Prompt para LLM

**Prompt estruturado para Claude:**

```javascript
const prompt = `
Você é um assistente especializado em resumos de séries de TV.

INFORMAÇÕES DA SÉRIE:
Nome: ${series.title}
Gêneros: ${series.genres.join(', ')}
Rating IMDb: ${series.rating_imdb}
Sinopse Geral: ${series.sinopse}

EPISÓDIO ATUAL:
Nome: ${currentEpisode.titulo} (T${currentEpisode.temporada}E${currentEpisode.episodio})
Data de Lançamento: ${currentEpisode.aired_date}
Sinopse Oficial: ${currentEpisode.sinopse}
Diretor: ${currentEpisode.director}
Roteirista: ${currentEpisode.writer}

EPISÓDIO ANTERIOR:
Nome: ${prevEpisode.titulo} (T${prevEpisode.temporada}E${prevEpisode.episodio})
Sinopse Oficial: ${prevEpisode.sinopse}

RESUMO DO EPISÓDIO ANTERIOR (gerado por IA):
${resumoAnterior.sinopse_expandida}

Plot Points anteriores:
${resumoAnterior.plot_points.map((p) => `- ${p}`).join('\n')}

---

TAREFA:
Gere um resumo inteligente do episódio atual (${currentEpisode.titulo}) que:

1. Provide uma sinopse expandida (3-5 parágrafos) mais detalhada que a sinopse oficial

2. Liste 3-5 plot points principais do episódio (eventos-chave)

3. Identifique personagens destaque e mudanças importantes no arco deles

4. MUITO IMPORTANTE - Faça conexões explícitas com o episódio anterior:
   - O que foi resolvido do episódio anterior neste?
   - Qual cliffhanger do anterior foi respondido?
   - Como este episódio evolui a trama geral?
   - Como este episódio prepara o próximo?

5. Indique momentos importantes com ícones:
   - ⚠️ Spoiler ou informação crucial
   - 💀 Morte ou acontecimento traumático
   - 💔 Momento emocional intenso
   - 🔑 Informação crucial para entender a trama futura

Retorne APENAS JSON válido, sem markdown, no seguinte formato:
{
  "sinopse_expandida": "...",
  "plot_points": ["...", "...", "..."],
  "personagens": [
    {"nome": "Walter White", "importancia": "Protagonista", "mudancas": "..."}
  ],
  "conexoes": {
    "episodio_anterior": "T2E4",
    "titulo_anterior": "Down",
    "resoluções": "...",
    "cliffhangers_respondidos": "...",
    "progressao_trama": "...",
    "prepara_proximo": "..."
  },
  "indicadores": [
    {"tipo": "crucial", "descricao": "..."},
    {"tipo": "emocional", "descricao": "..."}
  ]
}
`;
```

---

### Passo 6: Chamar LLM com Dados Estruturados

**Usando Claude (Anthropic):**

```javascript
const Anthropic = require("@anthropic-ai/sdk");

const client = new Anthropic();

async function gerarResumo(prompt) {
  try {
    const message = await client.messages.create({
      model: "claude-3-5-sonnet-20241022", // ou claude-3-opus
      max_tokens: 2000,
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    });

    // message.content[0].text conterá JSON
    const jsonResponse = JSON.parse(message.content[0].text);
    
    return {
      sinopse_expandida: jsonResponse.sinopse_expandida,
      plot_points: jsonResponse.plot_points,
      personagens: jsonResponse.personagens,
      conexoes: jsonResponse.conexoes, // ← ISSO É O DIFERENCIAL!
      indicadores: jsonResponse.indicadores,
      modelo_usado: "claude-3.5-sonnet",
      tokens_usados: message.usage.output_tokens + message.usage.input_tokens
    };
  } catch (error) {
    console.error("Erro ao chamar Claude API:", error);
    throw error;
  }
}
```

**Alternativa com OpenAI GPT-4:**

```javascript
const OpenAI = require("openai");

const client = new OpenAI();

async function gerarResumo(prompt) {
  try {
    const response = await client.chat.completions.create({
      model: "gpt-4-turbo",
      max_tokens: 2000,
      messages: [
        {
          role: "system",
          content: "Você é um especialista em resumos de séries. Sempre retorne JSON válido."
        },
        {
          role: "user",
          content: prompt
        }
      ]
    });

    const jsonResponse = JSON.parse(response.choices[0].message.content);
    
    return {
      ...jsonResponse,
      modelo_usado: "gpt-4-turbo",
      tokens_usados: response.usage.total_tokens
    };
  } catch (error) {
    console.error("Erro ao chamar OpenAI API:", error);
    throw error;
  }
}
```

---

### Passo 7: Salvar Resumo no Banco (Cache)

**SQL Insert:**
```sql
INSERT INTO resumos_ia 
(episodio_id, sinopse_expandida, plot_points, personagens, conexoes, indicadores, modelo_ia, token_usage, gerado_em)
VALUES 
(
  'uuid-t2e5',
  'Walter and Jesse face their greatest challenge...',
  '["Walter confronts dealers", "Jesse betrays...", "..."]::'jsonb,
  '[{"nome": "Walter", "importancia": "Protagonista", "mudancas": "..."}]'::jsonb,
  '{"episodio_anterior": "T2E4", "resoluções": "...", ...}'::jsonb,
  '[{"tipo": "crucial", "descricao": "..."}, ...]'::jsonb,
  'claude-3.5-sonnet',
  1234,
  NOW()
)
ON CONFLICT (episodio_id) DO NOTHING; -- Não duplica se já existe
```

**Próxima vez que pedir resumo de T2E5:**
```sql
SELECT * FROM resumos_ia WHERE episodio_id = 'uuid-t2e5';
-- Retorna instantaneamente (sem chamar LLM!)
```

---

## 4. Exemplo Prático Completo

### Cenário: Usuário marca "Assistiu Breaking Bad T2E5"

**Dados coletados:**

1. **Episódio T2E5 (TMDB):**
```json
{
  "name": "Half Measures",
  "overview": "Walter and Jesse face an ultimatum when a dealer they know is threatened by another dealer. Hank gets a clue...",
  "episode_number": 5,
  "season_number": 2,
  "air_date": "2009-04-26"
}
```

2. **Episódio T2E4 (TMDB):**
```json
{
  "name": "Down",
  "overview": "Hank and Gomez continue their investigation which becomes personal. Walter sees something he didn't expect...",
  "episode_number": 4,
  "season_number": 2
}
```

3. **Resumo T2E4 (Banco - já foi gerado antes):**
```json
{
  "sinopse_expandida": "The investigation heats up as Hank and Gomez...",
  "plot_points": ["Hank finds new evidence", "Walter discovers something troubling", "Tension builds between characters"],
  "personagens": [...]
}
```

4. **Série (Banco - já cached):**
```json
{
  "title": "Breaking Bad",
  "sinopse": "A high school chemistry teacher turned meth cook...",
  "genres": ["Crime", "Drama"]
}
```

**Prompt Montado:**
```
Você é um assistista especializado em resumos de séries de TV.

INFORMAÇÕES DA SÉRIE:
Nome: Breaking Bad
Gêneros: Crime, Drama, Thriller
...

EPISÓDIO ATUAL:
Nome: Half Measures (T2E5)
Data: 2009-04-26
Sinopse: Walter and Jesse face an ultimatum...

EPISÓDIO ANTERIOR:
Nome: Down (T2E4)
Sinopse: Hank and Gomez continue their investigation...

RESUMO ANTERIOR (IA):
The investigation heats up as Hank and Gomez discover new evidence...
...

TAREFA:
Gere um resumo com conexões explícitas entre T2E4 e T2E5...
```

**Resposta da Claude:**
```json
{
  "sinopse_expandida": "Walter and Jesse reach a critical turning point...",
  "plot_points": [
    "Walter makes a crucial decision regarding the dealer",
    "Jesse discovers Walter's true motivations",
    "Hank's investigation gets closer to the truth"
  ],
  "personagens": [
    {
      "nome": "Walter White",
      "importancia": "Protagonista",
      "mudancas": "Toma uma decisão que marca um turning point na série"
    }
  ],
  "conexoes": {
    "episodio_anterior": "T2E4",
    "titulo_anterior": "Down",
    "resoluções": "T2E5 resolve o dilema de Walter que começou em T2E4",
    "cliffhangers_respondidos": "A ameaça ao dealer é finalmente encarada",
    "progressao_trama": "Este episódio marca a transição de Walter de reativo para ativo",
    "prepara_proximo": "As ações de Walter aqui definem todo o resto da série"
  },
  "indicadores": [
    {"tipo": "crucial", "descricao": "Decisão que muda o rumo da série"},
    {"tipo": "emocional", "descricao": "Confrontação intensa entre Walter e Jesse"}
  ]
}
```

**Salvo no Banco:**
```sql
INSERT INTO resumos_ia ... valores acima
```

**Retornado para Frontend:**
```json
{
  "episodio": "T2E5 - Half Measures",
  "resumo": {
    "sinopse_expandida": "...",
    "plot_points": [...],
    "conexoes": {
      "episodio_anterior": "T2E4",
      "titulo_anterior": "Down",
      "resoluções": "T2E5 resolve o dilema...",
      ...
    },
    "indicadores": [...]
  }
}
```

---

## 5. Tabela de APIs Usadas

| API | Função | Limite | Custo |
|-----|--------|--------|-------|
| **TMDB** | Dados episódio (sinopse, diretor, data, etc) | 40 req/s | Grátis + Opcional |
| **Claude (Anthropic)** | Gerar resumo com conexões | Depende do plano | $3/M (input) + $15/M (output) |
| **OpenAI GPT-4** | Alternativa para gerar resumo | Depende do plano | ~$0.03 por 1k tokens |
| **OMDb** | Dados gerais série (já integrada) | 1000/dia | Grátis |

---

## 6. Diagrama Simplificado

```
┌─────────────┐
│  Usuário    │ "Assistiu T2E5"
└──────┬──────┘
       │
       ▼
┌──────────────────────┐
│ 1. BANCO             │
│ episodes table       │◄──── Se não existe
│ T2E5 existe?         │      └─► TMDB API
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 2. BANCO             │
│ episodes table       │◄──── Se não existe
│ T2E4 existe?         │      └─► TMDB API
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 3. BANCO             │
│ resumos_ia table     │◄──── Se não existe
│ Resumo T2E4?         │      └─► Fica como TODO (ou gera)
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 4. BANCO             │
│ movies table         │
│ Série context        │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 5. MONTAR PROMPT     │
│ com dados dos        │
│ passos 1-4           │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 6. CHAMAR LLM        │
│ Claude / GPT-4       │
│ Gerar resumo        │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 7. SALVAR NO BANCO   │
│ resumos_ia table     │
│ Cache do resumo      │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ 8. RETORNAR          │
│ Frontend exibe       │
│ resumo ao usuário    │
└──────────────────────┘
```

---

## 7. Handling de Erros e Edge Cases

### Cenário A: TMDB API tá lenta ou offline

```javascript
// Timeout após 5 segundos
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch(tmdbUrl, { signal: controller.signal });
} catch (error) {
  if (error.name === 'AbortError') {
    // Fallback: usar apenas sinopse do OMDb
    console.warn("TMDB timeout, usando sinopse padrão");
    return {
      sinopse: "Sinopse indisponível no momento",
      avisar_usuario: true
    };
  }
}
```

### Cenário B: Usuário pede resumo de episódio que não existe (T99E99)

```javascript
// Validação antes de chamar TMDB
const episodioValido = await validarEpisodio(seriesId, season, episode);
if (!episodioValido) {
  return {
    erro: "Este episódio não existe ou ainda não foi lançado",
    sugestao: "Próximo episódio sai em 3 dias"
  };
}
```

### Cenário C: LLM gera resposta inválida (não é JSON)

```javascript
try {
  const resumo = JSON.parse(llmResponse);
} catch (error) {
  console.error("LLM retornou JSON inválido");
  // Tenta regenerar com novo prompt
  // Ou retorna erro ao usuário: "Tente novamente"
}
```

### Cenário D: Episódio anterior não tem resumo gerado

```javascript
// Duas opções:

// Opção 1: Usar sinopse oficial do TMDB como contexto
const contextoAnterior = resumoAnterior || episodioAnterior.sinopse;

// Opção 2: Gerar resumo anterior também
if (!resumoAnterior) {
  await gerarResumoParaEpisodio(seriesId, season, episode - 1);
  const resumoAnterior = await buscarResumo(...);
}
```

---

## 8. Fluxo Completo com Código

### Backend (Node.js/Express)

```javascript
// POST /api/lists/{listId}/items/{itemId}/generate-summary
async function generateEpisodeSummary(req, res) {
  const { listId, itemId } = req.params;
  
  try {
    // 1. Buscar item da lista
    const listItem = await db.query(
      'SELECT li.*, m.id as movie_id FROM list_items li JOIN movies m ON li.movie_id = m.id WHERE li.id = $1',
      [itemId]
    );
    
    const { current_episode, movie_id } = listItem[0]; // T2E5
    const [season, episode] = parseEpisode(current_episode); // 2, 5
    
    // 2. Buscar série do banco
    const series = await db.query('SELECT * FROM movies WHERE id = $1', [movie_id]);
    const seriesTmdbId = await getTmdbId(series[0].imdb_id);
    
    // 3. Buscar dados do episódio atual (TMDB)
    let currentEpisodeData = await db.query(
      'SELECT * FROM episodes WHERE series_id = $1 AND temporada = $2 AND episodio = $3',
      [movie_id, season, episode]
    );
    
    if (currentEpisodeData.length === 0) {
      // Buscar TMDB e salvar
      const tmdbEpisode = await tmdbClient.getEpisode(seriesTmdbId, season, episode);
      await db.query(
        'INSERT INTO episodes (series_id, temporada, episodio, titulo, sinopse, aired_date) VALUES ($1, $2, $3, $4, $5, $6)',
        [movie_id, season, episode, tmdbEpisode.name, tmdbEpisode.overview, tmdbEpisode.air_date]
      );
      currentEpisodeData = [tmdbEpisode];
    }
    
    // 4. Buscar episódio anterior
    let prevEpisodeData = await db.query(
      'SELECT * FROM episodes WHERE series_id = $1 AND temporada = $2 AND episodio = $3',
      [movie_id, season, episode - 1]
    );
    
    if (prevEpisodeData.length === 0 && episode > 1) {
      const tmdbPrevEpisode = await tmdbClient.getEpisode(seriesTmdbId, season, episode - 1);
      // ... save to DB ...
      prevEpisodeData = [tmdbPrevEpisode];
    }
    
    // 5. Buscar resumo anterior
    let prevSummary = await db.query(
      'SELECT * FROM resumos_ia WHERE episodio_id = (SELECT id FROM episodes WHERE series_id = $1 AND temporada = $2 AND episodio = $3)',
      [movie_id, season, episode - 1]
    );
    
    // 6. Montar prompt
    const prompt = buildPrompt({
      series: series[0],
      currentEpisode: currentEpisodeData[0],
      prevEpisode: prevEpisodeData[0],
      prevSummary: prevSummary[0]
    });
    
    // 7. Chamar Claude
    const summary = await claudeClient.messages.create({
      model: "claude-3-5-sonnet-20241022",
      max_tokens: 2000,
      messages: [{ role: "user", content: prompt }]
    });
    
    const parsedSummary = JSON.parse(summary.content[0].text);
    
    // 8. Salvar no banco
    const episodeId = (await db.query('SELECT id FROM episodes WHERE series_id = $1 AND temporada = $2 AND episodio = $3', [movie_id, season, episode]))[0].id;
    
    await db.query(
      `INSERT INTO resumos_ia 
       (episodio_id, sinopse_expandida, plot_points, personagens, conexoes, indicadores, modelo_ia, token_usage)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       ON CONFLICT (episodio_id) DO NOTHING`,
      [
        episodeId,
        parsedSummary.sinopse_expandida,
        JSON.stringify(parsedSummary.plot_points),
        JSON.stringify(parsedSummary.personagens),
        JSON.stringify(parsedSummary.conexoes),
        JSON.stringify(parsedSummary.indicadores),
        'claude-3.5-sonnet',
        summary.usage.input_tokens + summary.usage.output_tokens
      ]
    );
    
    // 9. Retornar
    return res.json({
      success: true,
      summary: parsedSummary,
      gerado_em: new Date()
    });
    
  } catch (error) {
    console.error("Erro ao gerar resumo:", error);
    return res.status(500).json({ error: "Erro ao gerar resumo" });
  }
}
```

---

## 9. Custo Estimado (Fase 1: Vocês Dois)

### Cenário: Gerar 1 resumo por semana

**Claude API:**
- Prompt: ~800 tokens (incluindo contexto)
- Resposta: ~400 tokens
- **1 resumo = 1200 tokens = $0.0024** (Claude 3.5 Sonnet: $0.003 input + $0.015 output)
- **4 resumos/mês = ~$0.01/mês** ✅

**TMDB API:**
- Chamadas para episódios: ~$0 (grátis)
- Rate limit: 40 req/segundo (mais que suficiente)

**Total mensal: ~$1-2/mês** (considere sempre OpenAI como backup: similar ou melhor preço)

---

## 10. Fluxo Alternativo: Sem TMDB (Apenas OMDb)

Se decidir NÃO usar TMDB:

```
❌ TMDB (dados episódio específico)
↓
Use apenas:
- Sinopse geral da série (OMDb)
- Episódio que usuário marca (banco)
- Resumos anteriores (banco)

PROBLEMA: Sem sinopse específica do episódio, a qualidade do resumo cai muito.
O resumo IA teria que "adivinhar" o que acontece em cada episódio.

SOLUÇÃO: Deixar usuário adicionar sinopse manual ou usar web scraping (não recomendo).
```

**Recomendação: USE TMDB** (melhor qualidade, grátis)

