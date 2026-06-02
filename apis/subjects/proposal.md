## Why

Para que o EduTrack AI seja funcional, os usuários precisam de uma maneira de organizar seu trabalho acadêmico. A criação de "disciplinas" (subjects) é o pilar fundamental dessa organização. Permitir que cada usuário cadastre e gerencie suas próprias disciplinas viabiliza o controle de acesso (um usuário não pode ver as disciplinas de outro) e serve como base para futuras funcionalidades, como o cadastro de tarefas, notas e horários associados a cada disciplina.

## What Changes

- **Nova tabela `subjects`**: Será criada uma nova tabela no banco de dados para armazenar as informações das disciplinas.
- **Estrutura de Dados**: A tabela incluirá campos essenciais como nome, nome do professor e uma referência obrigatória ao `user_id` do proprietário.
- **Propriedade de Dados**: Cada registro de disciplina estará estritamente vinculado a um usuário, garantindo que os dados sejam isolados e seguros.

## Impact

- **Database**: Adição da nova tabela `subjects`.
- **Access Control**: A presença do campo `user_id` em todas as disciplinas será a base para todas as futuras regras de permissão.
- **Future Features**: Desbloqueia o desenvolvimento de funcionalidades dependentes, como gerenciamento de tarefas (`academic_tasks`) e notas (`grades`).