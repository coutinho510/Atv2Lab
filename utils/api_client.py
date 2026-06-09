import streamlit as st
import requests
import json
from datetime import datetime

# --- Configurações Globais ---
XANO_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:xhk3GBZb"  # Substitua pela URL do seu endpoint Xano

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
    """Busca todas as disciplinas do usuário."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{XANO_API_URL}/subjects/list", headers=get_headers()) # Usando endpoint de listagem paginada
        response.raise_for_status()
        return response.json().get('items', []) # Retorna apenas os itens da lista
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar disciplinas: {e}")
        return []

@st.cache_data(ttl=60)
def get_activities_for_subject(subject_id):
    """Busca atividades para uma disciplina específica."""
    if not st.session_state.get('auth_token') or not subject_id:
        return []
    try:
        response = requests.get(f"{XANO_API_URL}/academic_activities", params={"subject_id": subject_id}, headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar atividades: {e}")
        return []

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

def create_subject(name, teacher_name, hours):
    """Cria uma nova disciplina."""
    try:
        payload = {"name": name, "teacher_name": teacher_name, "hours": hours} #
        response = requests.post(f"{XANO_API_URL}/subject", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao criar disciplina: {e.response.text}")
        return None

def create_activity(name, description, due_date, subject_id):
    """Cria uma nova atividade acadêmica."""
    try:
        payload = {
            "name": name,
            "description": description,
            "due_date": due_date,
            "subject_id": subject_id
        } #
        response = requests.post(f"{XANO_API_URL}academic_activities", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao criar atividade: {e.response.text}")
        return None

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

def delete_record(record_type, record_id):
    """Exclui um registro (disciplina ou atividade)."""
    try:
        url = f"{XANO_API_URL}/{record_type}/{record_id}/delete" if record_type == "subjects" else f"{XANO_API_URL}/{record_type}/{record_id}" #
        response = requests.delete(url, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return True
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao excluir: {e.response.text}")
        return False

# --- Funções Adicionais para Gestão de Disciplinas ---

def get_subject_by_id(subject_id):
    """Busca uma disciplina específica pelo ID."""
    if not st.session_state.get('auth_token') or not subject_id:
        return None
    try:
        response = requests.get(f"{XANO_API_URL}/subjects/{subject_id}", headers=get_headers()) #
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao buscar disciplina: {e}")
        return None

def update_subject(subject_id, name, teacher, hours):
    """Atualiza os dados de uma disciplina."""
    try:
        payload = {
            "name": name,
            "teacher_name": teacher, #
            "hours": hours
        } #
        response = requests.patch(f"{XANO_API_URL}/subjects/{subject_id}/update", json=payload, headers=get_headers()) #
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

def check_duplicate_subject(name, teacher, exclude_id=None):
    """Verifica se já existe uma disciplina com o mesmo nome e professor.
    
    Args:
        name: Nome da disciplina
        teacher: Nome do professor
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
            subject_teacher = subject.get('teacher_name', '').lower().strip() #
            input_name = name.lower().strip()
            input_teacher = teacher.lower().strip()
            
            # Se excluir_id é fornecido, pula a própria disciplina
            if exclude_id and subject.get('id') == exclude_id:
                continue
            
            # Verifica duplicata
            if subject_name == input_name and subject_teacher == input_teacher:
                return True
        
        return False
    except Exception as e:
        st.error(f"Erro ao verificar duplicata: {e}")
        return False

def search_subjects_by_name(search_term):
    """Busca disciplinas que correspondem ao termo de busca."""
    if not st.session_state.get('auth_token'):
        return []
    
    try:
        response = requests.get(f"{XANO_API_URL}/subjects/search", params={"query": search_term}, headers=get_headers()) #
        response.raise_for_status()
        results = response.json().get('items', []) #
        
        return results
    except Exception as e:
        st.error(f"Erro ao buscar disciplinas: {e}")
        return []

def get_subjects_with_overdue_tasks():
    """Retorna disciplinas que possuem tarefas em atraso."""
    if not st.session_state.get('auth_token'):
        return []
    
    try:
        response = requests.get(f"{XANO_API_URL}/subjects/overdue", headers=get_headers()) #
        response.raise_for_status()
        subjects_with_overdue = response.json().get('items', []) #
        return subjects_with_overdue
    except Exception as e:
        st.error(f"Erro ao buscar disciplinas com tarefas em atraso: {e}")
        return []