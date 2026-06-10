import streamlit as st
import pandas as pd
from utils.api_client import get_subjects, get_activities_for_subject, get_grades_for_activity, create_or_update_grade

# --- Configuração da Página ---
st.set_page_config(page_title="Lançamento de Notas", page_icon="💯", layout="wide")

st.title("💯 Lançamento de Notas")

if not st.session_state.get('auth_token'):
    st.warning("Por favor, faça login para gerenciar as notas.")
    st.stop()

# --- Seleção de Disciplina e Atividade ---

subjects = get_subjects()
if not subjects:
    st.info("Nenhuma disciplina encontrada. Cadastre uma disciplina primeiro na página '📚 Disciplinas'.")
    st.stop()

subject_map = {s['name']: s['id'] for s in subjects}
selected_subject_name = st.selectbox("Selecione uma Disciplina", options=subject_map.keys())

if selected_subject_name:
    selected_subject_id = subject_map[selected_subject_name]
    
    activities = get_activities_for_subject(selected_subject_id)
    if not activities:
        st.info("Nenhuma atividade encontrada para esta disciplina. Cadastre uma na página '📝 Atividades'.")
        st.stop()

    activity_map = {a['name']: a['id'] for a in activities}
    selected_activity_name = st.selectbox("Selecione uma Atividade", options=activity_map.keys())

    if selected_activity_name:
        selected_activity_id = activity_map[selected_activity_name]
        
        st.divider()
        st.subheader(f"Lançar nota para: {selected_activity_name}")

        # --- Lançamento de Nota ---
        # No modelo atual simplificado, cada atividade tem apenas uma nota associada ao usuário logado.
        
        grades = get_grades_for_activity(selected_activity_id)
        current_grade = grades[0] if grades else None
        
        # O valor inicial do input numérico será a nota existente ou 0.0
        initial_grade_value = float(current_grade['grade']) if current_grade and 'grade' in current_grade else 0.0
        
        with st.form("form_grade"):
            grade_value = st.number_input(
                "Nota", 
                min_value=0.0, 
                max_value=100.0, 
                value=initial_grade_value,
                step=0.5,
                format="%.2f"
            )
            
            submitted = st.form_submit_button("Salvar Nota")
            if submitted:
                existing_grade_id = current_grade['id'] if current_grade else None
                result = create_or_update_grade(selected_activity_id, grade_value, existing_grade_id)
                if result:
                    st.success(f"Nota para '{selected_activity_name}' salva com sucesso!")
                    # st.rerun() é desnecessário pois o cache será limpo e o valor atualizado na próxima interação