## ADDED Requirements

### Requirement: Tarefas atrasadas são sinalizadas visualmente
O sistema SHALL exibir um indicador visual claro em qualquer tarefa cujo prazo (`data`) já tenha passado e que não esteja com status "completa".

#### Scenario: Tarefa pendente com prazo vencido
- **WHEN** uma tarefa tem `data` anterior à data atual e `status_tarefa` diferente de "completa"
- **THEN** o card da tarefa exibe o badge "🔴 Atrasada"

#### Scenario: Tarefa concluída com prazo vencido não é marcada como atrasada
- **WHEN** uma tarefa tem `data` anterior à data atual mas `status_tarefa` é "completa"
- **THEN** o badge de atraso NÃO é exibido

#### Scenario: Tarefa com prazo futuro ou no dia atual
- **WHEN** uma tarefa tem `data` igual ou posterior à data atual
- **THEN** o badge de atraso NÃO é exibido

#### Scenario: Consistência entre telas
- **WHEN** uma tarefa atrasada aparece na lista "Próximas Tarefas" do dashboard
- **THEN** o mesmo badge "🔴 Atrasada" é exibido, usando a mesma regra de cálculo do card de tarefas
