# Proposta: Funcionalidade de Notas de Atividades

## Why

Atualmente, o sistema não permite que professores lancem notas para atividades específicas dos alunos. Esta funcionalidade é essencial para o acompanhamento do progresso acadêmico e para a avaliação dos estudantes nas disciplinas em que estão matriculados.

## What Changes

Para habilitar o lançamento de notas, as seguintes mudanças são propostas:

1.  **Nova Tabela `academic_task`**: Uma nova tabela será criada para armazenar as atividades acadêmicas. Cada atividade pertencerá a uma `subject` (disciplina).
    *   Campos: `subject_id`, `title`, `description`, `due_date`.
2.  **Nova Tabela `activity_grade`**: Esta tabela armazenará as notas que os alunos recebem nas atividades.
    *   Campos: `academic_task_id`, `student_id`, `grader_id` (ID do professor que deu a nota), `grade`, `comments`.
3.  **Nova API `POST /activity_grades`**: Um novo endpoint será criado para permitir que um professor (com a permissão adequada) submeta uma nota para um aluno em uma atividade específica. A API validará se o usuário que está lançando a nota tem permissão de professor para a disciplina da atividade.

## Impact

-   **Backend**: Novas tabelas no banco de dados e um novo endpoint de API.
-   **Frontend**: Nenhuma mudança de frontend está no escopo desta proposta. O foco é apenas na criação da infraestrutura de backend.
-   **Segurança**: O novo endpoint de API incluirá validação para garantir que apenas usuários autorizados (professores da disciplina) possam lançar notas.
