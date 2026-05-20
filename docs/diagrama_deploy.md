# Diagrama de Deployment — WatchlistTracker

> Visão formal de **o que roda onde** em produção, **como uma requisição flui** e **como o código chega ao servidor**. Complementa `infraestrutura_conceitos.md` (que explica o porquê de cada peça).

---

## 1. Topologia de produção

Tudo roda em **um único Droplet** na DigitalOcean (Fase 1). Produção e staging compartilham a máquina mas têm DBs e portas separadas.

```mermaid
flowchart TB
    subgraph internet["Internet"]
        user["Usuário<br/>(navegador)"]
        gh["GitHub Actions<br/>(deploy via SSH)"]
        ext["APIs externas<br/>TVMaze · OMDb · Wikipedia · Anthropic"]
    end

    subgraph do["DigitalOcean"]
        rip["Reserved IP<br/>(estático, gerenciado pelo Terraform)"]
        fw["Firewall<br/>22 · 80 · 443"]

        subgraph droplet["Droplet (Ubuntu + Docker)"]
            nginx["Nginx<br/>:80 / :443<br/>SSL + WebSocket proxy"]

            subgraph prod_stack["docker-compose.prod.yml — rede watchlist_net"]
                web_prod["web (Puma)<br/>:3000"]
                sidekiq_prod["sidekiq<br/>(jobs assíncronos)"]
                pg_prod[("postgres :5432<br/>watchlist_production")]
                redis_prod[("redis :6379<br/>cache + queue")]
            end

            subgraph staging_stack["docker-compose.staging.yml — rede própria"]
                web_stg["web_staging (Puma)<br/>:3001"]
                sidekiq_stg["sidekiq_staging"]
                pg_stg[("postgres staging")]
                redis_stg[("redis staging")]
            end
        end
    end

    user -- "HTTPS (app.example.com)" --> rip
    user -. "HTTPS (staging.example.com)" .-> rip
    rip --> fw --> nginx

    nginx -- "proxy /" --> web_prod
    nginx -- "proxy /cable (WebSocket)" --> web_prod
    nginx -. "proxy / + /cable" .-> web_stg

    web_prod --> pg_prod
    web_prod --> redis_prod
    sidekiq_prod --> pg_prod
    sidekiq_prod --> redis_prod
    sidekiq_prod -- "HTTPS" --> ext

    web_stg --> pg_stg
    web_stg --> redis_stg
    sidekiq_stg --> pg_stg
    sidekiq_stg --> redis_stg

    gh -- "SSH :22<br/>docker compose pull/up" --> droplet

    classDef external fill:#fef3c7,stroke:#d97706,color:#000
    classDef datastore fill:#dbeafe,stroke:#1d4ed8,color:#000
    classDef app fill:#dcfce7,stroke:#16a34a,color:#000
    classDef edge fill:#fce7f3,stroke:#be185d,color:#000
    class user,gh,ext external
    class pg_prod,redis_prod,pg_stg,redis_stg datastore
    class web_prod,sidekiq_prod,web_stg,sidekiq_stg app
    class nginx,rip,fw edge
```

### O que está em cada peça

| Componente | Imagem / origem | Função | Exposto à internet? |
|---|---|---|---|
| Reserved IP | Terraform (`modules/networking`) | IP estático para o DNS apontar | Sim (entry point) |
| Firewall | Terraform (`modules/server`) | Libera apenas 22/80/443 entrada; saída livre | — |
| Nginx | Instalado no host (não containerizado) | TLS, roteamento por `server_name`, upgrade WebSocket | Sim (80/443) |
| `web` | `ghcr.io/.../backend:tag` (Rails) | Puma servindo API JSON | Não (acessível só via Nginx) |
| `sidekiq` | Mesma imagem do `web` | Workers de jobs (IA, e-mails) | Não |
| `postgres` | `postgres:16-alpine` | Banco relacional | Não (rede interna Docker) |
| `redis` | `redis:7-alpine` | Cache + fila do Sidekiq | Não (rede interna Docker) |
| Stack staging | `docker-compose.staging.yml` | Mesma topologia, DB e porta separados | Não diretamente |

**Princípio:** só Nginx fala com o mundo externo na entrada. Banco e Redis vivem na rede `watchlist_net` do Docker — invisíveis fora do Droplet.

---

## 2. Fluxo de uma requisição (caminho feliz)

Exemplo: usuário marca um episódio como assistido e dispara geração de resumo IA.

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuário
    participant N as Nginx
    participant W as Rails (web)
    participant DB as PostgreSQL
    participant R as Redis
    participant S as Sidekiq
    participant API as APIs externas<br/>(Wikipedia + Claude)

    U->>N: POST /api/v1/episodes/:id/watch (HTTPS)
    N->>W: proxy HTTP (rede interna)
    W->>DB: UPDATE list_items SET current_episode=...
    W->>R: enqueue GenerateEpisodeSummaryJob
    W-->>N: 202 Accepted
    N-->>U: 202 Accepted (resposta rápida)

    Note over S,API: assíncrono
    S->>R: pop job da fila
    S->>DB: carrega episódio + série + resumo anterior
    S->>API: fetch plot Wikipedia
    S->>API: gera resumo Claude
    S->>DB: INSERT resumos_ia
    S->>W: broadcast Action Cable (via Redis)
    W-->>U: WebSocket /cable → novo resumo
```

**Pontos a notar:**
- A resposta HTTP volta em ~50ms — geração de IA não bloqueia a request.
- Redis tem dois papéis: fila de jobs (Sidekiq) e pub/sub do Action Cable.
- O WebSocket `/cable` foi aberto antes pelo cliente; o broadcast só notifica.

---

## 3. Fluxo de deploy (do commit ao servidor)

```mermaid
flowchart LR
    dev["Dev local<br/>git push"]

    subgraph ci["GitHub Actions — ci.yml"]
        sec["security<br/>brakeman + bundler-audit"]
        lint["lint<br/>rubocop"]
        test["test<br/>rspec + simplecov ≥ 80%"]
        sec --> lint --> test
    end

    subgraph cd["GitHub Actions — deploy.yml"]
        build["docker build (multi-stage)<br/>tag: sha-xxxx, branch, semver"]
        push_img["push → ghcr.io"]
        deploy_stg["deploy staging<br/>(automático em main)"]
        approve{{"aprovação manual<br/>GitHub Environments"}}
        deploy_prod["deploy produção<br/>(em tag v*.*.*)"]
    end

    subgraph server["Droplet — SSH como deploy@"]
        pull["docker compose pull"]
        up["docker compose up -d"]
        migrate["rails db:migrate"]
        prune["docker image prune"]
        pull --> up --> migrate --> prune
    end

    dev --> sec
    test -- "merge main" --> build
    test -- "tag v*.*.*" --> build
    build --> push_img
    push_img -- "main" --> deploy_stg
    push_img -- "tag" --> approve --> deploy_prod
    deploy_stg --> server
    deploy_prod --> server

    classDef gate fill:#fef3c7,stroke:#d97706,color:#000
    class approve gate
```

**Regras importantes:**
- Push em `main` → vai pra staging sozinho.
- Promover pra produção exige **criar uma tag** `v*.*.*` E **aprovar** no GitHub (Environment `production` com reviewers obrigatórios).
- Migrations rodam **após** o `up -d` — Rails 8 aguenta um instante de mismatch durante o swap dos containers; mudanças incompatíveis (drop de coluna) exigem deploy em duas fases (futuro).

---

## 4. Quando esse diagrama muda

Atualize este arquivo se:
- Separar Postgres em Droplet/serviço gerenciado próprio.
- Adicionar um segundo Droplet (load balancer entra em cena).
- Migrar Nginx para dentro de container.
- Adicionar CDN / object storage para uploads.
- Mudar de Sidekiq para outra fila.

O diagrama é fonte de verdade da **topologia atual**, não de planos futuros.
