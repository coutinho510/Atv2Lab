import streamlit as st
import pandas as pd
from datetime import datetime
from utils.api_client import get_subjects, get_activities_for_subject, create_activity, delete_record

# --- Configuração da Página ---
st.set_page_config(page_title="Atividades Acadêmicas", page_icon="📝", layout="wide")

# --- Configurações da API e Estado ---
if 'editing_activity' not in st.session_state:
    st.session_state.editing_activity = None

def update_activity(activity_id, name, description, due_date):
    """Atualiza uma atividade existente."""
    try:
        payload = {
            "name": name,
            "description": description,
            "due_date": due_date
        }
        # Esta chamada também poderia ser abstraída no api_client
        response = st.requests.patch(f"https://x8ki-letl-twmt.n7.xano.io/api:v1/academic_activities/{activity_id}", json=payload, headers=st.session_state.api_client.get_headers())
        response.raise_for_status()
        st.cache_data.clear()
        st.session_state.editing_activity = None # Limpa o estado de edição
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Erro ao atualizar atividade: {e.response.text}")
        return None

# --- Interface do Usuário ---

st.title("📝 Gestão de Atividades")

if not st.session_state.get('auth_token'):
    st.warning("Por favor, faça login para gerenciar suas atividades.")
    st.stop()

subjects = get_subjects()
if not subjects:
    st.info("Nenhuma disciplina encontrada. Cadastre uma disciplina primeiro na página '📚 Disciplinas'.")
    st.stop()

subject_map = {s['name']: s['id'] for s in subjects}
selected_subject_name = st.selectbox("Selecione uma Disciplina", options=subject_map.keys())

if selected_subject_name:
    selected_subject_id = subject_map[selected_subject_name]

    st.divider()

    tab_lista, tab_nova = st.tabs(["📋 Listar Atividades", "➕ Nova Atividade"])

    with tab_lista:
        st.subheader(f"Atividades de {selected_subject_name}")

        # --- Formulário de Edição (aparece no topo se estiver editando) ---
        if st.session_state.editing_activity:
            activity = st.session_state.editing_activity
            st.info(f"✏️ Editando atividade: **{activity['name']}**")
            with st.form("form_edit_activity"):
                # Converte a data de string para objeto date
                current_due_date = datetime.fromisoformat(activity['due_date'].replace('Z', '+00:00')).date()

                name = st.text_input("Nome da Atividade", value=activity['name'])
                description = st.text_area("Descrição", value=activity.get('description', ''))
                due_date = st.date_input("Data de Entrega", value=current_due_date)

                col1, col2 = st.columns([1, 6])
                with col1:
                    if st.form_submit_button("Salvar Alterações"):
                        due_date_iso = datetime.combine(due_date, datetime.min.time()).isoformat() + "Z"
                        if update_activity(activity['id'], name, description, due_date_iso):
                            st.success("Atividade atualizada com sucesso!")
                            st.rerun()
                with col2:
                    if st.form_submit_button("Cancelar"):
                        st.session_state.editing_activity = None
                        st.rerun()
            st.divider()

        # --- Lista de Atividades ---
        activities = get_activities_for_subject(selected_subject_id)
        if activities:
            df = pd.DataFrame(activities)
            st.dataframe(df[['name', 'description', 'due_date']], use_container_width=True, hide_index=True)

            # --- Seção de Ações ---
            st.subheader("Ações")
            activity_map = {a['name']: a for a in activities}
            selected_activity_name = st.selectbox("Selecione uma atividade para gerenciar:", options=activity_map.keys())

            if selected_activity_name:
                selected_activity = activity_map[selected_activity_name]
                col1, col2 = st.columns(2)
                with col1:
                    if st.button("✏️ Editar", key=f"edit_{selected_activity['id']}"):
                        st.session_state.editing_activity = selected_activity
                        st.rerun()
                with col2:
                    if st.button("🗑️ Excluir", key=f"delete_{selected_activity['id']}", type="primary"):
                        if delete_record('academic_activities', selected_activity['id']):
                            st.success("Atividade excluída com sucesso!")
                            st.rerun()
        else:
            st.info("Nenhuma atividade cadastrada para esta disciplina.")

    with tab_nova:
        st.subheader("Cadastrar Nova Atividade")
        with st.form("form_atividade", clear_on_submit=True):
            name = st.text_input("Nome da Atividade")
            description = st.text_area("Descrição")
            due_date = st.date_input("Data de Entrega")
            
            submitted = st.form_submit_button("Salvar")
            if submitted:
                # Converte a data para o formato ISO 8601 com timezone (UTC)
                due_date_iso = datetime.combine(due_date, datetime.min.time()).isoformat() + "Z"
                
                new_activity = create_activity(name, description, due_date_iso, selected_subject_id)
                if new_activity:
                    st.success(f"Atividade '{name}' salva com sucesso!")
                    st.rerun()