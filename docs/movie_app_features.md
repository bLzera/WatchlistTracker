# 📽️ Movie & TV Series Tracker - Especificação de Features

**Público Alvo:** Casais que querem organizar e compartilhar listas de filmes e séries que assistem ou pretendem assistir.

**Objetivo Principal:** Centralizar, organizar e colaborar em listas de mídia, com foco em não perder contexto de onde pararam em uma série.

---

## 1. Core Features

### 1.1 Autenticação & Gestão de Usuários

**Feature: Criar Conta**
- Usuário cria conta com email e senha
- Email deve ser verificado via link de confirmação
- Após confirmação, pode fazer login

**Feature: Login**
- Login via email + senha
- "Lembrar de mim" (salvar sessão)
- Recuperação de senha via email

**Feature: Perfil de Usuário**
- Editar nome, foto de perfil
- Configurações de privacidade
- Histórico de atividades (opcional)
- Preferências de notificações

---

### 1.2 Gestão de Listas

**Feature: Criar Lista Personalizada**
- Usuário cria uma lista com nome e descrição
- Tipo de lista: "Pública" (privada), "Compartilhada" (com parceiro)
- Ícone/cor opcional para identação visual
- Data de criação automática

**Feature: Editar/Deletar Lista**
- Renomear lista
- Atualizar descrição
- Mudar tipo (privada ↔ compartilhada)
- Deletar permanentemente (com confirmação)

**Feature: Listas Padrão (System Default)**
- Cada usuário tem 3 listas automáticas:
  - 📺 "Assistindo Agora" (séries em andamento)
  - ⏭️ "Quer Assistir" (na fila)
  - ✅ "Já Assistiu" (completadas)
- Não podem ser deletadas, mas podem ser customizadas

**Feature: Arquivar/Desarquivar Lista**
- Mover lista para arquivo (não desaparece, só fica oculta)
- Útil para séries que terminaram ou filmes que não interessam mais

---

### 1.3 Buscar e Adicionar Filmes/Séries

**Feature: Buscar Mídia**
- Campo de busca que conecta com OMDb/TMDB
- Resultados em tempo real
- Exibir: poster, título, ano, tipo (filme/série), rating IMDb
- Clicar no resultado para ver detalhes

**Feature: Ver Detalhes da Mídia**
- Poster de alta qualidade
- Título, ano, tipo (filme/série)
- Sinopse completa
- Rating IMDb
- Gêneros
- Duração (filme) ou número de temporadas/episódios (série)
- Elenco principal
- Link para IMDb (opcional)

**Feature: Adicionar à Lista**
- Um clique para adicionar filme/série a uma lista
- Se é série, perguntar: "Qual temporada vai começar?" (padrão: T1E1)
- Se é filme, só adiciona

**Feature: Histórico de Buscas**
- Manter últimas 15 buscas (para rápido acesso)
- Deletar histórico manualmente

---

### 1.4 Gestão de Itens nas Listas

**Feature: Status do Item**
- Dropdown com opções:
  - 🔴 "Não assistiu" (padrão)
  - 🟡 "Assistindo" (em progresso)
  - 🟢 "Assistiu" (completado)
  - ⏸️ "Pausado" (interrompeu, pode voltar)
  - ❌ "Abandonado" (não recomenda)

**Feature: Marcar Episódio (Séries)**
- Para séries, poder marcar episódios específicos como assistidos
- Exemplo: "Temporada 2, Episódio 5"
- UI: T2E5 com check/uncheck
- Mostrar progresso: "3/10" episódios assistidos

**Feature: Rating Pessoal**
- Dar nota de 1-10 para filme/série
- Mostrar sua nota vs nota IMDb (comparação)
- Nota é pessoal (não é compartilhada automaticamente, mas pode ser em listas compartilhadas)

**Feature: Adicionar Notas/Comentários**
- Campo de texto livre para anotações pessoais
- Exemplo: "Adorei os efeitos especiais", "Muito longo"
- Para listas compartilhadas, mostrar quem escreveu
- Timestamp automático

**Feature: Data de Adição**
- Data que foi adicionado à lista
- Pode marcar manualmente data que "assistiu realmente"

**Feature: Remover da Lista**
- Deletar item (com confirmação)
- Item não é deletado do banco, só removido da lista do usuário

---

### 1.5 Organização e Filtros

**Feature: Agrupar Itens**
- Agrupar por:
  - Status (não assistiu, assistindo, assistiu, etc)
  - Rating (1-3⭐, 4-6⭐, 7-10⭐)
  - Tipo (filmes vs séries)
  - Gênero
  - Data adicionado
  - Prioridade (custom tag)

**Feature: Ordenar Itens**
- Ordenar por:
  - Alfabeto (A-Z, Z-A)
  - Rating pessoal (maior, menor)
  - Rating IMDb (maior, menor)
  - Data adicionado (recente, antigo)
  - Duração (filme: maior/menor, série: episódios)
  - Data "assistido" (customizada pelo user)

**Feature: Tags/Tópicos Customizados**
- Criar tags personalizadas por lista
- Exemplo: #urgente, #favoritos, #recomendação-parceiro
- Cor customizada por tag
- Um item pode ter múltiplas tags
- Filtrar por tag

**Feature: Pesquisa Dentro da Lista**
- Buscar por título dentro de uma lista
- Pesquisar por nota/comentário
- Filtro por status

---

### 1.6 Recursos de Colaboração (Casal)

**Feature: Converter Lista em Compartilhada**
- Marcar lista como "Compartilhada"
- Gerar link de convite
- Ou enviar convite via email
- Parceiro recebe notificação + link

**Feature: Aceitar/Rejeitar Convite**
- Parceiro clica no link de convite
- Opção: aceitar ou rejeitar
- Se aceitar, lista aparece no seu dashboard
- Se rejeitar, desaparece o convite

**Feature: Permissões em Listas Compartilhadas**
- Dois tipos de acesso:
  - **Editor**: pode adicionar, editar, remover itens
  - **Visualizador**: pode só ver (útil para listas read-only)
- Dono pode mudar permissões do parceiro

**Feature: Votos em Itens**
- Em listas compartilhadas, ambos podem votar:
  - 👍 "Quer ver" (concordo)
  - 👎 "Não quer" (discordo)
  - 😐 "Indiferente" (tanto faz)
- Mostrar resultado: X vs Y votos
- Prioridade automática: mais votos 👍 aparecem no topo

**Feature: Comentários em Itens**
- Em listas compartilhadas, deixar comentários
- Exemplo: "Vi um trailer, parece legal!" ou "Lembrei que vimos essa na Netflix"
- Mostrar quem comentou, data/hora
- Notificação quando parceiro comenta

**Feature: Sincronização em Tempo Real**
- Quando um edita a lista, outro vê a mudança instantaneamente
- Sem precisar refresh da página
- Indicador visual: "X está vendo esta lista" ou "X adicionou Y"

**Feature: Histórico de Atividades**
- Feed de atividades da lista compartilhada:
  - "Maria adicionou 'Stranger Things'"
  - "João marcou 'The Office' como assistiu"
  - "Maria votou 👍 em 'Dune'"
  - "João comentou em 'Oppenheimer'"
- Data/hora de cada atividade
- Opcionalmente, notificações em tempo real

---

## 2. Feature Premium: Resumos Inteligentes com IA

### 2.1 O Problema que Resolve

Usuários (especialmente em séries longas ou pausadas) perdem o contexto de:
- Quem são os personagens principais?
- Qual era a trama principal?
- Onde paramos exatamente?
- Quais foram os acontecimentos-chave do episódio?
- Como cada episódio conecta com o anterior?

### 2.2 Feature: Resumo de Episódio com Conexão Narrativa

**Resumo Padrão (via API)**
- OMDb fornece sinopse básica do episódio
- Exibir em um card acessível

**Resumo Inteligente com IA (nossa adição)**
- Para cada episódio, usar IA (Claude, GPT, etc) para gerar:
  
  1. **Sinopse Expandida**
     - Resumo mais completo que a sinopse padrão
     - Linguagem acessível
     - 3-5 parágrafos

  2. **Plot Points Principais**
     - Listar 3-5 eventos-chave do episódio
     - Formato bullet points
     - Facilita escanear rapidamente

  3. **Personagens Destaque**
     - Quem aparece no episódio?
     - Qual é a importância deles?
     - Mudanças no arco deles?

  4. **Conexões com Episódios Anteriores** (FEATURE DIFERENCIAL)
     - Mostrar como este episódio conecta com o anterior
     - Resoluções de cliffhangers
     - Progressão da trama geral
     - Exemplo de output:
       ```
       Episódio 5 (S2E5) "O Retorno":
       - Retoma a fuga de Victor (começou em S2E3)
       - Responde a pergunta feita em S2E4: Quem é o misterioso chamador?
       - Prepara o caminho para o confronto final (S2E8)
       ```

  5. **Indicadores Importantes**
     - ⚠️ Spoiler do próximo episódio (opcional avisar)
     - 💀 Morte de personagem importante
     - 💔 Momento emocional chave
     - 🔑 Informação crucial para a trama

### 2.3 Como Funciona o Fluxo

1. Usuário marca "Assistiu Episódio T2E5"
2. App oferece: "Ver resumo inteligente?" (botão)
3. Se sim, IA gera resumo:
   - Busca contexto: qual episódio anterior assistiu?
   - Gera resumo do episódio atual
   - Faz conexões explícitas com episódio anterior
4. Resumo é salvo em cache (reutilizar depois)
5. Próxima vez que abrir série, mostra resumo do último episódio assistido

### 2.4 Implementação da IA

**Opções de Providers:**
- OpenAI (GPT-4): melhor qualidade, maior custo
- Anthropic (Claude): bom balanço qualidade/custo
- Google (Gemini): opção intermediária
- Local LLM (Ollama): grátis, menor qualidade, rodando na VPS

**Dados que a IA Usa:**
- Sinopse oficial (OMDb/TMDB)
- Título do episódio
- Número (T2E5)
- Info do episódio anterior (se disponível)
- Plot summary da série inteira (contexto)

**Prompt Estruturado para IA:**
```
Gere um resumo inteligente do seguinte episódio:

Série: {nome série}
Episódio: T{temporada}E{episódio} - {título}
Sinopse Oficial: {sinopse}

Contexto da série: {resumo geral da série}
Episódio anterior: T{temp-1}E{ep-1} - {título}
Resumo anterior: {resumo IA do episódio anterior}

Por favor, gere:
1. Uma sinopse expandida (3-5 parágrafos)
2. 3-5 plot points principais em bullet points
3. Personagens destaque e mudanças no arco deles
4. Conexões explícitas com o episódio anterior:
   - O que foi resolvido?
   - Qual cliffhanger foi respondido?
   - Como prepara o próximo?
5. Indicadores importantes (spoilers, mortes, momentos chave)

Formato: JSON estruturado
```

### 2.5 Casos de Uso

**Caso 1: Volta após pausa**
- Usuário parou em T2E5 há 2 semanas
- Volta para série: "Clique aqui para relembrar"
- Vê resumo inteligente de onde parou
- Entende contexto em 2 minutos

**Caso 2: Série com muitos personagens**
- "The Witcher", "Game of Thrones", "The Wire"
- Resumo de IA ajuda a relembrar quem faz o quê
- Conexões entre tramas paralelas ficam claras

**Caso 3: Assistir junto (casal)**
- Um assistiu T3E4 ontem, outro vai assistir hoje
- Vê resumo inteligente do que aconteceu
- Fica alinhado sem spoilers no final

**Caso 4: Série muito longa**
- "Breaking Bad" (62 episódios), "The Office" (201 episódios)
- No meio da série, usuário quer ver os momentos-chave até agora
- App gera "resumo de temporada" com as IA

---

## 3. Features Secundárias

### 3.1 Listas Dinâmicas/Filtradas

**Feature: Smart Lists (Listas Inteligentes)**
- Listas que se atualizam automaticamente baseadas em critérios:
  - "Séries que comecei mas não terminei"
  - "Filmes não assistidos com rating IMDb > 8"
  - "Tudo que votei 👍 no casal"
- Salvar critérios próprios

### 3.2 Estatísticas & Analytics

**Feature: Dashboard com Estatísticas**
- Total de filmes/séries adicionadas
- Total assistido (horas estimadas)
- Gêneros mais comuns
- Rating médio das coisas que assistiu
- Comparação com parceiro (casal): "Maria assiste mais ação que drama"
- Série com mais episódios (progressão visual)

**Feature: Badges/Achievements** (gamificação opcional)
- "Assistiu 5 episódios em 1 dia"
- "Maratona concluída: série inteira"
- "Crítico": 20+ ratings adicionados

### 3.3 Recomendações

**Feature: Sugestões Baseadas em Histórico**
- "Já que você assistiu Breaking Bad, pode gostar de..."
- Baseado em: gênero, rating, atores comuns
- Usar dados públicos (TMDB "similar movies")

**Feature: Recomendação do Parceiro**
- Tag #recomendação-parceiro em itens
- Priorizar itens recomendados ao parceiro

### 3.4 Importação/Exportação

**Feature: Importar Listas**
- De outras plataformas (Letterboxd, IMDB, Trakt)
- CSV/JSON upload
- Mapear filmes automaticamente

**Feature: Exportar Listas**
- Download em CSV, JSON, PDF
- Útil para backup ou compartilhar com amigos

### 3.5 Notificações

**Feature: Notificações**
- Quando parceiro adiciona item a lista compartilhada
- Quando parceiro comenta
- Quando novo episódio da série está disponível (integração com Trakt API)
- Opções: push notification, email, in-app

### 3.6 Modo Escuro

**Feature: Dark Mode**
- Toggle light/dark automático
- Salvar preferência do usuário

---

## 4. Features Futuras (Pós-MVP)

- Integração com serviços de streaming (onde está disponível cada mídia?)
- Sync com Trakt.tv (trazer dados de plataforma externa)
- Modo "Votação em Tempo Real" (assistindo junto, votam em qual episódio ver)
- Clube de séries: criar "clubes" com amigos, não só casal
- Watchlist colaborativa com amigos (não apenas um parceiro)
- Análise de compatibilidade de gosto (quanto casal tem de gosto parecido?)
- Integração com calendário ("próximo episódio sai em 3 dias")

---

## 5. Fluxos de Usuário Principais

### Fluxo 1: Assistindo Sozinho
```
1. Faz login
2. Abre lista "Assistindo Agora"
3. Clica em série (ex: Stranger Things)
4. Marca "Assistiu T1E5"
5. Opcionalmente, vê resumo inteligente
6. Opcionalmente, deixa rating/comentário
7. App salva tudo
```

### Fluxo 2: Casal Decidindo Série
```
1. Ambos fazem login
2. Criam lista compartilhada "Próximas Assistir (Casal)"
3. Um busca "The Office" e adiciona
4. Outro recebe notificação em tempo real
5. Segundo clica em "The Office" e vota 👍
6. Primeiro vê voto instantaneamente
7. Primeiro comenta "Todos falam que é muito bom"
8. Segundo responde no comentário
9. Decidem: "Começamos amanhã!"
10. Ambos marcam T1E1 como "Assistindo"
```

### Fluxo 3: Voltando à Série Após Pausa
```
1. Usuário abre série que deixou no meio (T2E5)
2. App mostra: "Você parou em T2E5, quer um resumo?"
3. Clica em resumo inteligente
4. Lê conexões entre T2E4 e T2E5
5. Entende o contexto em 2 minutos
6. Vai para T2E6 pronto(a)
```

### Fluxo 4: Organizando Backlog
```
1. Abre lista "Quer Assistir"
2. Organiza por prioridade (tags ou reordenar)
3. Filtra por "séries" apenas
4. Vê 47 séries na fila
5. Busca "A mais curta de todas"
6. App mostra: "The Office (201 ep) vs Sherlock (13 ep)"
7. Decide começar Sherlock
8. Move para "Assistindo Agora"
```

---

## 6. Requisitos Não-Funcionais

### Segurança
- Senhas salvas com hash (Bcrypt)
- HTTPS em produção
- JWT tokens com expiração
- Validação de dados no servidor
- Rate limiting em APIs

### Performance
- Busca de filmes em <1s (cache de resultados)
- Carregar lista em <2s
- Geração de resumo IA em <10s (ou mostrar "gerando..." se mais lento)
- Sincronização real-time <500ms

### Usabilidade
- Mobile-first design
- Acessibilidade (WCAG 2.1)
- Offline-first para leitura (sincroniza depois)
- Atalhos de teclado comuns

### Escalabilidade
- Suportar 1000+ itens por lista sem lag
- Múltiplas listas compartilhadas simultâneas
- Cache de resumos IA gerados

---

## 7. Próximas Fases de Desenvolvimento

### MVP (Fase 1)
- ✅ Auth básico
- ✅ Criar/editar listas
- ✅ Buscar e adicionar filmes/séries
- ✅ Status e rating
- ✅ Listas compartilhadas básicas
- ✅ Resumo IA de episódios (com conexão narrativa)

### Phase 2
- Smart lists
- Estatísticas
- Notificações
- Importação/exportação
- Comentários e votos melhorados

### Phase 3+
- Integração streaming
- Clube de séries
- Analytics avançadas
- Recomendações ML-powered

---

## 8. Estrutura de Dados Resumida

**Usuários**
- ID, email, senha, nome, avatar, created_at

**Listas**
- ID, user_id, nome, descrição, tipo (privada/compartilhada), created_at

**Membros de Lista** (para listas compartilhadas)
- list_id, user_id, role (owner/editor/viewer), joined_at

**Itens da Lista**
- ID, list_id, movie_id, status, rating_pessoal, notas, current_episode (T{x}E{y}), added_at, watched_at

**Filmes/Séries**
- ID, imdb_id, título, ano, tipo, poster_url, rating_imdb, sinopse, gêneros, duração

**Episódios** (para séries)
- ID, serie_id, temporada, episódio, título, sinopse_oficial, aired_date

**Resumos IA**
- ID, episódio_id, resumo_expandido, plot_points, personagens, conexões, indicadores, gerado_em

**Tags**
- ID, list_id, nome, cor

**Item Tags**
- item_id, tag_id

**Comentários** (listas compartilhadas)
- ID, item_id, user_id, texto, created_at

**Votos** (listas compartilhadas)
- ID, item_id, user_id, voto (gosto, desgosto, indiferente)

**Atividades** (log para sincronização)
- ID, list_id, user_id, ação, metadata, created_at

