import streamlit as st
import pandas as pd
import requests
from utils.api_client import get_subjects, create_subject, delete_record, XANO_API_URL, get_headers

# --- Configuração da Página ---
st.set_page_config(page_title="Disciplinas", page_icon="📚", layout="wide")

# --- Estado da Sessão ---
if 'editing_subject' not in st.session_state:
    st.session_state.editing_subject = None

def update_subject(subject_id, name, teacher_name):
    """Atualiza uma disciplina existente (Apenas processa os dados)."""
    try:
        payload = {"name": name, "teacher_name": teacher_name}
        response = requests.patch(f"{XANO_API_URL}subjects/{subject_id}", json=payload, headers=get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        st.session_state.editing_subject = None # Limpa o estado de edição
        return response.json()
    except requests.exceptions.RequestException as e:
        error_msg = e.response.text if e.response else str(e)
        st.error(f"Erro ao atualizar disciplina: {error_msg}")
        return None

# --- Interface ---
st.title("📚 Minhas Disciplinas")

if not st.session_state.get('auth_token'):
    st.warning("Por favor, faça login na página principal para gerenciar suas disciplinas.")
    st.stop()

# --- Formulário de Cadastro / Edição ---
if st.session_state.editing_subject:
    st.subheader("✏️ Editando Disciplina")
    subject = st.session_state.editing_subject
    
    # O formulário agora envelopa corretamente os inputs e o botão de submit
    with st.form("form_edit_subject", clear_on_submit=True):
        new_name = st.text_input("Nome da Disciplina", value=subject['name'])
        new_teacher = st.text_input("Nome do Professor", value=subject.get('teacher_name', ''))
        
        submitted = st.form_submit_button("Salvar Alterações")
        if submitted:
            if update_subject(subject['id'], new_name, new_teacher):
                st.success("Disciplina atualizada com sucesso!")
                st.rerun()
else:
    with st.expander("➕ Adicionar Nova Disciplina", expanded=False):
        with st.form("form_new_subject", clear_on_submit=True):
            name = st.text_input("Nome da Disciplina")
            teacher_name = st.text_input("Nome do Professor")
            submitted = st.form_submit_button("Cadastrar")
            if submitted:
                if create_subject(name, teacher_name):
                    st.success(f"Disciplina '{name}' cadastrada com sucesso!")
                    st.rerun()

# --- Lista de Disciplinas ---
st.header("📋 Lista de Disciplinas")
subjects = get_subjects()

if not subjects:
    st.info("Você ainda não cadastrou nenhuma disciplina.")
else:
    df = pd.DataFrame(subjects)
    df_display = df[['name', 'teacher_name', 'created_at']].rename(columns={
        'name': 'Nome da Disciplina',
        'teacher_name': 'Professor(a)',
        'created_at': 'Data de Criação'
    })
    
    st.dataframe(df_display, use_container_width=True, hide_index=True)

    st.write("---")
    st.subheader("Ações")
    
    selected_subject_name = st.selectbox("Selecione uma disciplina para gerenciar:", options=[s['name'] for s in subjects])
    selected_subject = next((s for s in subjects if s['name'] == selected_subject_name), None)

    if selected_subject:
        col1, col2 = st.columns(2)
        with col1:
            if st.button("✏️ Editar", key=f"edit_{selected_subject['id']}"):
                st.session_state.editing_subject = selected_subject
                st.rerun()
        with col2:
            if st.button("🗑️ Excluir", key=f"delete_{selected_subject['id']}", type="primary"):
                if delete_record('subjects', selected_subject['id']):
                    st.success("Disciplina excluída com sucesso!")
                    st.rerun()