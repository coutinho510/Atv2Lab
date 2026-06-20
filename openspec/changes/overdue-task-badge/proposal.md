## Why

O checklist do EduTrack AI exige que tarefas com prazo vencido sejam "identificadas e sinalizadas visualmente". Hoje o card de tarefa (`views/tarefas_page.py`) e a lista "Próximas Tarefas" do dashboard (`views/dashboard_page.py`) exibem a data da tarefa, mas nunca comparam essa data com o dia atual — uma tarefa atrasada aparece visualmente igual a qualquer outra. Sem esse sinal, o usuário precisa conferir manualmente cada prazo.

## What Changes

- **Função utilitária `is_task_overdue(task)`** em `utils/api_client.py` que retorna `True` quando `data < hoje` e `status_tarefa != "completa"`.
- **Badge visual "🔴 Atrasada"** no card de tarefa (`render_task_card`) quando a tarefa estiver atrasada.
- **Mesmo badge** na lista "Próximas Tarefas" do dashboard, para manter consistência entre as duas telas.

## Capabilities

### New Capabilities
- `task-management`: usuários veem um indicador visual claro quando uma tarefa está com o prazo vencido, tanto na lista de tarefas quanto no dashboard.

### Modified Capabilities
<!-- Nenhuma capacidade existente requer mudança de especificação nesta fase -->

## Impact

- **Frontend apenas**: `utils/api_client.py`, `views/tarefas_page.py`, `views/dashboard_page.py`.
- **Backend**: nenhuma mudança — o cálculo de atraso é derivado no frontend a partir do campo `data` já retornado pela API de tarefas.
- **Dependencies**: depende da lista de tarefas já exposta por `get_tasks` / `get_dashboard_tasks`.
