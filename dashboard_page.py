import streamlit as st
from utils.api_client import get_subjects, get_activities_for_subject

def render_dashboard_page():
    """Renderiza a página do Dashboard."""
    st.title("🏠 Dashboard")
    
    subjects = get_subjects() or []
    
    total_activities = 0
    total_pending_activities = 0
    
    if subjects:
        for subject in subjects:
            activities = get_activities_for_subject(subject.get('id'))
            if activities:
                total_activities += len(activities)
                for activity in activities:
                    if activity.get('status') != 'Concluída': # Assumindo 'Concluída' como status final
                        total_pending_activities += 1
    
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric(label="Total de disciplinas ativas", value=len(subjects))
    with col2:
        st.metric(label="Total de tarefas pendentes", value=total_pending_activities)
    with col3:
        st.metric(label="Progresso geral", value="0%") # Placeholder, pode ser calculado futuramente