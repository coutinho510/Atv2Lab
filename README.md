# Edutrack-ai

Sistema de gerenciamento acadêmico construído com **Streamlit** (frontend)
e **Xano** (backend / API REST + banco de dados).

Permite que o usuário se registre/faça login e gerencie suas **disciplinas**
e **tarefas**, acompanhando o progresso de estudos em um **dashboard**.

## Funcionalidades

- **Autenticação**: registro e login de usuários (token JWT).
- **Dashboard**: métricas gerais, tarefas por status, progresso por
  disciplina e próximas tarefas pendentes.
- **Disciplinas**: criar, listar, editar, excluir e buscar disciplinas
  (nome, professor, carga horária).
- **Tarefas**: criar, listar, editar, excluir e buscar tarefas vinculadas a
  uma disciplina (título, descrição, data, status).
- **Perfil**: dados do usuário autenticado.

## Stack

| Camada | Tecnologia |
|---|---|
| Frontend | Streamlit (Python) |
| Backend / API | Xano (REST API + banco de dados) |
| Autenticação | Xano Auth (Bearer Token / JWT) |

## Como rodar o projeto

Pré-requisito: Python 3.10+

```powershell
# 1. Instalar as dependências
pip install -r requirements.txt

# 2. Rodar a aplicação
streamlit run app.py
```

A aplicação abre em `http://localhost:8501`. É necessário ter um usuário
cadastrado na base Xano (ou usar a tela de Registro) para acessar as páginas
internas.

## Estrutura do Projeto

```
Atv2Lab/
├── app.py                  # Entrada: autenticação e navegação (sidebar)
├── requirements.txt
├── utils/
│   └── api_client.py       # Camada única de acesso à API Xano
├── views/                   # Páginas liberadas após login
│   ├── dashboard_page.py
│   ├── disciplinas_page.py
│   ├── tarefas_page.py
│   └── perfil_page.py
└── agent-estrutura.md      # Especificações de estrutura, UX e padrões
```

## Como funciona a base

### Autenticação e navegação
- **Não logado**: a sidebar mostra apenas "Login" e "Registro"; nenhuma
  página interna fica acessível.
- **Logado**: a sidebar libera a navegação entre Dashboard, Disciplinas,
  Tarefas e Perfil, além do botão de Logout.
- O token retornado pelo Xano é guardado em `st.session_state.auth_token` e
  enviado em todas as chamadas via header `Authorization: Bearer <token>`.

### Camada de API (`utils/api_client.py`)
Cada grupo de API do Xano tem sua própria constante de URL e funções CRUD
dedicadas:

| Constante | Uso |
|---|---|
| `XANO_API_URL` | Autenticação (login/registro/perfil) e notas |
| `SUBJECT_API_URL` | CRUD de disciplinas |
| `TASK_API_URL` | CRUD de tarefas |
| `DASHBOARD_API_URL` | Dados agregados para o Dashboard |

Funções de listagem usam `@st.cache_data` (cache de 5 min); funções de
criar/editar/excluir chamam `st.cache_data.clear()` ao final para invalidar
o cache.

### Disciplinas
CRUD completo (nome, professor, carga horária), com validação de duplicata
(mesmo nome + professor) e busca por nome.

### Tarefas
CRUD completo vinculado a uma disciplina — relação N:N (cada disciplina pode
ter N tarefas, cada tarefa pertence a 1 disciplina). Status possíveis:
`pendente`, `em_progresso`, `completa`.

### Dashboard
Métricas gerais (disciplinas ativas, tarefas pendentes, progresso geral),
contagem de tarefas por status, progresso de conclusão por disciplina e
lista das próximas tarefas pendentes.

## Documentação adicional

Veja [`agent-estrutura.md`](agent-estrutura.md) para detalhes de navegação,
padrões de implementação (Streamlit) e especificações de cada módulo.
