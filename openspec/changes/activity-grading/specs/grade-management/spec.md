# grade-management Specification

## Purpose

Define a estrutura de dados e APIs para lançamento, visualização e edição de notas de alunos em atividades acadêmicas, com suporte a feedback estruturado, rubricas e validações de permissão baseadas em roles.

## ADDED Requirements

### Requirement: Instructor can create grades for students
Instrutores e administradores de disciplina SHALL conseguir lançar notas para alunos em atividades específicas com escala numérica (0-100).

#### Scenario: Instructor submits grade for student
- **WHEN** instrutor submete POST com activity_id, student_id, grade (0-100), feedback opcional, e rubric JSON
- **THEN** sistema cria record em activity_grade, valida intervalo de grade, e retorna grade criada com timestamps

#### Scenario: Grade must be numeric 0-100
- **WHEN** instrutor submete grade fora do intervalo (ex: 150 ou -10)
- **THEN** sistema retorna erro de validação de entrada

#### Scenario: Student must be enrolled in subject
- **WHEN** instrutor tenta lançar nota para usuário que não está matriculado na disciplina
- **THEN** sistema retorna erro de validação (student não encontrado em subject_enrollment)

#### Scenario: Cannot create duplicate grade
- **WHEN** instrutor tenta submeter segunda grade para mesma combinação (activity_id, student_id)
- **THEN** sistema retorna erro de constraint único violado, ou retorna a grade existente (dependendo de política)

### Requirement: Only instructors/admins can grade
Apenas instrutores e administradores de disciplina SHALL conseguir criar e modificar notas.

#### Scenario: Student cannot submit grades
- **WHEN** aluno tenta fazer POST para criar grade
- **THEN** sistema retorna erro de acesso negado

#### Scenario: Permission check via subject role
- **WHEN** API verifica permissão de quem está lançando nota
- **THEN** sistema valida que user tem subject_role "instructor" ou "admin" na disciplina

### Requirement: Instructor can view grades with filtering
Instrutores SHALL conseguir visualizar notas de alunos com capacidade de filtrar por atividade.

#### Scenario: Instructor views all grades for activity
- **WHEN** instrutor requisita GET para todas grades de uma atividade
- **THEN** sistema retorna lista de grades com student_id, grade, feedback, rubric, graded_by, timestamps

#### Scenario: Grades include student information
- **WHEN** GET é feito para grades
- **THEN** resposta inclui dados associados do aluno (nome, email) via join ou addon

#### Scenario: Pagination support for large grade lists
- **WHEN** muitos alunos estão matriculados
- **THEN** endpoint suporta paginação com limit/offset ou cursor

### Requirement: Students can view only their own grades
Alunos SHALL conseguir visualizar apenas suas próprias notas, não de outros alunos.

#### Scenario: Student retrieves their grades
- **WHEN** aluno autentico requisita suas grades de uma atividade
- **THEN** sistema retorna apenas grades onde student_id === $auth.id, com grade, feedback, rubric, graded_by, timestamps

#### Scenario: Student cannot view peer grades
- **WHEN** aluno tenta fazer GET /activities/{id}/grades (sem filtro de student_id)
- **THEN** sistema retorna acesso negado OU filtra automaticamente para apenas próprias grades

### Requirement: Instructor can update grades and feedback
Instrutores e administradores SHALL conseguir editar notas e adicionar feedback/rubrica sem deletar records anteriores.

#### Scenario: Instructor updates grade value
- **WHEN** instrutor submete PATCH com novo valor de grade
- **THEN** sistema atualiza activity_grade record, registra updated_at, e retorna grade modificada

#### Scenario: Instructor updates feedback/rubric
- **WHEN** instrutor submete PATCH com novo feedback ou rubric
- **THEN** sistema atualiza feedback/rubric fields mantendo auditoria de quando mudou (updated_at, updated_by)

#### Scenario: Update triggers audit log entry
- **WHEN** grade é atualizada
- **THEN** event_log record criado com action "grade.updated", valores antigos vs novos (se possível), user_id responsável

### Requirement: Grades cannot be deleted
Notas lançadas devem ser preservadas para auditoria, podendo apenas ser atualizadas.

#### Scenario: DELETE endpoint not available
- **WHEN** usuário tenta fazer DELETE em grade
- **THEN** sistema retorna erro método não permitido (405) ou acesso negado

#### Scenario: Audit trail is immutable
- **WHEN** professor quer registrar "grade removida"
- **THEN** professor atualiza grade com comentário em feedback, não deleta o record

### Requirement: Grade operations are logged
Todas operações de nota (create, update) SHALL ser registradas para auditoria e rastreamento de mudanças.

#### Scenario: Grade creation is logged
- **WHEN** nota é lançada
- **THEN** record em event_log criado com action "grade.created", activity_id, student_id, grade, user_id lançador, timestamp

#### Scenario: Grade update is logged
- **WHEN** nota é editada
- **THEN** record em event_log criado com action "grade.updated", activity_id, student_id, valor_antigo, valor_novo, user_id responsável

### Requirement: Grade management respects account and subject boundaries
Usuários podem gerenciar apenas notas dentro de suas contas e disciplinas autorizadas.

#### Scenario: User cannot grade in unauthorized subject
- **WHEN** instrutor A tenta lançar nota em disciplina onde não é instrutor
- **THEN** sistema retorna erro de acesso negado

#### Scenario: Account isolation enforced
- **WHEN** query de grades é feita
- **THEN** todas queries filtram implicitamente por account_id, garantindo isolamento multi-tenancy

#### Scenario: Grade visibility respects subject enrollment
- **WHEN** aluno requisita grades de atividade
- **THEN** sistema verifica se aluno está em subject_enrollment, retornando acesso negado caso contrário
