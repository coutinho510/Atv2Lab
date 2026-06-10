import streamlit as st
import requests
import json
from datetime import datetime

# --- Configurações Globais ---
XANO_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:xhk3GBZb"  # Substitua pela URL do seu endpoint Xano
SUBJECT_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:subject-crud"  # Grupo de API "Subject CRUD"
TASK_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:Zb1x7tiT"  # Grupo de API "Academic Tasks"
DASHBOARD_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:5sx9vVEG"  # Grupo de API "Dashboard"

# --- Status de Tarefas ---
STATUS_LABELS = {
    "pendente": "⏳ Pendente",
    "em_progresso": "🔄 Em Progresso",
    "completa": "✅ Completa",
}
STATUS_OPTIONS = list(STATUS_LABELS.keys())

def get_headers():
    """Retorna os cabeçalhos de autorização para as chamadas de API."""
    return {"Authorization": f"Bearer {st.session_state.get('auth_token')}"}

def login_user(email, password):
    """Autentica o usuário e retorna o token."""
    try:
        payload = {"email": email, "password": password}
        response = requests.post(f"{XANO_API_URL}/auth/login", json=payload)
        response.raise_for_status()
        data = response.json()
        return data.get("authToken"), data
    except requests.exceptions.RequestException as e:
        error_message = "Credenciais inválidas ou problema no servidor."
        if e.response is not None:
            try:
                error_message = e.response.json().get('message', error_message)
            except json.JSONDecodeError:
                error_message = e.response.text
        st.error(f"Erro no login: {error_message}")
        return None, None

def register_user(name, email, password):
    """Registra um novo usuário no Xano."""
    try:
        payload = {"name": name, "email": email, "password": password}
        response = requests.post(f"{XANO_API_URL}/auth/signup", json=payload)
        response.raise_for_status()
        st.success("Usuário registrado com sucesso! Você já pode fazer o login.")
        data = response.json()
        return data.get("authToken"), data
    except requests.exceptions.RequestException as e:
        error_message = "Não foi possível registrar o usuário."
        if e.response is not None:
            try:
                error_message = e.response.json().get('message', e.response.text)
            except json.JSONDecodeError:
                error_message = e.response.text
        st.error(f"Erro no registro: {error_message}")
        return None, None

@st.cache_data(ttl=60)
def get_current_user():
    """Obtém os dados do usuário autenticado via GET /auth/me.
    
    Endpoint: GET /auth/me
    Headers: Authorization: Bearer {token}
    Response: {"id": "...", "name": "...", "email": "...", ...}
    """
    if not st.session_state.get('auth_token'):
        return None
    try:
        # Tenta com /auth/me
        response = requests.get(f"{XANO_API_URL}/auth/me", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        try:
            # Se falhar, tenta sem a barra inicial
            response = requests.get(f"{XANO_API_URL}auth/me", headers=get_headers())
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e2:
            return None

# --- Funções de API ---

@st.cache_data(ttl=300)
def get_subjects():
    """Busca todas as disciplinas do usuário (GET /list)."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{SUBJECT_API_URL}/list", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar disciplinas: {e}")
        return []

@st.cache_data(ttl=300)
def get_tasks():
    """Busca todas as tarefas do usuário (GET /list-all)."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{TASK_API_URL}/list-all", params={"per_page": 100}, headers=get_headers())
        response.raise_for_status()
        items = response.json().get('items', [])

        # A API pode retornar a mesma tarefa mais de uma vez (join com
        # disciplinas/matrículas), então removemos duplicatas pelo id.
        seen_ids = set()
        unique_items = []
        for item in items:
            item_id = item.get('id')
            if item_id not in seen_ids:
                seen_ids.add(item_id)
                unique_items.append(item)
        return unique_items
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar tarefas: {e}")
        return []

@st.cache_data(ttl=300)
def get_dashboard_subjects():
    """Busca as disciplinas para o Dashboard (GET /Diciplinas-dashboard)."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{DASHBOARD_API_URL}/Diciplinas-dashboard", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar disciplinas do dashboard: {e}")
        return []

@st.cache_data(ttl=300)
def get_dashboard_tasks():
    """Busca as tarefas para o Dashboard (GET /Tarefas-dashboard)."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{DASHBOARD_API_URL}/Tarefas-dashboard", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar tarefas do dashboard: {e}")
        return []

def get_tasks_for_subject(subject_id):
    """Filtra as tarefas de uma disciplina específica."""
    if not subject_id:
        return []
    return [t for t in get_tasks() if t.get('subject_id') == subject_id]

def get_task_by_id(task_id):
    """Busca uma tarefa específica pelo ID (GET /single-task/{task_id})."""
    if not st.session_state.get('auth_token') or not task_id:
        return None
    try:
        response = requests.get(f"{TASK_API_URL}/single-task/{task_id}", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar tarefa: {e}")
        return None

@st.cache_data(ttl=60)
def get_grades_for_activity(activity_id):
    """Busca as notas de uma atividade específica."""
    if not st.session_state.get('auth_token') or not activity_id:
        return []
    try:
        response = requests.get(f"{XANO_API_URL}/activity_grades", params={"activity_id": activity_id}, headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar notas: {e}")
        return []

def create_subject(name, professor, cargahoraria):
    """Cria uma nova disciplina (POST /create)."""
    try:
        payload = {"name": name, "professor": professor, "cargahoraria": cargahoraria}
        response = requests.post(f"{SUBJECT_API_URL}/create", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao criar disciplina: {e.response.text}")
        return None

def create_task(subject_id, title, data, description="", status_tarefa="pendente"):
    """Cria uma nova tarefa (POST /add-task)."""
    try:
        payload = {
            "subject_id": subject_id,
            "title": title,
            "description": description,
            "data": data,
            "status_tarefa": status_tarefa,
        }
        response = requests.post(f"{TASK_API_URL}/add-task", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao criar tarefa: {e.response.text}")
        return None

def update_task(task_id, subject_id, title, data, description="", status_tarefa="pendente"):
    """Atualiza os dados de uma tarefa (PUT /edit-task/{task_id})."""
    try:
        payload = {
            "subject_id": subject_id,
            "title": title,
            "description": description,
            "data": data,
            "status_tarefa": status_tarefa,
        }
        response = requests.put(f"{TASK_API_URL}/edit-task/{task_id}", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao atualizar tarefa: {e.response.text}")
        return None

def delete_task(task_id):
    """Exclui uma tarefa (DELETE /delete-task/{task_id})."""
    try:
        response = requests.delete(f"{TASK_API_URL}/delete-task/{task_id}", headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return True
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao excluir tarefa: {e.response.text}")
        return False

def create_or_update_grade(activity_id, grade_value, existing_grade_id=None):
    """Cria ou atualiza uma nota para uma atividade."""
    try:
        payload = {
            "activity_id": activity_id,
            "grade": grade_value
        } #
        if existing_grade_id:
            response = requests.patch(f"{XANO_API_URL}activity_grades/{existing_grade_id}", json=payload, headers=get_headers())
        else:
            response = requests.post(f"{XANO_API_URL}activity_grades", json=payload, headers=get_headers())
        
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao salvar nota: {e.response.text}")
        return None

def delete_subject(subject_id):
    """Exclui uma disciplina (DELETE /delete/{subject_id})."""
    try:
        response = requests.delete(f"{SUBJECT_API_URL}/delete/{subject_id}", headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return True
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao excluir disciplina: {e.response.text}")
        return False

# --- Funções Adicionais para Gestão de Disciplinas ---

def get_subject_by_id(subject_id):
    """Busca uma disciplina específica pelo ID (GET /get/{subject_id})."""
    if not st.session_state.get('auth_token') or not subject_id:
        return None
    try:
        response = requests.get(f"{SUBJECT_API_URL}/get/{subject_id}", headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar disciplina: {e}")
        return None

def update_subject(subject_id, name, professor, cargahoraria):
    """Atualiza os dados de uma disciplina (PUT /update/{subject_id})."""
    try:
        payload = {"name": name, "professor": professor, "cargahoraria": cargahoraria}
        response = requests.put(f"{SUBJECT_API_URL}/update/{subject_id}", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        error_message = "Erro ao atualizar disciplina."
        if e.response is not None:
            try:
                error_message = e.response.json().get('message', e.response.text)
            except json.JSONDecodeError:
                error_message = e.response.text
        st.error(f"Erro ao atualizar disciplina: {error_message}")
        return None

def check_duplicate_subject(name, professor, exclude_id=None):
    """Verifica se já existe uma disciplina com o mesmo nome e professor.

    Args:
        name: Nome da disciplina
        professor: Nome do professor
        exclude_id: ID da disciplina a excluir da busca (útil ao editar)

    Returns:
        True se existe duplicata, False caso contrário
    """
    if not st.session_state.get('auth_token'):
        return False

    try:
        all_subjects = get_subjects()
        for subject in all_subjects:
            subject_name = subject.get('name', '').lower().strip()
            subject_professor = subject.get('professor', '').lower().strip()
            input_name = name.lower().strip()
            input_professor = professor.lower().strip()

            # Se exclude_id é fornecido, pula a própria disciplina
            if exclude_id and subject.get('id') == exclude_id:
                continue

            # Verifica duplicata
            if subject_name == input_name and subject_professor == input_professor:
                return True

        return False
    except Exception as e:
        st.error(f"Erro ao verificar duplicata: {e}")
        return False

def search_subjects_by_name(search_term):
    """Busca disciplinas cujo nome contém o termo informado.

    A API "Subject CRUD" não possui endpoint de busca, então o filtro é
    aplicado localmente sobre o resultado de get_subjects().
    """
    if not st.session_state.get('auth_token'):
        return []

    term = search_term.lower().strip()
    return [s for s in get_subjects() if term in s.get('name', '').lower()]