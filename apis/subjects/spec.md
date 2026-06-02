# subjects-db Specification

## Purpose

Define a estrutura da tabela `subjects` no banco de dados, que é essencial para permitir que os usuários do EduTrack AI gerenciem suas disciplinas acadêmicas. Cada disciplina pertence a um usuário específico.

## ADDED Requirements

### Requirement: Store academic subjects
O sistema SHALL armazenar informações sobre as disciplinas acadêmicas de cada usuário.

#### Scenario: User creates a subject
- **WHEN** um usuário cria uma nova disciplina com nome e nome do professor.
- **THEN** o sistema SHALL salvar a disciplina associando-a ao `id` do usuário autenticado (`user_id`).