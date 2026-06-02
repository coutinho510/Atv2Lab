import streamlit as st
import subprocess
import json
import pandas as pd
from utils.api_client import get_subjects, get_activities_for_subject, login_user

# Configuração da Página (Título na aba do navegador)
st.set_page_config(page_title="EduTrack AI", page_icon="🎓", layout="wide")

def show_login_form():
    """Exibe o formulário de login."""
    st.title("🎓 Bem-vindo ao EduTrack AI")
    with st.form("login_form"):
        email = st.text_input("Email")
        password = st.text_input("Senha", type="password")
        submitted = st.form_submit_button("Login")
        if submitted:
            token = login_user(email, password)
            if token:
                st.session_state['auth_token'] = token
                st.rerun()
            else:
                # A função login_user já exibe o st.error
                pass

def show_dashboard():
    """Exibe o dashboard principal da aplicação."""
    st.title("📊 Seu Dashboard Acadêmico")
    st.sidebar.success("Selecione uma página acima.")
    if st.sidebar.button("Logout"):
        del st.session_state['auth_token']
        st.rerun()

    subjects = get_subjects()
    if not subjects:
        st.info("Você ainda não tem disciplinas cadastradas. Comece adicionando uma na página '📚 Disciplinas'.")
        st.stop()

    activities_per_subject = {}
    for subject in subjects:
        activities = get_activities_for_subject(subject['id'])
        activities_per_subject[subject['name']] = len(activities)

    total_activities = sum(activities_per_subject.values())

    # --- Métricas Principais ---
    with st.container(border=True):
        col1, col2 = st.columns(2)
        col1.metric("Disciplinas Cadastradas", len(subjects))
        col2.metric("Total de Atividades", total_activities)

    # --- Gráfico de Atividades por Disciplina ---
    st.subheader("📊 Atividades por Disciplina")
    if total_activities > 0:
        chart_data = pd.DataFrame(activities_per_subject.items(), columns=['Disciplina', 'Número de Atividades'])
        st.bar_chart(chart_data.set_index('Disciplina'))
    else:
        st.info("Nenhuma atividade cadastrada para exibir no gráfico.")

    # --- Progresso Geral (usando o script Python) ---
    st.subheader("📈 Progresso Geral")

    # Simulação de progresso - em um cenário real, isso viria do banco de dados
    if total_activities > 0:
        completed_items = st.slider("Itens Concluídos (Simulação)", 0, total_activities, int(total_activities / 2))
        
        result = subprocess.run(['python', 'calculate_progress.py', '--completed', str(completed_items), '--total', str(total_activities)], capture_output=True, text=True)
        progress_data = json.loads(result.stdout)
        progress_percentage = progress_data.get("progress_percentage", 0)

        st.progress(progress_percentage / 100, text=f"{progress_percentage:.2f}% de progresso")
    else:
        st.info("Cadastre atividades para ver seu progresso.")

# --- Lógica Principal ---
if 'auth_token' not in st.session_state:
    show_login_form()
else:
    show_dashboard()