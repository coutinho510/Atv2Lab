import streamlit as st
import pandas as pd
import requests
from utils.api_client import (
    get_subjects, create_subject, delete_record, XANO_API_URL, get_headers,
    login_user, register_user, get_current_user, get_activities_for_subject # Adicionado get_activities_for_subject para o dashboard
)
from pages.disciplinas_page import render_disciplinas_page
from pages.dashboard_page import render_dashboard_page
from pages.tarefas_page import render_tarefas_page
from pages.perfil_page import render_perfil_page

# --- Configuração da Página Original ---
st.set_page_config(page_title="Edutrack-ai", page_icon="🎓", layout="wide")

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
    st.title("🎓 Edutrack-ai")
    st.markdown("### Sistema de Gerenciamento Acadêmico")
    
    # Criando abas para Login e Registro
    col1, col2 = st.columns([1, 1])
    
    with col1:
        if st.button("🔐 Login", key="btn_login", use_container_width=True):
            st.session_state.auth_mode = "login"
        
        st.write("")
        
    with col2:
        if st.button("📝 Registrar", key="btn_register", use_container_width=True):
            st.session_state.auth_mode = "register"
    
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
    else:
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

else:
    # ==============================================================================
    # SEÇÃO PRINCIPAL - Usuario Autenticado
    # ==============================================================================
    
    # --- BARRA LATERAL (SIDEBAR) ---
    st.sidebar.title("🎓 Edutrack-ai")
    
    # Exibir info do usuário logado
    if st.session_state.user_data:
        user_name = st.session_state.user_data.get("name", "Usuário")
        st.sidebar.info(f"👤 Logado como: **{user_name}**")
    
    st.sidebar.divider()
    
    # Menu de navegação
    opcao_menu = st.sidebar.radio("Navegar", ["Dashboard", "Disciplinas", "Tarefas", "Perfil"])
    
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
    # OPÇÃO: PERFIL
    # ==============================================================================
    elif opcao_menu == "Perfil":
        render_perfil_page() #