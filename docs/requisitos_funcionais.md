# 📋 Requisitos Funcionais - Movie & TV Series Tracker

## RF-001: Registrar Novo Usuário

**Descrição:** Um novo usuário pode criar uma conta no aplicativo fornecendo email e senha.

**Atores:** Usuário não autenticado

**Pré-condições:** Usuário tem acesso à página de registro

**Passos:**
1. Usuário preenche email válido
2. Usuário cria senha com mínimo 8 caracteres
3. Usuário confirma a senha
4. Clica em "Criar Conta"

**Critérios de Aceitação:**
- ✅ Email deve ser válido (formato correto, exemplo: user@domain.com)
- ✅ Senha deve ter mínimo 8 caracteres
- ✅ Confirmar senha deve ser igual à senha
- ✅ Email deve ser único (não pode já estar registrado)
- ✅ Mensagem de erro clara se email já existe
- ✅ Mensagem de erro clara se campos inválidos
- ✅ Após registro, enviar email de confirmação
- ✅ Link de confirmação válido por 24h
- ✅ Após confirmar email, redirecionar para login
- ✅ Usuário não pode fazer login antes de confirmar email
- ✅ Opção "Reenviar email de confirmação" se não recebeu

**Pós-condições:** Usuário é criado no banco de dados, email de confirmação é enviado

---

## RF-002: Fazer Login

**Descrição:** Um usuário registrado pode fazer login com email e senha.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem conta criada e email confirmado

**Passos:**
1. Usuário insere email
2. Usuário insere senha
3. Clica em "Entrar"

**Critérios de Aceitação:**
- ✅ Credenciais corretas = acesso ao dashboard
- ✅ Credenciais incorretas = mensagem de erro (sem revelar qual campo está errado)
- ✅ Email não confirmado = mensagem explicando necessidade de confirmar
- ✅ Opção "Lembrar de mim" mantém sessão por 30 dias
- ✅ Logout limpa sessão
- ✅ Tentar 5x com senha errada = conta bloqueada temporariamente (15 min)

**Pós-condições:** Token de autenticação é gerado, usuário redirecionado para dashboard

---

## RF-003: Recuperar Senha Esquecida

**Descrição:** Um usuário que esqueceu a senha pode recuperá-la via email.

**Atores:** Usuário não autenticado

**Pré-condições:** Usuário tem conta criada

**Passos:**
1. Na tela de login, clica "Esqueci a senha"
2. Insere email
3. Clica "Enviar link de recuperação"

**Critérios de Aceitação:**
- ✅ Email deve existir na base de dados
- ✅ Mensagem de sucesso mesmo que email não exista (por segurança)
- ✅ Email com link de recuperação enviado
- ✅ Link válido por 1 hora
- ✅ Ao clicar link, usuário vai para página de nova senha
- ✅ Nova senha deve ter mínimo 8 caracteres
- ✅ Após trocar, redirecionar para login
- ✅ Link expirado = mensagem clara, opção de solicitar novo

**Pós-condições:** Usuário pode fazer login com nova senha

---

## RF-004: Ver/Editar Perfil

**Descrição:** Usuário autenticado pode visualizar e editar suas informações de perfil.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está autenticado

**Passos:**
1. Clica em ícone de perfil
2. Abre página de configurações
3. Edita informações

**Critérios de Aceitação:**
- ✅ Pode editar nome, sobrenome
- ✅ Pode fazer upload de foto de perfil
- ✅ Foto deve ser menor que 5MB
- ✅ Foto deve ser JPG, PNG ou WEBP
- ✅ Crop de imagem antes de salvar
- ✅ Pode alterar email (com confirmação de novo email)
- ✅ Pode trocar senha (pedindo senha atual)
- ✅ Pode deletar conta (com confirmação e aviso de consequências)
- ✅ Dados salvos com feedback visual ("Salvo!")
- ✅ Validação em tempo real de campos

**Pós-condições:** Perfil do usuário atualizado no banco de dados

---

## RF-005: Criar Nova Lista

**Descrição:** Usuário autenticado pode criar uma nova lista personalizada.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está autenticado

**Passos:**
1. Clica em "Nova Lista" ou "+"
2. Preenche nome da lista
3. Preenche descrição (opcional)
4. Escolhe tipo: Privada ou Compartilhada
5. Clica "Criar"

**Critérios de Aceitação:**
- ✅ Nome é obrigatório
- ✅ Nome deve ter entre 1-50 caracteres
- ✅ Descrição é opcional, máximo 500 caracteres
- ✅ Tipo padrão é "Privada"
- ✅ Lista é criada vazia (0 itens)
- ✅ Usuário vê lista instantaneamente no dashboard
- ✅ Data de criação é registrada
- ✅ Usuário é automaticamente "Owner" da lista
- ✅ Opção para escolher cor/ícone da lista (opcional)

**Pós-condições:** Nova lista é criada e aparece no dashboard do usuário

---

## RF-006: Editar Lista

**Descrição:** Usuário pode editar informações de uma lista que possui.

**Atores:** Usuário autenticado (dono da lista)

**Pré-condições:** Usuário está autenticado e é dono da lista

**Passos:**
1. Abre lista
2. Clica em ⋮ (menu) ou "Editar"
3. Altera nome, descrição ou tipo
4. Clica "Salvar"

**Critérios de Aceitação:**
- ✅ Pode editar nome
- ✅ Pode editar descrição
- ✅ Pode mudar tipo de Privada → Compartilhada
- ✅ Pode mudar tipo de Compartilhada → Privada
- ✅ Mudança para Compartilhada pede email do parceiro ou gera link
- ✅ Confirmação antes de mudar para Privada (aviso: removará acesso de outros)
- ✅ Validação em tempo real

**Pós-condições:** Informações da lista atualizadas no banco de dados

---

## RF-007: Deletar Lista

**Descrição:** Usuário pode deletar uma lista que possui.

**Atores:** Usuário autenticado (dono da lista)

**Pré-condições:** Usuário está autenticado e é dono da lista

**Passos:**
1. Abre lista
2. Clica em ⋮ (menu)
3. Seleciona "Deletar"
4. Confirma deleção em modal

**Critérios de Aceitação:**
- ✅ Não pode deletar listas padrão (Assistindo, Quer Assistir, Já Assistiu)
- ✅ Modal de confirmação explicando consequências
- ✅ Se lista é compartilhada, aviso que outros perderão acesso
- ✅ Após confirmar, lista é deletada (soft delete: marca como deleted_at)
- ✅ Usuário redirecionado para dashboard
- ✅ Mensagem de sucesso: "Lista deletada"

**Pós-condições:** Lista marcada como deletada, não aparece mais para usuário

---

## RF-008: Arquivar/Desarquivar Lista

**Descrição:** Usuário pode arquivar listas que não quer ver, sem deletar.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está autenticado

**Passos:**
1. Abre lista
2. Clica em ⋮ (menu)
3. Seleciona "Arquivar"

**Critérios de Aceitação:**
- ✅ Lista desaparece da view principal
- ✅ Opção "Ver Arquivadas" mostra listas arquivadas
- ✅ Pode desarquivar da mesma forma
- ✅ Dados não são perdidos
- ✅ Se lista é compartilhada, só quem arquivou vê como arquivada

**Pós-condições:** Lista marcada como archived_at

---

## RF-009: Buscar Filme/Série na API

**Descrição:** Usuário pode buscar filmes e séries via API de terceiros (OMDb).

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está em uma lista ou página de busca

**Passos:**
1. Clica em campo de busca ou "Adicionar Filme/Série"
2. Digita nome (ex: "Breaking Bad")
3. Aguarda resultados

**Critérios de Aceitação:**
- ✅ Busca em tempo real (não precisa clicar buscar)
- ✅ Debounce: espera 300ms antes de fazer requisição
- ✅ Mostra 10-20 primeiros resultados
- ✅ Cada resultado mostra: poster, título, ano, tipo
- ✅ Clique no resultado abre detalhes
- ✅ Se nenhum resultado, mensagem clara
- ✅ Máximo 1000 requisições/dia (limite OMDb free)
- ✅ Histórico de buscas mantido (últimas 15)
- ✅ Pode limpar histórico manualmente

**Pós-condições:** Resultados exibidos ao usuário

---

## RF-010: Ver Detalhes da Mídia

**Descrição:** Usuário pode ver detalhes completos de um filme/série.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário fez uma busca e clicou em um resultado

**Passos:**
1. Clica em um resultado de busca
2. Abre modal/página com detalhes

**Critérios de Aceitação:**
- ✅ Poster de alta qualidade (se disponível)
- ✅ Título completo
- ✅ Ano de lançamento
- ✅ Tipo (Filme, Série, Episódio)
- ✅ Sinopse completa
- ✅ Rating IMDb
- ✅ Gêneros (ex: Drama, Thriller)
- ✅ Duração (filme) ou nº temporadas/episódios (série)
- ✅ Elenco principal (3-5 atores)
- ✅ Link para IMDb (ícone externo)
- ✅ Botão "Adicionar à Lista"
- ✅ Se já está em uma lista, indicar qual(is)

**Pós-condições:** Informações exibidas, usuário pode adicionar à lista

---

## RF-011: Adicionar Filme/Série à Lista

**Descrição:** Usuário pode adicionar um filme/série a uma de suas listas.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário selecionou um filme/série e está em uma lista

**Passos:**
1. Clica "Adicionar à Lista"
2. Seleciona lista (dropdown com suas listas)
3. Se for série, escolhe temporada inicial (padrão T1E1)
4. Clica "Confirmar"

**Critérios de Aceitação:**
- ✅ Pode adicionar a múltiplas listas
- ✅ Para séries, campo "Começar em T{x}E{y}"
- ✅ Padrão é T1E1 para séries
- ✅ Para filmes, não pede episódio
- ✅ Status padrão é "Não Assistiu"
- ✅ Rating padrão é vazio (pode adicionar depois)
- ✅ Se já está na lista, mensagem: "Já existe em [lista]"
- ✅ Opção para adicionar mesmo assim (duplicar)
- ✅ Após adicionar, confirmação visual: "✓ Adicionado!"
- ✅ Botão para desfazer ação (undo)

**Pós-condições:** Filme/série adicionado à lista do usuário

---

## RF-012: Marcar Status do Item

**Descrição:** Usuário marca o status de assistência de um item na lista.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem item na lista

**Passos:**
1. Abre item na lista
2. Clica em status atual
3. Seleciona novo status

**Critérios de Aceitação:**
- ✅ Opções: Não Assistiu, Assistindo, Assistiu, Pausado, Abandonado
- ✅ Status pode ser selecionado como dropdown ou pills
- ✅ Ícone visual para cada status (🔴🟡🟢⏸️❌)
- ✅ Pode mudar status a qualquer momento
- ✅ Mudança é salva instantaneamente
- ✅ Se marcou "Assistiu", data é registrada
- ✅ Pode editar a data que "assistiu"
- ✅ Notificação visual: "Status atualizado"

**Pós-condições:** Status do item atualizado no banco de dados

---

## RF-013: Marcar Episódio Específico (Séries)

**Descrição:** Para séries, usuário marca episódios específicos como assistidos.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem série na lista

**Passos:**
1. Abre série na lista
2. Vê estrutura: T1E1, T1E2, T1E3, etc
3. Clica checkbox em T1E5 para marcar como assistido
4. Barra de progresso atualiza

**Critérios de Aceitação:**
- ✅ Mostrar todos episódios da série (ou paginar)
- ✅ Checkbox para cada episódio
- ✅ Número: T{x}E{y}
- ✅ Título do episódio (se disponível)
- ✅ Barra de progresso: "5/10 assistidos"
- ✅ Pode marcar múltiplos episódios de uma vez (shift+click)
- ✅ Marcar T1E5 automaticamente marca T1E1-T1E4 também
- ✅ Desmarcar T1E3 automaticamente desmarca T1E4+
- ✅ Pode editar data que assistiu cada episódio
- ✅ Mudanças são salvas automaticamente (auto-save)
- ✅ Status geral atualiza com base nos episódios marcados

**Pós-condições:** Episódios marcados como assistidos, progresso atualizado

---

## RF-014: Adicionar Rating Pessoal

**Descrição:** Usuário pode dar uma nota de 1-10 para um filme/série.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem item na lista

**Passos:**
1. Abre item na lista
2. Clica em campo de rating
3. Seleciona nota (1-10) ou usa slider
4. Nota é salva

**Critérios de Aceitação:**
- ✅ Rating de 1-10 (ou sistema de estrelas ⭐⭐⭐...)
- ✅ Pode ser fracionado (ex: 8.5)
- ✅ Mostra rating IMDb para comparação
- ✅ Pode mudar rating a qualquer momento
- ✅ Rating pessoal é apenas para quem adicionou (privado)
- ✅ Em listas compartilhadas, mostrar ratings separados de cada pessoa
- ✅ Padrão é vazio (sem rating)
- ✅ Visual: "Sua nota: 9 / IMDb: 9.0"

**Pós-condições:** Rating pessoal do usuário é salvo

---

## RF-015: Adicionar Notas/Comentários Pessoais

**Descrição:** Usuário pode adicionar notas textuais sobre um item.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem item na lista

**Passos:**
1. Abre item na lista
2. Clica em campo "Notas"
3. Escreve observação
4. Salva

**Critérios de Aceitação:**
- ✅ Campo de texto livre (máximo 1000 caracteres)
- ✅ Exemplo: "Adorei os efeitos especiais", "Muito longo, mas vale a pena"
- ✅ Notas são salvas automaticamente (auto-save)
- ✅ Mostrar contador de caracteres
- ✅ Markdown básico suportado (bold, italic, links)
- ✅ Notas pessoais não aparecem em listas compartilhadas (só o dono vê)
- ✅ Data de criação/edição da nota

**Pós-condições:** Nota salva no banco de dados

---

## RF-016: Criar Tags/Tópicos Customizados

**Descrição:** Usuário pode criar tags personalizadas para organizar itens em uma lista.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está em uma lista

**Passos:**
1. Clica "Novo Tag" ou em ícone de tag
2. Insere nome do tag
3. Escolhe cor (opcional)
4. Clica "Criar"

**Critérios de Aceitação:**
- ✅ Nome de tag entre 1-20 caracteres
- ✅ Pode escolher cor em paleta predefinida
- ✅ Cor é opcional (padrão: cinza)
- ✅ Tags são específicos por lista (não globais)
- ✅ Pode ter múltiplos tags por item
- ✅ Pode editar nome/cor do tag
- ✅ Pode deletar tag (pergunta se remove dos itens)
- ✅ Buscar/filtrar por tag
- ✅ Indicador visual: pill com cor

**Pós-condições:** Tag criado e disponível para uso naquela lista

---

## RF-017: Atribuir Tags a Itens

**Descrição:** Usuário pode atribuir tags criados a itens na lista.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens e tags criados em uma lista

**Passos:**
1. Abre item na lista
2. Clica em campo de tags
3. Seleciona tags do dropdown
4. Salva

**Critérios de Aceitação:**
- ✅ Dropdown/modal com tags disponíveis
- ✅ Pode selecionar múltiplos tags
- ✅ Tags aparecem como pills coloridas no item
- ✅ Pode remover tag clicando X no pill
- ✅ Busca/autocomplete no dropdown de tags
- ✅ Criar novo tag na hora (se não existir)
- ✅ Salva automaticamente

**Pós-condições:** Tags atribuídos ao item

---

## RF-018: Filtrar Itens por Tags

**Descrição:** Usuário pode filtrar itens de uma lista por tags específicos.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens com tags em uma lista

**Passos:**
1. Abre lista
2. Clica em filtro ou em um tag
3. Vê apenas itens com aquele tag

**Critérios de Aceitação:**
- ✅ Clique em tag filtra a lista
- ✅ Pode filtrar por múltiplos tags (AND logic)
- ✅ Indicador visual: "Filtrado por: #favoritos #ação"
- ✅ Botão "Limpar Filtros" reseta
- ✅ Contador: "3 filmes com este tag"
- ✅ Funciona com agrupamento simultâneo

**Pós-condições:** Lista exibe apenas itens que correspondem ao filtro

---

## RF-019: Agrupar Itens por Critério

**Descrição:** Usuário pode agrupar itens da lista por diferentes critérios.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens em uma lista

**Passos:**
1. Abre lista
2. Clica em "Agrupar por"
3. Seleciona critério (ex: Status, Rating, Gênero)
4. Lista se reorganiza em grupos

**Critérios de Aceitação:**
- ✅ Opções de agrupamento:
  - Status (Não Assistiu, Assistindo, Assistiu, Pausado, Abandonado)
  - Rating (1-3⭐, 4-6⭐, 7-10⭐)
  - Tipo (Filmes, Séries)
  - Gênero (Drama, Ação, etc)
  - Tag
  - Data Adicionado (Hoje, Esta Semana, Este Mês)
  - Sem agrupamento (padrão)
- ✅ Cada grupo colapsável (expandir/colapsar)
- ✅ Contador de itens por grupo
- ✅ Agrupamento persiste na sessão

**Pós-condições:** Itens exibidos agrupados

---

## RF-020: Ordenar Itens

**Descrição:** Usuário pode ordenar itens da lista por diferentes critérios.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens em uma lista

**Passos:**
1. Abre lista
2. Clica em "Ordenar por"
3. Seleciona critério (ex: Alfabeto, Rating)
4. Seleciona direção (crescente/decrescente)

**Critérios de Aceitação:**
- ✅ Opções de ordenação:
  - Alfabeto (A-Z, Z-A)
  - Seu Rating (maior → menor, menor → maior)
  - Rating IMDb (maior → menor)
  - Data Adicionado (recente → antigo, antigo → recente)
  - Data Assistido (recente → antigo)
  - Duração (maior → menor)
  - Aleatório
- ✅ Direção escolhida por critério
- ✅ Indicador visual: ↑ ou ↓
- ✅ Ordenação persiste na sessão

**Pós-condições:** Itens exibidos em nova ordem

---

## RF-021: Pesquisar Dentro da Lista

**Descrição:** Usuário pode buscar itens dentro de uma lista específica.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens em uma lista

**Passos:**
1. Abre lista
2. Digita no campo "Buscar nesta lista"
3. Resultados filtram em tempo real

**Critérios de Aceitação:**
- ✅ Busca por título (match parcial)
- ✅ Busca por nota/comentário pessoal
- ✅ Busca por gênero
- ✅ Busca por ator (se disponível)
- ✅ Case-insensitive
- ✅ Debounce: espera 300ms antes de filtrar
- ✅ Limpar busca = mostra todos
- ✅ Mensagem se nenhum resultado

**Pós-condições:** Lista filtrada por termo de busca

---

## RF-022: Compartilhar Lista com Parceiro

**Descrição:** Usuário convida um parceiro para acessar uma lista compartilhada.

**Atores:** Usuário autenticado (dono da lista)

**Pré-condições:** Usuário tem lista criada

**Passos:**
1. Abre lista
2. Clica em ⋮ (menu) → "Compartilhar"
3. Escolhe convidar via email ou gerar link
4. Se email: insere email do parceiro, clica "Enviar Convite"
5. Se link: copia link compartilhado

**Critérios de Aceitação:**
- ✅ Pode convidar por email
- ✅ Pode gerar link único e copiável
- ✅ Link é único por lista
- ✅ Link expira em 30 dias (configurável)
- ✅ Email de convite enviado com link
- ✅ Convite explica que será adicionado à lista
- ✅ Parceiro que receber convite pode aceitar ou rejeitar
- ✅ Aceitar = lista aparece no seu dashboard
- ✅ Rejeitar = convite é descartado
- ✅ Dono pode ver quem aceitou/rejeitou
- ✅ Histórico de convites

**Pós-condições:** Convite enviado, parceiro pode aceitar

---

## RF-023: Aceitar/Rejeitar Convite de Lista Compartilhada

**Descrição:** Usuário pode aceitar ou rejeitar convite para acessar uma lista compartilhada.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário recebeu convite por email ou clicou link de compartilhamento

**Passos:**
1. Clica em link no email ou link direto
2. Se não autenticado, faz login/registro
3. Vê modal: "X convida você para colaborar em 'Lista Y'"
4. Clica "Aceitar" ou "Rejeitar"

**Critérios de Aceitação:**
- ✅ Se autenticado, vai direto para aceitar/rejeitar
- ✅ Se não autenticado, redireciona para login/registro
- ✅ Modal mostra: nome de quem convida, nome da lista, descrição
- ✅ Botão "Aceitar" → lista adicionada ao dashboard
- ✅ Botão "Rejeitar" → convite descartado
- ✅ Mensagem de confirmação após ação
- ✅ Se já é membro, mensagem: "Você já é membro desta lista"

**Pós-condições:** Usuário adicionado à lista ou convite rejeitado

---

## RF-024: Definir Permissões em Listas Compartilhadas

**Descrição:** Dono da lista define permissões de acesso para membros.

**Atores:** Usuário autenticado (dono da lista)

**Pré-condições:** Usuário tem lista compartilhada com outros

**Passos:**
1. Abre lista compartilhada
2. Clica em ⋮ (menu) → "Membros" ou "Configurações"
3. Vê lista de membros
4. Clica em membro → edita permissão

**Critérios de Aceitação:**
- ✅ Dois níveis de permissão:
  - **Editor**: pode adicionar, editar, remover itens, comentar, votar
  - **Visualizador**: apenas ler (read-only)
- ✅ Dono sempre tem permissão de Editor + pode mudar/remover membros
- ✅ Padrão para novos membros é Editor
- ✅ Pode remover membro (com confirmação)
- ✅ Membro removido perde acesso instantaneamente
- ✅ Indicador visual de role: "👁️ Visualizador" ou "✏️ Editor"

**Pós-condições:** Permissões atualizadas no banco de dados

---

## RF-025: Votar em Itens de Lista Compartilhada

**Descrição:** Em listas compartilhadas, membros votam se querem ver cada item.

**Atores:** Usuário autenticado com permissão de Editor

**Pré-condições:** Usuário é membro de lista compartilhada

**Passos:**
1. Abre lista compartilhada
2. Vê item com opções de voto
3. Clica em 👍 (quer ver), 👎 (não quer), ou 😐 (indiferente)

**Critérios de Aceitação:**
- ✅ Três opções: 👍 👎 😐
- ✅ Pode mudar voto a qualquer momento
- ✅ Seu voto é salvo
- ✅ Resultado do voto mostrado: "👍 +1 vs 👎 -0"
- ✅ Pode ver quem votou (hover: "Maria: 👍, João: 👎")
- ✅ Itens com mais 👍 podem aparecer no topo (opção)
- ✅ Visualizadores não podem votar
- ✅ Resultado em tempo real se parceiro votou

**Pós-condições:** Voto registrado e resultado atualizado

---

## RF-026: Comentar em Itens de Lista Compartilhada

**Descrição:** Membros da lista podem deixar comentários em itens.

**Atores:** Usuário autenticado com permissão de Editor

**Pré-condições:** Usuário é membro de lista compartilhada

**Passos:**
1. Abre item na lista compartilhada
2. Clica em "Comentários" ou vê seção de comentários
3. Digita comentário
4. Clica "Enviar"

**Critérios de Aceitação:**
- ✅ Campo de texto para comentário
- ✅ Máximo 500 caracteres
- ✅ Mostra quem comentou, data/hora
- ✅ Markdown básico suportado
- ✅ Pode editar próprio comentário
- ✅ Pode deletar próprio comentário
- ✅ Dono da lista pode deletar qualquer comentário
- ✅ Notificação em tempo real: "Maria comentou em 'The Office'"
- ✅ Thread de respostas (opcional, fase 2)

**Pós-condições:** Comentário adicionado e parceiro notificado em tempo real

---

## RF-027: Sincronização em Tempo Real

**Descrição:** Quando um membro de lista compartilhada faz mudanças, outro vê instantaneamente.

**Atores:** Múltiplos usuários autenticados acessando mesma lista

**Pré-condições:** Ambos os usuários estão acessando a mesma lista compartilhada

**Passos:**
1. Usuário A adiciona "The Office" à lista
2. Usuário B, que tem lista aberta, vê novo item aparecer
3. Sem precisar refazer a página

**Critérios de Aceitação:**
- ✅ WebSocket conecta ambos os usuários
- ✅ Adição de item: <1s para aparecer no outro
- ✅ Edição de status/rating: <1s
- ✅ Comentário novo: <1s
- ✅ Voto novo: <1s
- ✅ Indicador visual: "Maria está vendo esta lista"
- ✅ Desconexão amigável se perder internet
- ✅ Reconectar automaticamente
- ✅ Se offline, sincronizar quando voltar online

**Pós-condições:** Dados sincronizados em tempo real entre usuários

---

## RF-028: Resumo Inteligente de Episódio com IA

**Descrição:** Para séries, após marcar episódio como assistido, IA gera resumo inteligente com conexões narrativas.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário marcou episódio como assistido

**Passos:**
1. Usuário marca "Assistiu T2E5"
2. App oferece: "Ver resumo inteligente?"
3. Usuário clica "Gerar Resumo"
4. IA analisa e gera resumo

**Critérios de Aceitação:**
- ✅ Resumo gerado em <10s (mostra "gerando..." se mais lento)
- ✅ Resumo inclui:
  1. **Sinopse Expandida** (3-5 parágrafos)
  2. **Plot Points Principais** (3-5 bullet points)
  3. **Personagens Destaque** (quem aparece, mudanças no arco)
  4. **Conexões com Episódio Anterior** (como T2E5 conecta com T2E4)
  5. **Indicadores Importantes** (⚠️ spoiler, 💀 morte, 💔 emocional, 🔑 crucial)
- ✅ Resumo é salvo em cache (reutilizar depois)
- ✅ Quando abre série novamente, mostra resumo do último episódio
- ✅ Pode regenerar resumo (refrescar)
- ✅ Pode copiar resumo (clipboard)
- ✅ Pode ver histórico de resumos (últimos 10)

**Pós-condições:** Resumo IA gerado, salvo e exibido ao usuário

---

## RF-029: Conexão Narrativa entre Episódios

**Descrição:** Resumo IA mostra explicitamente como episódio atual conecta com anterior.

**Atores:** Usuário autenticado

**Pré-condições:** Resumo IA foi gerado para episódio

**Passos:**
1. Abre resumo de T2E5
2. Vê seção "Conexões com Episódio Anterior"
3. Lê como T2E5 relaciona com T2E4

**Critérios de Aceitação:**
- ✅ Seção "Conexões com Episódio Anterior" mostra:
  - O que foi resolvido de T2E4 em T2E5
  - Qual cliffhanger foi respondido
  - Como T2E5 prepara T2E6
  - Progressão geral da trama entre episódios
- ✅ Exemplo de output:
  ```
  Episódio 5 (S2E5) "O Retorno":
  - Retoma a fuga de Victor (começou em S2E3)
  - Responde pergunta de S2E4: Quem é o misterioso chamador? → É o irmão de Victor!
  - Prepara o caminho para o confronto final (S2E8)
  ```
- ✅ Linguagem acessível e clara
- ✅ Não contem spoilers do próximo episódio (apenas prepara)
- ✅ Funciona mesmo se usuário pulou episódios
- ✅ Funciona mesmo se série tem múltiplas tramas paralelas

**Pós-condições:** Usuário entende contexto narrativo e onde parou

---

## RF-030: Mostrar Resumo ao Voltar à Série (Recall)

**Descrição:** Quando usuário volta a uma série após pausa, app oferece resumo do último episódio.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário parou de assistir série há dias/semanas

**Passos:**
1. Abre série que deixou no meio (T2E5, 2 semanas atrás)
2. App mostra notificação: "Você parou em T2E5. Quer um resumo para relembrar?"
3. Clica "Sim, me ajude!"
4. Vê resumo inteligente do T2E5

**Critérios de Aceitação:**
- ✅ Detecta série que foi deixada incompleta
- ✅ Notificação discreta (não invasiva)
- ✅ Oferece resumo se já foi gerado
- ✅ Se resumo não foi gerado, oferece gerar agora
- ✅ Usuário pode descartar oferta ("Já sei onde parei")
- ✅ Resumo aparece acima da série/episódio para fácil acesso
- ✅ Destaca T2E5 como "Último assistido"

**Pós-condições:** Usuário tem contexto claro para continuar série

---

## RF-031: Gerar Resumo de Temporada Inteira

**Descrição:** IA pode gerar resumo de toda uma temporada (todos episódios vistos).

**Atores:** Usuário autenticado

**Pré-condições:** Usuário completou uma temporada

**Passos:**
1. Abre série
2. Clica "Ver Resumo da Temporada" ou similar
3. IA gera resumo consolidado

**Critérios de Aceitação:**
- ✅ Resumo da temporada inteira (ex: T2)
- ✅ Incluir: eventos principais, desenvolvimento de personagens, arcos completados
- ✅ Mostrar progressão do começo ao fim da temporada
- ✅ Preparar para próxima temporada (dicas do que esperar)
- ✅ Gerado a partir dos resumos dos episódios (reutilizar dados)

**Pós-condições:** Resumo da temporada disponível para consulta

---

## RF-032: Importar Listas de Plataformas Externas

**Descrição:** Usuário pode importar listas de filmes/séries de plataformas externas (Letterboxd, Trakt, etc).

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem conta em plataforma externa

**Passos:**
1. Abre dashboard
2. Clica "Importar Listas"
3. Escolhe plataforma (Letterboxd, Trakt, CSV, etc)
4. Autoriza ou faz upload de arquivo
5. Seleciona qual lista importar
6. Clica "Importar"

**Critérios de Aceitação:**
- ✅ Suportar: Letterboxd, IMDB, Trakt, arquivo CSV/JSON
- ✅ Mapear automaticamente filmes/séries (via IMDb ID)
- ✅ Se não conseguir mapear, mostrar opções manuais
- ✅ Importar para lista nova ou existente
- ✅ Mostrar progresso: "3/47 itens importados"
- ✅ Se alguns não conseguir mapear, mostrar aviso
- ✅ Resumo final: "Importados 45 itens, 2 não encontrados"

**Pós-condições:** Itens importados adicionados à lista do usuário

---

## RF-033: Exportar Listas

**Descrição:** Usuário pode exportar suas listas em diferentes formatos.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem listas criadas

**Passos:**
1. Abre lista
2. Clica em ⋮ (menu) → "Exportar"
3. Escolhe formato (CSV, JSON, PDF)
4. Clica "Baixar"

**Critérios de Aceitação:**
- ✅ Formatos: CSV, JSON, PDF
- ✅ CSV: colunas = título, ano, tipo, status, rating, data adicionado
- ✅ JSON: estrutura completa com metadados
- ✅ PDF: formatado bonito com poster, informações, etc
- ✅ Arquivo baixado: "lista-nome-data.csv"
- ✅ Pode exportar múltiplas listas de uma vez

**Pós-condições:** Arquivo exportado disponível para download

---

## RF-034: Dashboard com Estatísticas

**Descrição:** Usuário vê estatísticas sobre suas listas e hábitos.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário tem itens em listas

**Passos:**
1. Clica em "Dashboard" ou "Minhas Estatísticas"
2. Vê cards com dados

**Critérios de Aceitação:**
- ✅ Total de filmes/séries adicionadas
- ✅ Total assistido (contar horas estimadas baseado em duração)
- ✅ Gêneros mais comuns (gráfico pie)
- ✅ Rating médio (sua nota vs IMDb)
- ✅ Status breakdown (Não Assistiu, Assistindo, Assistiu, etc)
- ✅ Série com mais episódios
- ✅ Filme mais longo
- ✅ Para casal: comparação "Maria assiste mais drama que João"
- ✅ Atividade recente (últimos 7 dias)

**Pós-condições:** Estatísticas exibidas em dashboard

---

## RF-035: Notificações

**Descrição:** Usuário recebe notificações de atividades em listas compartilhadas.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário é membro de lista compartilhada

**Passos:**
1. Parceiro executa ação (adiciona item, vota, comenta)
2. Usuário recebe notificação

**Critérios de Aceitação:**
- ✅ Notificações em-app (ícone com badge)
- ✅ Notificações por email (configurável)
- ✅ Notificações por push (se app mobile, fase 2)
- ✅ Tipos de notificação:
  - Membro adicionou item
  - Membro votou em item
  - Membro comentou em item
  - Membro foi adicionado à lista
- ✅ Notificação tem link direto para item/lista
- ✅ Pode desabilitar notificações por lista
- ✅ Centro de notificações com histórico

**Pós-condições:** Usuário notificado de atividades

---

## RF-036: Dark Mode

**Descrição:** Aplicativo suporta tema escuro.

**Atores:** Usuário autenticado

**Pré-condições:** Usuário está usando aplicativo

**Passos:**
1. Clica em menu de configurações
2. Escolhe "Dark Mode" ou "Automático"
3. Interface muda de tema

**Critérios de Aceitação:**
- ✅ Opções: Light, Dark, Automático (segue sistema)
- ✅ Preferência salva no perfil do usuário
- ✅ Automático detecta preferência do SO
- ✅ Todos os elementos têm cores no dark mode
- ✅ Não deve ser desconfortável em modo escuro
- ✅ Transição suave entre temas

**Pós-condições:** Tema do usuário atualizado

