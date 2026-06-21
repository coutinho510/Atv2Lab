import streamlit as st
from utils.api_client import (
    login_user,
    register_user,
    request_password_reset,
    confirm_password_reset,
    is_session_expired,
)
from views.disciplinas_page import render_disciplinas_page
from views.dashboard_page import render_dashboard_page
from views.tarefas_page import render_tarefas_page
from views.perfil_page import render_perfil_page
from views.relatorios_page import render_relatorios_page

# --- Configuração da Página Original ---
st.set_page_config(page_title="Edutrack-ai", page_icon="🎓", layout="wide")

# --- Identidade Visual: fonte e wordmark do app ---
st.markdown(
    """
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');
        html, body, [class*="css"] { font-family: 'Poppins', sans-serif; }
        div[data-testid="stSidebar"] button[kind="primary"],
        div.stButton > button[kind="primary"] {
            background: linear-gradient(135deg, #A66CFF 0%, #4D96FF 100%);
            border: none;
        }
    </style>
    """,
    unsafe_allow_html=True,
)


def render_logo(container=None, size="1.3em"):
    """Renderiza o wordmark do app. Por padrão na barra lateral."""
    target = container or st.sidebar
    target.markdown(
        f"""
        <h2 style="margin-bottom:0;">
            <span style="font-size:{size};">🎓</span>
            <span style="background: linear-gradient(135deg, #A66CFF 0%, #4D96FF 100%);
                  -webkit-background-clip: text; background-clip: text; color: transparent;
                  font-weight: 700;">EduTrack AI</span>
        </h2>
        """,
        unsafe_allow_html=True,
    )


# --- Estado da Sessão ---
if 'editing_subject' not in st.session_state:
    st.session_state.editing_subject = None

if 'auth_token' not in st.session_state:
    st.session_state.auth_token = None

if 'user_data' not in st.session_state:
    st.session_state.user_data = None

if 'auth_mode' not in st.session_state:
    st.session_state.auth_mode = "login"  # "login" ou "register"

# ==============================================================================
# SEÇÃO DE AUTENTICAÇÃO - Se não estiver logado
# ==============================================================================
if not st.session_state.auth_token:
    # --- BARRA LATERAL (SIDEBAR) - Acesso ---
    render_logo()
    st.sidebar.divider()
    opcao_acesso = st.sidebar.radio("Acesso", ["🔐 Login", "📝 Registro", "🔁 Esqueci a Senha"])
    if opcao_acesso == "🔐 Login":
        st.session_state.auth_mode = "login"
    elif opcao_acesso == "📝 Registro":
        st.session_state.auth_mode = "register"
    else:
        st.session_state.auth_mode = "reset"

    render_logo(container=st, size="2em")
    st.markdown("### Sistema de Gerenciamento Acadêmico")
    st.divider()

    # --- MODO: LOGIN ---
    if st.session_state.auth_mode == "login":
        st.subheader("🔐 Fazer Login")
        
        with st.form("form_login", clear_on_submit=False):
            email = st.text_input("E-mail")
            password = st.text_input("Senha", type="password")
            
            submitted = st.form_submit_button("Entrar", type="primary", use_container_width=True)
            
            if submitted:
                if email and password:
                    token, user_data = login_user(email, password)
                    if token:
                        st.session_state.auth_token = token
                        st.session_state.user_data = user_data
                        st.success("Login realizado com sucesso! 🎉")
                        st.rerun()
                else:
                    st.error("Por favor, preencha todos os campos.")
        
        st.info("Não tem uma conta? Clique em 'Registrar' acima para criar uma.")
    
    # --- MODO: REGISTRO ---
    elif st.session_state.auth_mode == "register":
        st.subheader("📝 Criar Conta")
        
        with st.form("form_register", clear_on_submit=False):
            name = st.text_input("Nome Completo")
            email = st.text_input("E-mail")
            password = st.text_input("Senha", type="password")
            confirm_password = st.text_input("Confirmar Senha", type="password")
            
            submitted = st.form_submit_button("Registrar", type="primary", use_container_width=True)
            
            if submitted:
                if not all([name, email, password, confirm_password]):
                    st.error("Por favor, preencha todos os campos.")
                elif password != confirm_password:
                    st.error("As senhas não correspondem.")
                elif len(password) < 6:
                    st.error("A senha deve ter no mínimo 6 caracteres.")
                else:
                    token, user_data = register_user(name, email, password)
                    if token:
                        st.session_state.auth_token = token
                        st.session_state.user_data = user_data
                        st.success("Conta criada com sucesso! Bem-vindo! 🎉")
                        st.rerun()
        
        st.info("Já tem uma conta? Clique em 'Login' acima para entrar.")

    # --- MODO: ESQUECI A SENHA ---
    else:
        st.subheader("🔁 Redefinir Senha")
        st.markdown("**Passo 1:** informe seu e-mail para receber um código de 6 dígitos.")

        with st.form("form_request_reset", clear_on_submit=False):
            reset_email = st.text_input("E-mail")

            if st.form_submit_button("📧 Enviar Código", type="primary", use_container_width=True):
                if reset_email:
                    if request_password_reset(reset_email):
                        st.success("✅ Código de redefinição enviado! Confira seu e-mail.")
                else:
                    st.error("Por favor, informe o e-mail.")

        st.divider()
        st.markdown("**Passo 2:** informe o código recebido por e-mail e defina sua nova senha.")

        with st.form("form_complete_reset", clear_on_submit=False):
            code_email = st.text_input("E-mail", key="reset_code_email")
            reset_code = st.text_input("Código recebido por e-mail (6 dígitos)")
            new_password = st.text_input("Nova Senha", type="password", key="reset_new_password")
            confirm_new_password = st.text_input("Confirmar Nova Senha", type="password", key="reset_confirm_password")

            if st.form_submit_button("🔐 Redefinir Senha", use_container_width=True):
                if not all([code_email, reset_code, new_password, confirm_new_password]):
                    st.error("Por favor, preencha todos os campos.")
                elif new_password != confirm_new_password:
                    st.error("As senhas não correspondem.")
                else:
                    if confirm_password_reset(code_email, reset_code, new_password, confirm_new_password):
                        st.success("✅ Senha redefinida com sucesso! Clique em 'Login' acima para entrar.")

        st.info("Já tem uma conta? Clique em 'Login' acima para entrar.")

else:
    # ==============================================================================
    # SEÇÃO PRINCIPAL - Usuario Autenticado
    # ==============================================================================

    if is_session_expired():
        st.session_state.auth_token = None
        st.session_state.user_data = None
        st.session_state.editing_subject = None
        st.warning("⏰ Sua sessão expirou. Faça login novamente.")
        st.rerun()

    # --- BARRA LATERAL (SIDEBAR) ---
    render_logo()
    
    # Exibir info do usuário logado
    if st.session_state.user_data:
        user_name = st.session_state.user_data.get("name", "Usuário")
        st.sidebar.info(f"👤 Logado como: **{user_name}**")
    
    st.sidebar.divider()
    
    # Menu de navegação
    opcao_menu = st.sidebar.radio("Navegar", ["Dashboard", "Disciplinas", "Tarefas", "Relatórios", "Perfil"])
    
    st.sidebar.divider()
    
    # Botão de logout
    if st.sidebar.button("🚪 Sair (Logout)", type="secondary", use_container_width=True):
        st.session_state.auth_token = None
        st.session_state.user_data = None
        st.session_state.editing_subject = None
        st.success("Você saiu com sucesso!")
        st.rerun()
    
    # ==============================================================================
    # OPÇÃO: DASHBOARD
    # ==============================================================================
    if opcao_menu == "Dashboard": #
        render_dashboard_page() #
    
    # ==============================================================================
    # OPÇÃO: DISCIPLINAS
    # ==============================================================================
    elif opcao_menu == "Disciplinas":
        render_disciplinas_page() #
    
    # ==============================================================================
    # OPÇÃO: TAREFAS
    # ==============================================================================
    elif opcao_menu == "Tarefas":
        render_tarefas_page() #

    # ==============================================================================
    # OPÇÃO: RELATÓRIOS
    # ==============================================================================
    elif opcao_menu == "Relatórios":
        render_relatorios_page()

    # ==============================================================================
    # OPÇÃO: PERFIL
    # ==============================================================================
    elif opcao_menu == "Perfil":
        render_perfil_page() #