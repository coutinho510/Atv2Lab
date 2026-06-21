from datetime import datetime

import streamlit as st
from utils.api_client import get_current_user, update_profile, update_password


def format_timestamp(value):
    """Formata um timestamp epoch (em segundos ou milissegundos) para dd/mm/aaaa HH:MM."""
    if not value:
        return 'N/A'
    try:
        ts = float(value)
        if ts > 1e12:  # epoch em milissegundos
            ts /= 1000
        return datetime.fromtimestamp(ts).strftime('%d/%m/%Y %H:%M')
    except (ValueError, TypeError, OSError):
        return str(value)


def render_perfil_page():
    """Renderiza a página de Perfil do Usuário."""
    st.title("👤 Meu Perfil")

    if 'show_change_password_form' not in st.session_state:
        st.session_state.show_change_password_form = False
    if 'show_edit_profile_form' not in st.session_state:
        st.session_state.show_edit_profile_form = False

    # Tentar atualizar dados do perfil do Xano usando GET /auth/me
    user_data = get_current_user()
    if user_data:
        st.session_state.user_data = user_data

    current_user = st.session_state.user_data or {}

    if not current_user:
        st.warning("⚠️ Não foi possível carregar os dados do perfil. Tente fazer login novamente.")
        return

    # ========== SEÇÃO: INFORMAÇÕES PESSOAIS ==========
    st.subheader("📋 Informações Pessoais")

    with st.container(border=True):
        col1, col2 = st.columns(2)
        with col1:
            st.metric("👤 Nome Completo", current_user.get('name', 'N/A'))
            st.metric("📝 ID do Usuário", str(current_user.get('id', 'N/A')))
        with col2:
            st.metric("📧 E-mail", current_user.get('email', 'N/A'))
            st.metric("✅ Cargo da Conta", current_user.get('role', 'N/A'))

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ========== SEÇÃO: EDITAR PERFIL ==========
    with st.container(border=True):
        st.markdown("##### ✏️ Editar Perfil")

        if not st.session_state.show_edit_profile_form:
            if st.button("✏️ Editar meus dados", key="btn_toggle_edit_profile", use_container_width=True):
                st.session_state.show_edit_profile_form = True
                st.rerun()
        else:
            with st.form("form_edit_profile"):
                edited_name = st.text_input("Nome", value=current_user.get('name', ''))
                edited_email = st.text_input("E-mail", value=current_user.get('email', ''))

                col_save, col_cancel = st.columns(2)
                with col_save:
                    submitted = st.form_submit_button("💾 Salvar Alterações", type="primary", use_container_width=True)
                with col_cancel:
                    cancelled = st.form_submit_button("❌ Cancelar", use_container_width=True)

                if submitted:
                    if not edited_name.strip() or not edited_email.strip():
                        st.error("❌ Nome e e-mail não podem ficar vazios.")
                    else:
                        result = update_profile(name=edited_name, email=edited_email)
                        if result:
                            st.session_state.user_data = result
                            st.session_state.show_edit_profile_form = False
                            st.success("✅ Perfil atualizado com sucesso!")
                            st.rerun()

                if cancelled:
                    st.session_state.show_edit_profile_form = False
                    st.rerun()

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ========== SEÇÃO: INFORMAÇÕES ADICIONAIS ==========
    st.subheader("ℹ️ Informações Adicionais")

    with st.container(border=True):
        info_cols = st.columns(2)

        with info_cols[0]:
            if 'created_at' in current_user:
                st.write(f"**📅 Conta criada em:** {format_timestamp(current_user.get('created_at'))}")
            if 'updated_at' in current_user:
                st.write(f"**🔄 Última atualização:** {format_timestamp(current_user.get('updated_at'))}")
            if current_user.get('phone'):
                st.write(f"**📱 Telefone:** {current_user.get('phone')}")

        with info_cols[1]:
            if 'role' in current_user:
                st.write(f"**👔 Função:** {current_user.get('role', 'N/A')}")
            if 'organization' in current_user:
                st.write(f"**🏢 Organização:** {current_user.get('organization', 'N/A')}")
            if current_user.get('bio'):
                st.write(f"**📝 Bio:** {current_user.get('bio')}")

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ========== SEÇÃO: SEGURANÇA ==========
    st.subheader("🔐 Segurança")

    with st.container(border=True):
        if st.button("🔑 Alterar Senha", key="btn_change_password", use_container_width=True):
            st.session_state.show_change_password_form = not st.session_state.show_change_password_form

        if st.session_state.show_change_password_form:
            with st.form("form_change_password"):
                new_password = st.text_input("Nova Senha", type="password")
                confirm_password = st.text_input("Confirmar Nova Senha", type="password")

                if st.form_submit_button("✅ Confirmar Nova Senha", type="primary", use_container_width=True):
                    if not new_password or not confirm_password:
                        st.error("❌ Preencha os dois campos de senha.")
                    elif new_password != confirm_password:
                        st.error("❌ As senhas não correspondem.")
                    elif update_password(new_password, confirm_password, st.session_state.auth_token):
                        st.session_state.show_change_password_form = False
                        st.success("✅ Senha alterada com sucesso!")
                        st.rerun()

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ========== SEÇÃO: REFRESH DE DADOS ==========
    if st.button("🔄 Atualizar Dados do Perfil", key="btn_refresh_profile", use_container_width=True):
        st.cache_data.clear()
        user_data = get_current_user()
        if user_data:
            st.session_state.user_data = user_data
            st.success("✅ Dados do perfil atualizados com sucesso!")
            st.rerun()
        else:
            st.error("❌ Erro ao atualizar dados do perfil")

    st.divider()
    st.caption("Edutrack-ai v2.0 - Sistema conectado ao Xano")
