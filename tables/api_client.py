import streamlit as st
import requests
from datetime import datetime

# --- Configurações Globais ---
XANO_API_URL = "https://x8ki-letl-twmt.n7.xano.io/api:v1"

def get_headers():
    """Retorna os cabeçalhos de autorização para as chamadas de API."""
    return {"Authorization": f"Bearer {st.session_state.get('auth_token')}"}

def login_user(email, password):
    """Autentica o usuário e retorna o token."""
    try:
        payload = {"email": email, "password": password}
        response = requests.post(f"{XANO_API_URL}/auth/login", json=payload)
        response.raise_for_status()
        # A resposta do Xano para login bem-sucedido geralmente contém o token em 'authToken'
        return response.json().get("authToken")
    except requests.exceptions.RequestException as e:
        # Tenta obter a mensagem de erro específica do Xano, se disponível
        error_message = "Credenciais inválidas ou problema no servidor."
        if e.response is not None:
            try:
                error_message = e.response.json().get('message', error_message)
            except json.JSONDecodeError:
                error_message = e.response.text
        st.error(f"Erro no login: {error_message}")
        return None


# --- Funções de API ---

@st.cache_data(ttl=300)
def get_subjects():
    """Busca todas as disciplinas do usuário."""
    if not st.session_state.get('auth_token'):
        return []
    try:
        response = requests.get(f"{XANO_API_URL}/subjects", headers=get_headers())
        response.raise_for_status()
        return response.json()
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

def create_subject(name, teacher_name):
    """Cria uma nova disciplina."""
    try:
        payload = {"name": name, "teacher_name": teacher_name}
        response = requests.post(f"{XANO_API_URL}/subjects", json=payload, headers=get_headers())
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
        }
        response = requests.post(f"{XANO_API_URL}/academic_activities", json=payload, headers=get_headers())
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
        }
        if existing_grade_id:
            # Atualiza a nota existente
            response = requests.patch(f"{XANO_API_URL}/activity_grades/{existing_grade_id}", json=payload, headers=get_headers())
        else:
            # Cria uma nova nota
            response = requests.post(f"{XANO_API_URL}/activity_grades", json=payload, headers=get_headers())
        
        response.raise_for_status()
        st.cache_data.clear()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao salvar nota: {e.response.text}")
        return None

def delete_record(record_type, record_id):
    """Exclui um registro (disciplina ou atividade)."""
    try:
        response = requests.delete(f"{XANO_API_URL}/{record_type}/{record_id}", headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        return True
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao excluir: {e.response.text}")
        return False