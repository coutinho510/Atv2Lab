import streamlit as st
from utils.api_client import get_current_user

def render_perfil_page():
    """Renderiza a página de Perfil do Usuário."""
    st.title("👤 Meu Perfil")
    
    # Tentar atualizar dados do perfil do Xano usando GET /auth/me
    user_data = get_current_user()
    if user_data:
        st.session_state.user_data = user_data
    
    current_user = st.session_state.user_data or {}
    
    # Se não houver dados do usuário, exibir mensagem
    if not current_user:
        st.warning("⚠️ Não foi possível carregar os dados do perfil. Tente fazer login novamente.")
    else:
        # ========== SEÇÃO: INFORMAÇÕES PESSOAIS ==========
        st.subheader("📋 Informações Pessoais")
        
        with st.container(border=True):
            col1, col2 = st.columns(2)
            
            with col1:
                st.metric("👤 Nome Completo", current_user.get('name', 'N/A'))
                st.metric("📝 ID do Usuário", str(current_user.get('id', 'N/A')))
            
            with col2:
                st.metric("📧 E-mail", current_user.get('email', 'N/A'))
                st.metric("✅ Status da Conta", "Ativa")
        
        st.divider()
        
        # ========== SEÇÃO: INFORMAÇÕES ADICIONAIS ==========
        st.subheader("ℹ️ Informações Adicionais")
        
        with st.container(border=True):
            # Exibir campos adicionais se existirem
            info_cols = st.columns(2)
            
            # Coluna 1: Dados de criação/atualização
            with info_cols[0]:
                if 'created_at' in current_user:
                    st.write(f"**📅 Conta criada em:** {current_user.get('created_at', 'N/A')}")
                if 'updated_at' in current_user:
                    st.write(f"**🔄 Última atualização:** {current_user.get('updated_at', 'N/A')}")
                if 'phone' in current_user and current_user.get('phone'):
                    st.write(f"**📱 Telefone:** {current_user.get('phone')}")
            
            # Coluna 2: Outros dados
            with info_cols[1]:
                if 'role' in current_user:
                    st.write(f"**👔 Função:** {current_user.get('role', 'N/A')}")
                if 'organization' in current_user:
                    st.write(f"**🏢 Organização:** {current_user.get('organization', 'N/A')}")
                if 'bio' in current_user and current_user.get('bio'):
                    st.write(f"**📝 Bio:** {current_user.get('bio')}")
        
        st.divider()
        
        # ========== SEÇÃO: SEGURANÇA ==========
        st.subheader("🔐 Segurança")
        
        col_sec1, col_sec2 = st.columns(2)
        
        with col_sec1:
            if st.button("🔑 Alterar Senha", key="btn_change_password", use_container_width=True):
                st.info("🔄 Funcionalidade de alteração de senha será implementada em breve.")
        
        with col_sec2:
            if st.button("🔒 Fazer Login em Outro Lugar", key="btn_logout_other", use_container_width=True):
                st.info("Você será desconectado de todos os outros dispositivos.")
        
        st.divider()
        
        # ========== SEÇÃO: REFRESH DE DADOS ==========
        if st.button("🔄 Atualizar Dados do Perfil", key="btn_refresh_profile", use_container_width=True):
            # Limpar cache da função
            st.cache_data.clear()
            # Recarregar dados
            user_data = get_current_user()
            if user_data:
                st.session_state.user_data = user_data
                st.success("✅ Dados do perfil atualizados com sucesso!")
                st.rerun()
            else:
                st.error("❌ Erro ao atualizar dados do perfil")
    
    st.divider()
    
    st.caption("Edutrack-ai v2.0 - Sistema conectado ao Xano")