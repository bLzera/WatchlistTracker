# 🎬 WatchlistTracker — Contexto do Projeto

Documento-síntese: o "porquê", o "o quê" e o "como" do projeto em uma página só.
Os outros arquivos da pasta `docs/` aprofundam cada parte; este aqui é o ponto de entrada.

---

## 1. Em uma frase

App colaborativo para casais (e, no futuro, grupos) gerenciarem listas de filmes
e séries — com um diferencial: **resumos de episódio gerados por IA que conectam
narrativamente um episódio ao anterior**, para nunca mais perder o fio da meada
ao voltar a uma série pausada.

---

## 2. Problema

1. Perder contexto em séries longas ou pausadas.
2. Listas de "quero ver" espalhadas em várias plataformas.
3. Casal tem dificuldade pra decidir o que assistir junto.
4. Falta histórico do que já viu e gostou.
5. Sinopses oficiais são curtas demais e não ajudam a relembrar a trama.

## 3. Solução

- **Listas** (privadas, compartilhadas, padrão "Assistindo / Quer / Já assistiu").
- **Itens** com status, rating pessoal, notas, progresso por episódio (T2E5).
- **Colaboração em tempo real** entre parceiros (votos, comentários, sync).
- **Resumos Inteligentes com IA** — o diferencial do produto:
  sinopse expandida + plot points + personagens em destaque +
  **conexões explícitas com o episódio anterior** + indicadores (spoiler, morte,
  momento-chave). Cacheados por episódio, regeneráveis sob demanda.

---

## 4. Público e modelo de uso

- **Alvo inicial:** casal (2 usuários reais — os próprios autores).
- **Fase 1 (MVP):** gratuito, auto-hospedado em VPS.
- **Pós-MVP:** abrir para grupos/amigos, possíveis features pagas.

---

## 5. Stack técnico (decidido)

- **Backend:** Ruby on Rails 7+ — escolhido por Action Cable nativo (real-time),
  Sidekiq (jobs de IA em background), ActiveRecord para o domínio relacional.
- **Banco:** PostgreSQL (com JSONB para payloads de resumo IA).
- **Cache/queue:** Redis + Sidekiq.
- **Auth:** Devise + JWT, Pundit para autorização.
- **Real-time:** Action Cable (WebSocket).
- **APIs externas** (decisão 2026-05-19, TMDB descartado por custo de licença comercial):
  - **TVMaze** — catálogo de séries (shows, episodes, datas, sinopse curta). Sem chave, free.
  - **OMDb** — catálogo de **filmes** apenas (tracking, sem IA). Free 1000 req/dia.
  - **MediaWiki/Wikipedia** — plot detalhado por episódio (alimenta o LLM). Sem chave.
  - **Anthropic Claude** — geração dos resumos (~US$0,30/mês para 1 casal).
- **Deploy:** VPS com Puma + Nginx + systemd.

---

## 6. Domínio (entidades principais)

`USERS` · `LISTS` · `LIST_MEMBERS` (papéis: owner/editor/viewer) ·
`MOVIES_TV_SERIES` · `EPISODES` · `LIST_ITEMS` (status, rating, current_episode,
notas) · `RESUMOS_IA` (sinopse expandida, plot points, personagens, conexões,
indicadores) · `TAGS` / `ITEM_TAGS` · `COMMENTS` · `VOTES` · `ACTIVITIES` (feed).

Detalhes de SQL e queries: `arquitetura_dados.md`.

---

## 7. Pipeline da feature de IA (resumo do fluxo) — **TV-only**

1. Usuário marca "Assistiu T2E5".
2. Backend garante episódios em cache via TVMaze.
3. `WikipediaClient` resolve a página do episódio (slug direto → busca textual) e baixa o plot detalhado. Se não achar, segue em modo "contexto reduzido".
4. Sidekiq monta prompt: sinopse da série, plot Wikipedia do atual + anterior, resumo IA anterior se houver.
5. Claude retorna JSON estruturado (sinopse, plot points, personagens, conexões, **spoiler_tags**).
6. Resultado salvo em `RESUMOS_IA` e broadcast via Action Cable.

Detalhes: `arquitetura_llm.md`.

---

## 8. Escopo do MVP (Fase 1)

**Inegociáveis:**
- Auth (RF-001..004)
- CRUD de listas (RF-005..008)
- Buscar e adicionar mídia via TVMaze (séries) e OMDb (filmes) (RF-009..011)
- Status, rating, notas (RF-012..015)
- Listas compartilhadas + sync real-time (RF-022..027)
- **Resumos IA com conexão narrativa (RF-028..031) — o diferencial**

**Importantes:** tags, filtros, agrupamento, ordenação (RF-016..021).

**Fica pra Fase 2+:** smart lists, estatísticas, importação/exportação,
notificações por email, dark mode, integração com streaming, clubes de séries.

Cronograma sugerido: 12 semanas (ver `README.md` da pasta docs).

---

## 9. Requisitos não-funcionais relevantes

- Busca de mídia < 1s (cache local na tabela `media` — evita bater no OMDb/TVMaze quando já temos).
- Sync real-time < 500ms entre parceiros.
- Geração de resumo IA < 10s no caminho feliz.
- Senhas com bcrypt, HTTPS em prod, JWT com expiração, rate limiting.
- Mobile-first, responsivo.
- Suportar 1000+ itens por lista sem degradar.

---

## 10. Mapa da pasta `docs/`

| Arquivo | O que tem | Quando ler |
|---|---|---|
| `README.md` | Visão geral, cronograma, FAQ | Primeiro contato |
| `movie_app_features.md` | Catálogo de features (o QUÊ) | Antes de discutir escopo |
| `requisitos_funcionais.md` | 36 RFs com critérios de aceitação | Antes de implementar / virar testes RSpec |
| `arquitetura_dados.md` | MER, SQL, queries, fluxos de dados | Ao mexer no banco |
| `arquitetura_llm.md` | Pipeline TVMaze + MediaWiki + Claude, prompt, cache | Ao implementar a feature de IA |
| `ruby_on_rails_architecture.md` | Stack Rails, gems, estrutura de pastas, deploy | Ao codar/deployar |
| `diagrama_deploy.md` | Diagramas Mermaid: topologia de produção, fluxo de requisição, fluxo de deploy | Ao operar/debugar produção ou onboardar |
| `00_CHECKLIST_FINAL.md` | Status do que está documentado vs. faltando | Para saber o que ainda falta planejar |
| `GUIA_USO_DOCUMENTACAO.md` | Meta-guia explicando cada arquivo | Quando se perder na documentação |
| `CONTEXTO_PROJETO.md` (este) | Síntese de tudo acima | Sempre que precisar do panorama rápido |

---

## 11. O que ainda falta planejar

Identificado no `00_CHECKLIST_FINAL.md`:
- Estratégia de testes (RSpec, Factory Bot, Cypress/Playwright).
- CI/CD (GitHub Actions).
- Wireframes/mockups (Figma).
- Diagrama de deployment formal.
- Pricing model para Fase 3+.

---

## 12. Princípios de produto (norte para decisões)

- **A feature de IA é o diferencial** — qualquer trade-off de escopo deve preservá-la.
- **Casal antes de grupo** — UX e domínio modelados pra dois; generalização vem depois.
- **Real-time é parte da experiência**, não enfeite — sem sync, vira um Trello de filmes.
- **Cache agressivo** em tudo que é caro: buscas externas e resumos IA.
- **Auto-hospedável e barato** na fase 1; escalar só quando houver usuários reais além dos dois autores.
