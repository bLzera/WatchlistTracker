# 📽️ Movie & TV Series Tracker - Documentação do Projeto

## 📌 Visão Geral

**Movie & TV Series Tracker** é um aplicativo para casais (e eventualmente grupos) gerenciarem listas colaborativas de filmes e séries que querem assistir, estão assistindo ou já assistiram.

### Problema que Resolve

1. **Perder contexto** em séries longas ou pausadas
2. **Desorganização** de filmes/séries espalhados em várias plataformas
3. **Dificuldade para decidir** o que assistir junto (casal)
4. **Falta de histórico** de o que já assistiu e gostou
5. **Resumos inadequados** de episódios (sinopse padrão é insuficiente)

### Solução Única

**Resumos Inteligentes com IA** que conectam episódios de forma narrativa, ajudando o usuário a relembrar a trama geral e entender como cada episódio se conecta com o anterior.

---

## 📂 Estrutura de Documentação

Esta pasta contém 4 arquivos principais:

### 1. **movie_app_features.md** - Especificação de Features
Descreve **O QUE** o app faz, separado em:
- ✅ **Core Features** (autenticação, listas, busca, status, etc)
- 🤖 **Feature Premium: Resumos Inteligentes com IA** (diferencial)
- ⭐ **Features Secundárias** (estatísticas, sugestões, etc)
- 🔮 **Features Futuras** (pós-MVP)
- 📱 **Fluxos de Usuário** (cenários de uso)

**Leia quando:** Quer entender a visão geral do app e que features vocês vão ter.

---

### 2. **requisitos_funcionais.md** - Requisitos Funcionais Detalhados
Descreve **COMO** cada feature funciona, com:
- 📋 RF-001 até RF-036 (36 requisitos)
- Cada um com:
  - Descrição
  - Atores (quem usa)
  - Pré-condições
  - Passos
  - Critérios de Aceitação (testes)
  - Pós-condições

**Exemplo:** RF-028: Resumo Inteligente de Episódio com IA

**Leia quando:** Vai implementar uma feature e quer saber exatamente o que fazer, passos a passo, e como testar.

---

### 3. **arquitetura_dados.md** - Banco de Dados
Descreve **COMO ARMAZENAR** os dados, com:
- 🗄️ Modelo Entidade-Relacionamento (13 tabelas)
- 📊 Definição SQL de cada tabela
- 🔍 Queries importantes (buscar listas, itens, atividades, etc)
- ⚡ Cache strategy
- 🔄 Fluxos de dados (passo a passo)
- 📈 Estrutura JSON de respostas da API

**Leia quando:** Vai criar o backend/banco de dados.

---

### 4. **README.md** (este arquivo)
Seu mapa da documentação e guia rápido.

---

## 🚀 Como Usar Esta Documentação

### Cenário 1: "Vocês ainda não começaram a codificar"
1. Leia **movie_app_features.md** (visão geral)
2. Discuta quais features entram no MVP (fase 1)
3. Guardem tudo para quando forem implementar

### Cenário 2: "Vamos começar o backend"
1. Leia **requisitos_funcionais.md** - seções RF-001 a RF-010 (auth, busca)
2. Leia **arquitetura_dados.md** - tabelas USERS, MOVIES, LIST_ITEMS
3. Comece implementando auth + busca

### Cenário 3: "Vamos começar o frontend"
1. Leia **requisitos_funcionais.md** - seções RF-005 a RF-020 (criar lista, adicionar item, filtros)
2. Leia **movie_app_features.md** - seção "Fluxos de Usuário"
3. Comece implementando dashboard + criar lista

### Cenário 4: "Implementando a feature IA de resumos"
1. Leia **movie_app_features.md** - seção 2.0 (Feature Premium: Resumos Inteligentes)
2. Leia **requisitos_funcionais.md** - RF-028 até RF-031 (resumo episódio, conexões, recall)
3. Leia **arquitetura_dados.md** - tabela RESUMOS_IA e Fluxo 5

---

## 🎯 MVP (Fase 1) - Prioridades

### Features que devem estar prontas antes de publicar:

**Essenciais (não negocie):**
1. ✅ Autenticação (RF-001 até RF-004)
2. ✅ Criar/editar/deletar listas (RF-005 até RF-008)
3. ✅ Buscar filmes/séries (RF-009 até RF-011)
4. ✅ Marcar status e rating (RF-012 até RF-014)
5. ✅ Listas compartilhadas básicas (RF-022 até RF-027)
6. 🤖 **Resumos Inteligentes com IA** (RF-028 até RF-031) ← DIFERENCIAL!

**Importantes (tente incluir):**
7. ✅ Tags e filtros (RF-016 até RF-021)
8. ✅ Agrupamento e ordenação (RF-019 e RF-020)

**Pode deixar para Fase 2:**
- Smart lists (listas dinâmicas)
- Estatísticas/dashboard
- Importação/exportação
- Notificações por email
- Dark mode

---

## 🔄 Cronograma Sugerido

```
Semana 1-2: Backend Setup + Auth
  └─ RF-001 a RF-004
  └─ Arquitetura de pastas, auth flow
  
Semana 3: API de Filmes + Busca
  └─ RF-009 a RF-011
  └─ Integração OMDb
  └─ Caching
  
Semana 4-5: Listas + CRUD
  └─ RF-005 a RF-008, RF-012 a RF-015
  └─ Endpoints para criar lista, adicionar item, etc
  
Semana 6: Colaboração + WebSocket
  └─ RF-022 a RF-027
  └─ Setup WebSocket, sincronização real-time
  
Semana 7-8: Feature IA de Resumos
  └─ RF-028 a RF-031
  └─ Integração com Claude/OpenAI API
  └─ Testes
  
Semana 9-10: Frontend + Testes
  └─ React components para todas as features acima
  └─ QA
  
Semana 11-12: Deploy + Features Extras
  └─ Setup VPS
  └─ Tags, filtros, agrupamento
  └─ Launch!
```

---

## 💡 Dicas para Implementação

### Sobre a Feature de Resumos IA
- **Não é trivial**, mas é o que diferencia seu app
- Comece com prompt bem estruturado (veja em arquitetura_dados.md, Fluxo 5)
- Teste com algumas séries populares (Breaking Bad, The Office, Game of Thrones)
- Cache os resumos (uma vez gerado, reutiliza)
- Se IA for lenta (>10s), mostre "gerando..." ou faça assincronamente

### Sobre WebSocket (Sincronização)
- Crucial para experiência de casal
- Use Socket.io (mais fácil) ou ws nativo
- Teste com 2 abas abertas (ambas sincronizam)
- Sem WebSocket, app funciona mas experiência ruim

### Sobre Custos IA
- **Fase 1:** Comece com Anthropic Claude (bom custo-benefício)
  - Aprox US$2-5/mês para 2 usuários (gerando 10 resumos/mês)
- **Depois:** Considere OpenAI GPT-4 ou self-hosted LLM

### Sobre Escalabilidade
- Fase 1: PostgreSQL local é suficiente (vocês 2)
- Fase 2: Banco gerenciado (Amazon RDS, Digital Ocean)
- Cache é importante: use Redis se tiver muitas buscas

---

## 🔐 Checklist Antes de Publicar

- [ ] Todas as senhas usando hash (bcrypt)
- [ ] HTTPS em produção
- [ ] Rate limiting em APIs (1000 req/dia para OMDb)
- [ ] Email verification antes de poder usar app
- [ ] Backup automático do banco de dados
- [ ] Logs de erro centralizados
- [ ] Teste com 2 usuários reais (vocês)
- [ ] Resumo IA funcionando para 3+ séries diferentes
- [ ] WebSocket sincronizando corretamente
- [ ] Mobile-friendly (Tailwind/responsivo)

---

## 📞 Dúvidas Frequentes

**P: Por onde começar?**
A: Se vocês nunca codificaram juntos, comece com auth. Se já têm backend, comece com search + listas.

**P: Precisa de MongoDB ou só PostgreSQL?**
A: PostgreSQL é suficiente. Use JSON fields (JSONB) para dados estruturados (resumos IA, metadata).

**P: E se a IA gerar resumo ruim?**
A: Deixe usuário regenerar com mesmo prompt. Ou deixe editar/notas manuais.

**P: Precisa de Stripe para pagamento?**
A: Não, fase 1 é grátis. Fase 2+, quando tiver muitos usuários, considere plano Pro.

**P: Qual IA é melhor para resumos?**
A: Claude (Anthropic) é meu voto - custo baixo, qualidade alta, boa documentação.

---

## 📚 Referências Externas

- [OMDb API](http://www.omdbapi.com/) - Dados de filmes
- [PostgreSQL Docs](https://www.postgresql.org/docs/) - Banco de dados
- [Socket.io Docs](https://socket.io/docs/) - Real-time
- [Claude API](https://docs.anthropic.com/) - IA para resumos
- [React Query](https://tanstack.com/query/) - State management frontend
- [Express.js](https://expressjs.com/) - Backend framework

---

## 📝 Atualizações Futuras a Esta Documentação

- [ ] Adicionar wireframes/mockups (Figma)
- [ ] Adicionar exemplos de código (não implementar, só exemplos)
- [ ] Adicionar testes (Jest, Cypress)
- [ ] Adicionar diagrama de deployment (Docker, VPS)
- [ ] Adicionar pricing model para Fase 3+

---

## 👥 Autores

Documentação criada para **[Seu Nome] & [Parceira(o)]** - App de Listas de Filmes e Séries para Casais.

Data de criação: **2024-01-15**
Última atualização: **2024-01-15**
Versão: **1.0 - MVP Planning**

---

**Boa sorte com o projeto! 🍿🎬**

