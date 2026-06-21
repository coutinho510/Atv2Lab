## Why

O checklist do EduTrack AI (seção "Relatórios e Progresso") pede uma tela de relatórios com histórico de tarefas por período e progresso por disciplina, além de exportação dos dados do usuário. Hoje essas informações só existem espalhadas no Dashboard (sem filtro de período) e não há nenhuma forma de exportar disciplinas/tarefas.

## What Changes

- **Nova página "📈 Relatórios"** (`views/relatorios_page.py`), acessível pelo menu de navegação em `app.py`.
- **Histórico de tarefas por período**: filtro de data inicial/final (`st.date_input`), tabela com as tarefas cujo prazo cai dentro do intervalo.
- **Progresso por disciplina**: mesma lógica de conclusão usada no Dashboard, reaproveitada aqui como parte do relatório.
- **Exportação de dados em CSV**: dois botões de download (`st.download_button`) — disciplinas e tarefas — gerados com `pandas.DataFrame.to_csv()`. **Apenas CSV nesta fase** (PDF fica de fora, conforme decidido com o usuário).

## Capabilities

### New Capabilities
- `reporting`: usuários autenticados podem visualizar um histórico de tarefas filtrado por período, ver o progresso por disciplina em uma tela dedicada, e exportar suas disciplinas e tarefas em CSV.

## Impact

- **Frontend apenas**: `views/relatorios_page.py` (novo), `app.py` (novo item de menu).
- **Backend**: nenhuma mudança — reaproveita `get_subjects()`/`get_tasks()` já existentes em `utils/api_client.py`. Nenhum arquivo `.xs` foi tocado.
- **Dependência**: `pandas`, já listada em `requirements.txt`.
- **Fora de escopo**: exportação em PDF (decidido explicitamente com o usuário, só CSV por agora).
