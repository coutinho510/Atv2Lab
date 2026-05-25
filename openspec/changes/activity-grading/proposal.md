## Why

EduTrack AI necessita de um sistema robusto para gestão de atividades acadêmicas e avaliação de alunos. Professores precisam lançar notas para atividades específicas dentro de disciplinas, permitindo acompanhamento do desempenho estudantil. Este recurso é essencial para estabelecer um registro de grades, fornecer feedback estruturado com rubricas, e suportar futuras análises de desempenho e geração de relatórios acadêmicos.

## What Changes

- **Nova tabela `academic_activity`** para armazenar atividades acadêmicas dentro de disciplinas com metadados (nome, descrição, data de entrega, status)
- **Nova tabela `activity_grade`** para registrar notas de alunos com suporte a feedback textual e rubrica
- **Controle de acesso** permitindo que apenas professores/administradores da disciplina lancem e editem notas
- **Visualização filtrada** onde alunos veem apenas suas próprias notas
- **Audit trail** registrando todas as operações de atividade e avaliação
- **Estrutura extensível** pronta para suportar submissões de alunos, anexos e histórico de correções futuro

## Capabilities

### New Capabilities
- `activity-management`: Professores podem criar, visualizar, atualizar e deletar atividades dentro de disciplinas com controle de acesso baseado em roles e logging de auditoria
- `grade-management`: Instrutores podem lançar, visualizar, editar e fornecer feedback com rubricas para notas de alunos em atividades, com restrições de permissão e rastreamento de eventos

### Modified Capabilities
<!-- Nenhuma capacidade existente requer mudanças nesta fase -->

## Impact

- **Database**: Novas tabelas `academic_activity` (atividades por disciplina) e `activity_grade` (notas de alunos)
- **APIs**: Novos endpoints REST para gerenciamento de atividades (CRUD) e lançamento/visualização de notas com filtros de permissão
- **Access Control**: Permissões baseadas em `subject_role` (instructor/admin vs learner) do `subject_enrollment`
- **Event Logging**: Todas as operações registradas via `event_log` para auditoria (atividades criadas/atualizadas/deletadas, notas lançadas/editadas)
- **Dependencies**: Constrói sobre estrutura existente de autenticação, `subject` e `subject_enrollment`
