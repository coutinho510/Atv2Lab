## 1. Lógica de Atraso

- [x] 1.1 Criar `is_task_overdue(task)` em `utils/api_client.py` (compara `data` com a data de hoje e ignora tarefas com `status_tarefa == "completa"`).

## 2. UI — Página de Tarefas

- [x] 2.1 Exibir badge "🔴 Atrasada" em `render_task_card` (`views/tarefas_page.py`) quando `is_task_overdue(task)` for verdadeiro.

## 3. UI — Dashboard

- [x] 3.1 Exibir o mesmo badge na lista "Próximas Tarefas" em `views/dashboard_page.py`.

## 4. Validação

- [x] 4.1 Validar manualmente com tarefas de datas passadas, atual e futura, em cada status (pendente, em_progresso, completa).
