"""
Módulo de Gestão de Disciplinas
Responsável pela interface e lógica de gerenciamento de disciplinas do usuário autenticado.

Funcionalidades:
- Cadastrar nova disciplina (nome, professor, carga horária)
- Listar todas as disciplinas
- Editar disciplina
- Deletar disciplina
- Validação de duplicatas
- Buscar por nome
"""

import streamlit as st
from utils.api_client import (
    get_subjects,
    create_subject,
    update_subject,
    delete_subject,
    set_subject_status,
    check_duplicate_subject,
    search_subjects_by_name,
)
from utils.theme import subject_color


def render_disciplinas_page():
    """Renderiza a página completa de gestão de disciplinas."""
    
    st.title("📚 Gestão de Disciplinas")
    st.markdown("Gerencie suas disciplinas de forma simples e eficiente.")
    
    # Inicializar estado da sessão
    if 'edit_mode_id' not in st.session_state:
        st.session_state.edit_mode_id = None
    if 'confirm_delete_id' not in st.session_state:
        st.session_state.confirm_delete_id = None
    if 'search_query' not in st.session_state:
        st.session_state.search_query = ""
    
    # ==================================================
    # ABAS: Listar, Criar, Buscar
    # ==================================================
    aba1, aba2, aba3 = st.tabs(
        ["📋 Minhas Disciplinas", "➕ Nova Disciplina", "🔍 Buscar"]
    )
    
    # ==================================================
    # ABA 1: LISTAR DISCIPLINAS
    # ==================================================
    with aba1:
        st.subheader("📋 Todas as Minhas Disciplinas")
        
        # Botão para atualizar lista
        if st.button("🔄 Atualizar Lista", key="btn_refresh_subjects"):
            st.cache_data.clear()
            st.rerun()
        
        # Buscar disciplinas
        todas_subjects = get_subjects()

        if not todas_subjects:
            st.info("ℹ️ Você ainda não tem nenhuma disciplina cadastrada. Clique na aba 'Nova Disciplina' para criar uma.")
        else:
            mostrar_arquivadas = st.checkbox("📦 Mostrar disciplinas arquivadas", key="mostrar_arquivadas")

            arquivadas = [s for s in todas_subjects if s.get('status') == 'arquivado']
            subjects = arquivadas if mostrar_arquivadas else [s for s in todas_subjects if s.get('status') != 'arquivado']

            if mostrar_arquivadas and not subjects:
                st.info("ℹ️ Nenhuma disciplina arquivada.")
            elif not mostrar_arquivadas and not subjects:
                st.info("ℹ️ Nenhuma disciplina ativa. Marque 'Mostrar disciplinas arquivadas' para ver as arquivadas.")
            else:
                st.success(f"✅ Total: {len(subjects)}")

            # Exibir cada disciplina em um card
            for i, subject in enumerate(subjects):
                subject_id = subject.get('id')
                subject_name = subject.get('name', 'Sem nome')
                subject_professor = subject.get('professor', 'Professor não informado')
                subject_cargahoraria = subject.get('cargahoraria', 'Carga horária não informada')
                created_at = subject.get('created_at', '')

                color = subject_color(subject)
                with st.container(border=True):
                    col1, col2 = st.columns([3, 1])

                    with col1:
                        st.markdown(
                            f"### <span style='color:{color};'>●</span> {subject_name}",
                            unsafe_allow_html=True,
                        )
                        st.markdown(f"👨‍🏫 **Professor:** {subject_professor}")
                        st.markdown(f"⏱️ **Carga Horária:** {subject_cargahoraria}h")
                        if created_at:
                            st.caption(f"📅 Criada em: {created_at}")

                    with col2:
                        # Botões de ação
                        st.markdown("**Ações:**")
                        if st.button("✏️ Editar", key=f"edit_{subject_id}"):
                            st.session_state.edit_mode_id = subject_id
                            st.rerun()

                        if subject.get('status') == 'arquivado':
                            if st.button("♻️ Reativar", key=f"reactivate_{subject_id}"):
                                if set_subject_status(subject_id, "ativo"):
                                    st.success(f"✅ Disciplina '{subject_name}' reativada!")
                                    st.rerun()
                        else:
                            if st.button("📦 Arquivar", key=f"archive_{subject_id}"):
                                if set_subject_status(subject_id, "arquivado"):
                                    st.success(f"✅ Disciplina '{subject_name}' arquivada!")
                                    st.rerun()

                        if st.button("🗑️ Deletar", key=f"delete_{subject_id}"):
                            st.session_state.confirm_delete_id = subject_id
                            st.rerun()

                        # Modal de confirmação (persiste entre reruns via session_state)
                        if st.session_state.confirm_delete_id == subject_id:
                            col_confirm1, col_confirm2 = st.columns(2)
                            with col_confirm1:
                                if st.button("✅ Confirmar Exclusão", key=f"confirm_delete_{subject_id}"):
                                    if delete_subject(subject_id):
                                        st.session_state.confirm_delete_id = None
                                        st.success(f"✅ Disciplina '{subject_name}' deletada com sucesso!")
                                        st.cache_data.clear()
                                        st.rerun()
                            with col_confirm2:
                                if st.button("❌ Cancelar", key=f"cancel_delete_{subject_id}"):
                                    st.session_state.confirm_delete_id = None
                                    st.rerun()

                    # Se estiver em modo edição para esta disciplina
                    if st.session_state.edit_mode_id == subject_id:
                        st.divider()
                        render_edit_subject_form(subject_id, subject_name, subject_professor, subject_cargahoraria)
    
    # ==================================================
    # ABA 2: CRIAR NOVA DISCIPLINA
    # ==================================================
    with aba2:
        st.subheader("➕ Cadastrar Nova Disciplina")
        
        render_create_subject_form()
    
    # ==================================================
    # ABA 3: BUSCAR DISCIPLINAS
    # ==================================================
    with aba3:
        st.subheader("🔍 Buscar Disciplinas por Nome")
        
        search_term = st.text_input(
            "Digite o nome da disciplina:",
            placeholder="Ex: Matemática, Física, etc.",
            key="search_subject_input"
        )
        
        if search_term:
            results = search_subjects_by_name(search_term)
            
            if not results:
                st.warning(f"❌ Nenhuma disciplina encontrada com o termo '{search_term}'")
            else:
                st.success(f"✅ Encontrados {len(results)} resultado(s)")
                
                for result in results:
                    subject_id = result.get('id')
                    subject_name = result.get('name', 'Sem nome')
                    subject_professor = result.get('professor', 'Professor não informado')
                    subject_cargahoraria = result.get('cargahoraria', 'Carga horária não informada')

                    with st.container(border=True):
                        st.markdown(
                            f"### <span style='color:{subject_color(result)};'>●</span> {subject_name}",
                            unsafe_allow_html=True,
                        )
                        col1, col2 = st.columns(2)
                        with col1:
                            st.markdown(f"👨‍🏫 **Professor:** {subject_professor}")
                        with col2:
                            st.markdown(f"⏱️ **Carga Horária:** {subject_cargahoraria}h")
        else:
            st.info("ℹ️ Digite o nome de uma disciplina para buscar")


def render_create_subject_form():
    """Renderiza o formulário de criação de nova disciplina."""
    
    with st.form("form_create_subject", border=True):
        st.markdown("### 📝 Preencha os Dados da Disciplina")
        
        # Campos do formulário
        subject_name = st.text_input(
            "📘 Nome da Disciplina *",
            placeholder="Ex: Matemática, Física, Literatura",
            max_chars=100
        )
        
        subject_professor = st.text_input(
            "👨‍🏫 Nome do Professor *",
            placeholder="Ex: Dr. João Silva",
            max_chars=100
        )

        subject_cargahoraria = st.number_input(
            "⏱️ Carga Horária (em horas) *",
            min_value=1,
            max_value=200,
            value=60,
            step=1,
            help="Quantas horas tem a disciplina?"
        )

        # Botão de envio
        submitted = st.form_submit_button(
            "✅ Criar Disciplina",
            use_container_width=True,
            type="primary"
        )

        if submitted:
            # Validações
            if not subject_name.strip():
                st.error("❌ Por favor, informe o nome da disciplina")
                return

            if not subject_professor.strip():
                st.error("❌ Por favor, informe o nome do professor")
                return

            if subject_cargahoraria < 1:
                st.error("❌ A carga horária deve ser maior que 0")
                return

            # Verificar duplicata
            if check_duplicate_subject(subject_name, subject_professor):
                st.error(f"❌ Já existe uma disciplina com o nome '{subject_name}' do professor '{subject_professor}'")
                return

            # Criar disciplina
            result = create_subject(subject_name, subject_professor, subject_cargahoraria)

            if result:
                st.success(f"✅ Disciplina '{subject_name}' criada com sucesso!")
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao criar disciplina. Tente novamente.")


def render_edit_subject_form(subject_id, original_name, original_professor, original_cargahoraria):
    """Renderiza o formulário de edição de disciplina."""

    st.markdown("### ✏️ Editar Disciplina")

    with st.form(f"form_edit_subject_{subject_id}", border=True):
        # Campos do formulário pré-preenchidos
        edited_name = st.text_input(
            "📘 Nome da Disciplina",
            value=original_name,
            max_chars=100
        )

        edited_professor = st.text_input(
            "👨‍🏫 Nome do Professor",
            value=original_professor,
            max_chars=100
        )

        edited_cargahoraria = st.number_input(
            "⏱️ Carga Horária (em horas)",
            min_value=1,
            max_value=200,
            value=int(original_cargahoraria) if isinstance(original_cargahoraria, (int, float)) else 60,
            step=1
        )

        col1, col2 = st.columns(2)

        with col1:
            submitted = st.form_submit_button(
                "✅ Salvar Alterações",
                use_container_width=True,
                type="primary"
            )

        with col2:
            if st.form_submit_button("❌ Cancelar", use_container_width=True):
                st.session_state.edit_mode_id = None
                st.rerun()

        if submitted:
            # Validações
            if not edited_name.strip():
                st.error("❌ Por favor, informe o nome da disciplina")
                return

            if not edited_professor.strip():
                st.error("❌ Por favor, informe o nome do professor")
                return

            if edited_cargahoraria < 1:
                st.error("❌ A carga horária deve ser maior que 0")
                return

            # Verificar duplicata (excluindo a própria disciplina)
            if check_duplicate_subject(edited_name, edited_professor, exclude_id=subject_id):
                st.error(f"❌ Já existe outra disciplina com o nome '{edited_name}' do professor '{edited_professor}'")
                return

            # Atualizar disciplina
            result = update_subject(subject_id, edited_name, edited_professor, edited_cargahoraria)

            if result:
                st.success(f"✅ Disciplina atualizada com sucesso!")
                st.session_state.edit_mode_id = None
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao atualizar disciplina. Tente novamente.")
