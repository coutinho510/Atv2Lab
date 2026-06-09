import streamlit as st
from utils.api_client import get_activities_for_subject # Exemplo de import

def render_tarefas_page():
    """Renderiza a página de Gestão de Tarefas."""
    st.title("📝 Gestão de Tarefas")
    st.markdown("Aqui você poderá visualizar, criar, editar e excluir suas tarefas acadêmicas.")
    
    # TODO: Implementar a lógica para listar, criar, editar e excluir tarefas.
    st.info("🚧 Esta página está em construção. Em breve, você terá todas as funcionalidades de gestão de tarefas aqui!")