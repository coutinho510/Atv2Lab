## ADDED Requirements

### Requirement: Usuário pode ver o histórico de tarefas por período
Usuários autenticados SHALL ser capazes de filtrar suas tarefas por um intervalo de datas e visualizar o resultado em uma tabela.

#### Scenario: Usuário filtra tarefas por período
- **WHEN** um usuário autenticado seleciona uma data inicial e uma data final na página de Relatórios
- **THEN** o sistema exibe uma tabela apenas com as tarefas cujo prazo (`data`) está dentro do intervalo selecionado, ordenadas por data

#### Scenario: Nenhuma tarefa no período
- **WHEN** não existe nenhuma tarefa com prazo dentro do intervalo selecionado
- **THEN** o sistema exibe uma mensagem informativa em vez de uma tabela vazia

### Requirement: Usuário pode ver o progresso por disciplina na tela de relatórios
Usuários autenticados SHALL ser capazes de visualizar, para cada disciplina, a proporção de tarefas concluídas em relação ao total.

#### Scenario: Disciplina com tarefas concluídas e pendentes
- **WHEN** uma disciplina tem tarefas com status "completa" e outras com status diferente
- **THEN** o sistema exibe uma barra de progresso com a contagem de concluídas sobre o total e o percentual correspondente

### Requirement: Usuário pode exportar disciplinas e tarefas em CSV
Usuários autenticados SHALL ser capazes de baixar seus dados de disciplinas e de tarefas em formato CSV.

#### Scenario: Exportar disciplinas
- **WHEN** um usuário autenticado clica em "Exportar Disciplinas (CSV)"
- **THEN** o sistema gera um arquivo CSV com nome, professor e carga horária de todas as disciplinas do usuário

#### Scenario: Exportar tarefas
- **WHEN** um usuário autenticado clica em "Exportar Tarefas (CSV)"
- **THEN** o sistema gera um arquivo CSV com disciplina, título, descrição, status e data de todas as tarefas do usuário

#### Scenario: Sem dados para exportar
- **WHEN** o usuário não possui nenhuma disciplina ou nenhuma tarefa cadastrada
- **THEN** o botão de exportação correspondente fica desabilitado
