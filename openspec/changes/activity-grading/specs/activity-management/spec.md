# activity-management Specification

## Purpose

Define a estrutura de dados e APIs para gerenciamento de atividades acadêmicas dentro de disciplinas no EduTrack AI, permitindo que professores criem, visualizem, atualizem e deletem atividades com controle de acesso apropriado.

## ADDED Requirements

### Requirement: User can create academic activities
Instrutores e administradores de disciplina SHALL ser capazes de criar novas atividades acadêmicas dentro de uma disciplina com informações essenciais (nome, descrição, data de entrega).

#### Scenario: Instructor creates an activity successfully
- **WHEN** um instrutor autenticado de uma disciplina submete uma requisição válida de criação de atividade com nome, description e subject_id
- **THEN** o sistema cria o registro de atividade com id, timestamps, status "draft", e retorna os dados criados

#### Scenario: Activity creation requires instructor role
- **WHEN** um aluno tenta criar uma atividade
- **THEN** o sistema retorna erro de acesso negado (access denied)

#### Scenario: User cannot create activity in unowned subject
- **WHEN** um usuário tenta criar atividade em disciplina onde não tem role instructor/admin
- **THEN** o sistema retorna erro de acesso negado

### Requirement: User can view activities in a subject
Todos os usuários matriculados em uma disciplina SHALL conseguir visualizar lista de atividades dessa disciplina com informações básicas.

#### Scenario: Instructor views all activities in subject
- **WHEN** um instrutor autentico requisita a lista de atividades para uma disciplina
- **THEN** o sistema retorna todas as atividades da disciplina com status, data de criação, e criador

#### Scenario: Student views published activities
- **WHEN** um aluno requisita a lista de atividades de uma disciplina
- **THEN** o sistema retorna apenas atividades com status "published" ou "closed"

#### Scenario: User cannot view activities from unjoined subject
- **WHEN** um usuário requisita atividades de disciplina onde não está matriculado
- **THEN** o sistema retorna erro de acesso negado

### Requirement: User can retrieve activity details
Usuários matriculados em disciplina SHALL conseguir visualizar detalhes completos de uma atividade específica dentro do escopo de acesso.

#### Scenario: Instructor views activity detail with full metadata
- **WHEN** um instrutor requisita detalhes de atividade específica que criou
- **THEN** o sistema retorna dados completos incluindo status, descrição, data de entrega, id do criador

#### Scenario: Student views activity detail if published
- **WHEN** um aluno requisita atividade "published" ou "closed"
- **THEN** o sistema retorna dados públicos da atividade

#### Scenario: Student cannot view draft activities
- **WHEN** um aluno tenta visualizar atividade com status "draft"
- **THEN** o sistema retorna erro não encontrado (404)

### Requirement: Instructor can update activity metadata
Instrutores e administradores de disciplina SHALL conseguir atualizar detalhes de atividades que criaram.

#### Scenario: Instructor updates activity name and description
- **WHEN** instrutor submete requisição PATCH com novos valores para name, description, ou due_date
- **THEN** sistema atualiza atividade e registra mudança via event_log com action "activity.updated"

#### Scenario: Activity update only by instructor/admin
- **WHEN** aluno ou usuário sem role instructor tenta fazer PATCH em atividade
- **THEN** sistema retorna erro de acesso negado

#### Scenario: Cannot update activity from different account
- **WHEN** usuário tenta atualizar atividade de disciplina em outra conta
- **THEN** sistema retorna erro de validação (validação de account_id falha)

### Requirement: Instructor can delete or archive activities
Instrutores e administradores SHALL conseguir deletar/arquivar atividades para remover do sistema.

#### Scenario: Instructor archives activity
- **WHEN** instrutor submete DELETE para atividade existente
- **THEN** sistema marca atividade como deletada ou remove do registro, registra evento "activity.deleted"

#### Scenario: Cannot delete activity from other user
- **WHEN** instrutor A tenta deletar atividade criada por instrutor B
- **THEN** sistema retorna erro de acesso negado (se restrição existir) ou permite (se ambos são instrutores da mesma disciplina)

### Requirement: Activity operations are logged
Todas operações de atividade (create, update, delete) SHALL ser registradas via sistema de event logging para auditoria.

#### Scenario: Activity creation is logged
- **WHEN** atividade é criada
- **THEN** record em event_log é criado com action "activity.created", activity_id, subject_id, user_id criador, e timestamp

#### Scenario: Activity update is logged
- **WHEN** atividade é atualizada
- **THEN** record em event_log criado com action "activity.updated", mudanças relevantes, user_id responsável

#### Scenario: Activity deletion is logged
- **WHEN** atividade é deletada
- **THEN** record em event_log criado com action "activity.deleted", activity_id, subject_id, user_id responsável

### Requirement: Activity management respects account boundaries
Usuários podem gerenciar apenas atividades dentro de suas próprias contas.

#### Scenario: User cannot access activities from other accounts
- **WHEN** usuário requisita atividades de disciplina em outra conta
- **THEN** sistema filtra resultados para account_id do usuário, retornando acesso negado se necessário

#### Scenario: Multi-tenancy isolation enforced
- **WHEN** consulta é feita via APIs de atividades
- **THEN** todas queries filtram implicitamente por account_id do usuário autenticado
