# 🤖 Arquitetura de Dados para Resumos com LLM

> **Escopo:** Esta feature é **TV-only**. Filmes não têm pipeline de IA — usuários acompanham filmes apenas via tracking (OMDb).

> **Decisão arquitetural (2026-05-19):** TMDB foi descartado (custo de licença comercial). Pipeline atual:
> - **TVMaze** — catálogo (show, episodes, datas, sinopse curta).
> - **MediaWiki/Wikipedia** — plot detalhado por episódio (alimenta o contexto do LLM).
> - **Claude (Anthropic)** — gera o resumo final com tag de spoilers.

---

## 1. Fontes de Dados

### 1.1 TVMaze (catálogo de séries)

**Fornece:**
- Show: id, nome, gêneros, ano, status, sinopse curta.
- Episode list: `season`, `number`, `name`, `airdate`, `summary` (curta).
- Sem chave, sem rate limit prático (limite cortês de ~20 req/s).

**Limitação crítica:** o campo `summary` do episódio costuma ter 1–2 frases — não dá contexto suficiente para um resumo IA útil.

**Exemplo:**
```http
GET https://api.tvmaze.com/shows/169/episodebynumber?season=2&number=5
```
```json
{
  "id": 13549,
  "name": "Breakage",
  "season": 2,
  "number": 5,
  "airdate": "2009-03-29",
  "runtime": 47,
  "summary": "<p>Marie deals with stress in her own way...</p>"
}
```

### 1.2 MediaWiki / Wikipedia (plot detalhado)

**Fornece:**
- Plot por episódio quando há página dedicada (séries grandes — Breaking Bad, Game of Thrones, etc.).
- Texto limpo via `prop=extracts` (sem markup).
- Sem chave, limite cortês de 200 req/s (na prática usaremos muito menos).

**Limitação:** nem toda série tem página por episódio. Séries pequenas/recentes podem ter só uma página de "List of episodes" com tabela resumida, ou nada.

**Estratégia de lookup (ordem de tentativa):**

1. **Página dedicada do episódio.** Slug típico: `"{episode_name} ({show_name})"` ou `"{episode_name} (Breaking Bad episode)"`.
   ```
   GET https://en.wikipedia.org/w/api.php?action=query&format=json
       &prop=extracts&explaintext=1&exintro=0
       &titles=Breakage_(Breaking_Bad)
   ```
2. **Busca textual** se o slug direto falhar:
   ```
   GET .../w/api.php?action=query&list=search&srsearch=Breakage+Breaking+Bad+episode
   ```
   Pega o primeiro hit que contenha o nome da série no título.
3. **Degradação:** se nada encontrado, marca `wiki_page_title = NULL`, `wiki_fetched_at = NOW()`, e o pipeline pula o passo de plot detalhado — o LLM trabalha só com a sinopse curta da TVMaze e devolve um resumo mais raso (UI deve avisar "contexto reduzido").

> **Sem fallback Fandom** (decisão de escopo). Aceitamos cobertura parcial em troca de simplicidade.

### 1.3 Claude (Anthropic)

Gera o resumo consolidado. Recebe: contexto da série, plot do episódio atual, plot do anterior, resumo IA anterior (se houver). Retorna JSON estruturado com tag de spoilers.

---

## 2. Pipeline

```
Usuário marca "Assistiu T2E5"
            │
            ▼
┌─────────────────────────────────────────────┐
│ 1. Garantir Show no banco                   │
│    SELECT FROM shows WHERE tvmaze_id = ?    │
│    Miss → TVMaze /shows/{id} → INSERT       │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 2. Garantir Episodes T2E5 e T2E4 no banco   │
│    Miss → TVMaze /shows/{id}/episodes       │
│    (busca todos de uma vez, cacheia)        │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 3. Resolver plot Wikipedia (T2E5 e T2E4)    │
│    Para cada episode sem wiki_fetched_at:   │
│      a) tenta slug direto                   │
│      b) tenta busca textual                 │
│      c) salva wiki_page_title, wiki_url,    │
│         wiki_plot (text), wiki_fetched_at   │
│         (ou NULL se não encontrou)          │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 4. Buscar ResumoIa anterior (T2E4)          │
│    Hit  → usa como contexto                 │
│    Miss → segue só com sinopses             │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 5. Montar prompt + chamar Claude            │
│    Inputs: show.summary, ep_atual.wiki_plot │
│    (ou tvmaze summary), ep_anterior.*,      │
│    resumo_ia_anterior                       │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│ 6. Persistir ResumoIa (UNIQUE episode_id)   │
└──────────────────┬──────────────────────────┘
                   ▼
                Frontend
```

Tudo do passo 5 em diante roda em **Sidekiq job** (`GenerateEpisodeSummaryJob`) — a request HTTP do usuário responde imediato com "gerando", e o resumo aparece via Action Cable quando fica pronto.

---

## 3. Schema relevante (referência cruzada com `arquitetura_dados.md`)

```sql
-- Catálogo TVMaze
shows (
  id              uuid PK,
  tvmaze_id       integer UNIQUE NOT NULL,
  name            text NOT NULL,
  summary         text,           -- sinopse curta TVMaze
  genres          text[],
  premiered       date,
  status          text,
  ...
)

episodes (
  id              uuid PK,
  show_id         uuid FK shows,
  tvmaze_id       integer UNIQUE NOT NULL,
  season          int NOT NULL,
  number          int NOT NULL,
  name            text,
  airdate         date,
  summary         text,           -- summary curto TVMaze
  -- Cache Wikipedia
  wiki_page_title text,           -- ex: "Breakage (Breaking Bad)"
  wiki_url        text,
  wiki_plot       text,           -- plot completo (pode ser grande)
  wiki_fetched_at timestamptz,    -- NULL = nunca tentou; preenchido = já tentou
  UNIQUE(show_id, season, number)
)

resumos_ia (
  id                uuid PK,
  episode_id        uuid FK episodes UNIQUE,
  sinopse_expandida text,
  plot_points       jsonb,
  personagens       jsonb,
  conexoes          jsonb,
  spoiler_tags      jsonb,         -- [{trecho, severidade}]
  modelo_ia         text,
  token_usage       int,
  gerado_em         timestamptz DEFAULT NOW()
)
```

**Política de cache:**
- `episodes` e `wiki_plot` são imutáveis na prática (plot da Wikipedia muda raramente; quando muda, não invalida resumo IA anterior).
- Re-fetch manual via job administrativo se necessário.
- `wiki_fetched_at IS NOT NULL AND wiki_page_title IS NULL` = "já tentamos, não achou" → não tenta de novo.

---

## 4. Prompt do Claude

```text
Você é um assistente especializado em resumos de séries de TV.

CONTEXTO DA SÉRIE:
Nome: {show.name}
Gêneros: {show.genres}
Sinopse geral: {show.summary}

EPISÓDIO ATUAL:
Título: {ep.name} (T{ep.season}E{ep.number})
Data: {ep.airdate}
Sinopse curta (TVMaze): {ep.summary}
{% if ep.wiki_plot %}
Plot detalhado (Wikipedia):
{ep.wiki_plot}
{% else %}
[Plot detalhado indisponível — gere o resumo com base apenas na sinopse curta acima e indique no campo "contexto_reduzido": true]
{% endif %}

EPISÓDIO ANTERIOR:
Título: {prev_ep.name} (T{prev_ep.season}E{prev_ep.number})
{% if prev_resumo %}
Resumo IA já gerado:
{prev_resumo.sinopse_expandida}
Plot points: {prev_resumo.plot_points}
{% else %}
Sinopse curta: {prev_ep.summary}
{% endif %}

TAREFA:
Gere um resumo do episódio atual que:
1. Tenha sinopse expandida (3-5 parágrafos).
2. Liste 3-5 plot points principais.
3. Identifique personagens em destaque e suas mudanças.
4. Conecte explicitamente com o episódio anterior (o que foi resolvido,
   o que evoluiu, cliffhangers respondidos).
5. Marque trechos de spoiler em "spoiler_tags": cada item com
   {"trecho": "...", "severidade": "leve|forte|crítico"}.
   - "leve": revelação de personagem secundário ou subtrama.
   - "forte": morte, traição, twist principal do episódio.
   - "crítico": revelação que afeta o resto da temporada/série.

Retorne APENAS JSON válido (sem markdown), neste formato:
{
  "sinopse_expandida": "...",
  "plot_points": ["...", "..."],
  "personagens": [{"nome": "...", "papel": "...", "mudanca": "..."}],
  "conexoes": {
    "resolucoes": "...",
    "progressao": "...",
    "prepara_proximo": "..."
  },
  "spoiler_tags": [
    {"trecho": "...", "severidade": "forte"}
  ],
  "contexto_reduzido": false
}
```

A UI usa `spoiler_tags` para borrar/clicar-para-revelar os trechos sensíveis, e o flag `contexto_reduzido` para mostrar aviso de "resumo gerado sem plot Wikipedia".

---

## 5. Edge cases

| Cenário | Tratamento |
|---|---|
| TVMaze offline | Retry com backoff exponencial no job; falha após N tentativas → notifica usuário "tente em alguns minutos". |
| Episódio não existe (T99E99) | Validar contra `episodes` cacheado; se passar do `total_seasons` da TVMaze, retorna 404 antes do job. |
| Wikipedia sem página dedicada | `wiki_fetched_at = NOW(), wiki_page_title = NULL`; LLM segue só com sinopse curta + `contexto_reduzido: true`. |
| Wikipedia retorna disambiguation page | Detectar via flag `pageprops.disambiguation` no response; trata como "não achou". |
| Episódio anterior é T1E1 (não há anterior) | Job pula o bloco "EPISÓDIO ANTERIOR" do prompt. |
| LLM retorna JSON inválido | 1 retry com nota "Retorne JSON válido". Falha após retry → registra erro, não persiste, UI mostra "Erro ao gerar". |
| Episódio anterior sem resumo IA gerado | Usa só a sinopse curta + wiki_plot dele como contexto (não gera recursivamente — caro demais). |

---

## 6. Estimativa de custo

Por resumo gerado (Claude Sonnet 4.6, ordem de grandeza):
- Input: ~2.500 tokens (show context + wiki_plot atual ~1500 chars + wiki_plot anterior + resumo anterior).
- Output: ~500 tokens.
- Custo: ~US$ 0,015 por resumo.

Para um casal assistindo ~5 episódios/semana → ~20 resumos/mês → **~US$ 0,30/mês**. APIs de catálogo (TVMaze, MediaWiki) são gratuitas.

---

## 7. Services Rails envolvidos

| Service | Responsabilidade |
|---|---|
| `TvmazeClient` | Buscar show e lista de episódios. |
| `WikipediaClient` | Resolver título da página e baixar plot do episódio. |
| `AnthropicClient` | Chamar Claude com o prompt montado. |
| `GenerateEpisodeSummaryJob` (Sidekiq) | Orquestra passos 1–6 do pipeline. |
| `EpisodeSummaryBroadcaster` | Broadcast Action Cable do resumo pronto. |

Detalhes de implementação em `ruby_on_rails_architecture.md`.
