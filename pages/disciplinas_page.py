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
- Filtrar disciplinas com tarefas em atraso
"""

import streamlit as st
from utils.api_client import (
    get_subjects,
    create_subject,
    update_subject,
    delete_record,
    check_duplicate_subject,
    search_subjects_by_name,
    get_subjects_with_overdue_tasks,
    get_activities_for_subject
)


def render_disciplinas_page():
    """Renderiza a página completa de gestão de disciplinas."""
    
    st.title("📚 Gestão de Disciplinas")
    st.markdown("Gerencie suas disciplinas de forma simples e eficiente.")
    
    # Inicializar estado da sessão
    if 'edit_mode_id' not in st.session_state:
        st.session_state.edit_mode_id = None
    if 'search_query' not in st.session_state:
        st.session_state.search_query = ""
    
    # ==================================================
    # ABAS: Listar, Criar, Buscar
    # ==================================================
    aba1, aba2, aba3, aba4 = st.tabs(
        ["📋 Minhas Disciplinas", "➕ Nova Disciplina", "🔍 Buscar", "⚠️ Tarefas em Atraso"]
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
        subjects = get_subjects()
        
        if not subjects:
            st.info("ℹ️ Você ainda não tem nenhuma disciplina cadastrada. Clique na aba 'Nova Disciplina' para criar uma.")
        else:
            st.success(f"✅ Total de disciplinas: {len(subjects)}")
            
            # Exibir cada disciplina em um card
            for i, subject in enumerate(subjects):
                subject_id = subject.get('id')
                subject_name = subject.get('name', 'Sem nome')
                subject_teacher = subject.get('teacher', 'Professor não informado')
                subject_hours = subject.get('hours', 'Horas não informadas')
                created_at = subject.get('created_at', '')
                
                with st.container(border=True):
                    col1, col2, col3 = st.columns([2, 1, 1])
                    
                    with col1:
                        st.markdown(f"### 📘 {subject_name}")
                        st.markdown(f"👨‍🏫 **Professor:** {subject_teacher}")
                        st.markdown(f"⏱️ **Carga Horária:** {subject_hours}h")
                        if created_at:
                            st.caption(f"📅 Criada em: {created_at}")
                    
                    with col2:
                        # Mostrar número de atividades
                        activities = get_activities_for_subject(subject_id)
                        st.metric("📝 Atividades", len(activities) if activities else 0)
                    
                    with col3:
                        # Botões de ação
                        st.markdown("**Ações:**")
                        if st.button("✏️ Editar", key=f"edit_{subject_id}"):
                            st.session_state.edit_mode_id = subject_id
                            st.rerun()
                        
                        if st.button("🗑️ Deletar", key=f"delete_{subject_id}"):
                            # Modal de confirmação
                            col_confirm1, col_confirm2 = st.columns(2)
                            with col_confirm1:
                                if st.button("✅ Confirmar Exclusão", key=f"confirm_delete_{subject_id}"):
                                    if delete_record("subjects", subject_id):
                                        st.success(f"✅ Disciplina '{subject_name}' deletada com sucesso!")
                                        st.cache_data.clear()
                                        st.rerun()
                            with col_confirm2:
                                if st.button("❌ Cancelar", key=f"cancel_delete_{subject_id}"):
                                    st.info("Exclusão cancelada.")
                    
                    # Se estiver em modo edição para esta disciplina
                    if st.session_state.edit_mode_id == subject_id:
                        st.divider()
                        render_edit_subject_form(subject_id, subject_name, subject_teacher, subject_hours)
    
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
                    subject_teacher = result.get('teacher', 'Professor não informado')
                    subject_hours = result.get('hours', 'Horas não informadas')
                    
                    with st.container(border=True):
                        st.markdown(f"### 📘 {subject_name}")
                        col1, col2 = st.columns(2)
                        with col1:
                            st.markdown(f"👨‍🏫 **Professor:** {subject_teacher}")
                        with col2:
                            st.markdown(f"⏱️ **Carga Horária:** {subject_hours}h")
        else:
            st.info("ℹ️ Digite o nome de uma disciplina para buscar")
    
    # ==================================================
    # ABA 4: DISCIPLINAS COM TAREFAS EM ATRASO
    # ==================================================
    with aba4:
        st.subheader("⚠️ Disciplinas com Tarefas em Atraso")
        
        if st.button("🔄 Atualizar", key="btn_refresh_overdue"):
            st.cache_data.clear()
            st.rerun()
        
        overdue_subjects = get_subjects_with_overdue_tasks()
        
        if not overdue_subjects:
            st.success("✅ Nenhuma disciplina com tarefas em atraso!")
        else:
            st.warning(f"⚠️ Você tem {len(overdue_subjects)} disciplina(s) com tarefas em atraso!")
            
            for subject in overdue_subjects:
                subject_name = subject.get('name', 'Sem nome')
                subject_teacher = subject.get('teacher', 'Professor não informado')
                
                with st.container(border=True):
                    st.markdown(f"### 🚨 {subject_name}")
                    st.markdown(f"👨‍🏫 **Professor:** {subject_teacher}")
                    st.error("⚠️ ATENÇÃO: Esta disciplina possui atividades vencidas!")


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
        
        subject_teacher = st.text_input(
            "👨‍🏫 Nome do Professor *",
            placeholder="Ex: Dr. João Silva",
            max_chars=100
        )
        
        subject_hours = st.number_input(
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
            
            if not subject_teacher.strip():
                st.error("❌ Por favor, informe o nome do professor")
                return
            
            if subject_hours < 1:
                st.error("❌ A carga horária deve ser maior que 0")
                return
            
            # Verificar duplicata
            if check_duplicate_subject(subject_name, subject_teacher):
                st.error(f"❌ Já existe uma disciplina com o nome '{subject_name}' do professor '{subject_teacher}'")
                return
            
            # Criar disciplina
            result = create_subject(subject_name, subject_teacher, subject_hours)
            
            if result:
                st.success(f"✅ Disciplina '{subject_name}' criada com sucesso!")
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao criar disciplina. Tente novamente.")


def render_edit_subject_form(subject_id, original_name, original_teacher, original_hours):
    """Renderiza o formulário de edição de disciplina."""
    
    st.markdown("### ✏️ Editar Disciplina")
    
    with st.form(f"form_edit_subject_{subject_id}", border=True):
        # Campos do formulário pré-preenchidos
        edited_name = st.text_input(
            "📘 Nome da Disciplina",
            value=original_name,
            max_chars=100
        )
        
        edited_teacher = st.text_input(
            "👨‍🏫 Nome do Professor",
            value=original_teacher,
            max_chars=100
        )
        
        edited_hours = st.number_input(
            "⏱️ Carga Horária (em horas)",
            min_value=1,
            max_value=200,
            value=int(original_hours) if isinstance(original_hours, (int, float)) else 60,
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
            
            if not edited_teacher.strip():
                st.error("❌ Por favor, informe o nome do professor")
                return
            
            if edited_hours < 1:
                st.error("❌ A carga horária deve ser maior que 0")
                return
            
            # Verificar duplicata (excluindo a própria disciplina)
            if check_duplicate_subject(edited_name, edited_teacher, exclude_id=subject_id):
                st.error(f"❌ Já existe outra disciplina com o nome '{edited_name}' do professor '{edited_teacher}'")
                return
            
            # Atualizar disciplina
            result = update_subject(subject_id, edited_name, edited_teacher, edited_hours)
            
            if result:
                st.success(f"✅ Disciplina atualizada com sucesso!")
                st.session_state.edit_mode_id = None
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao atualizar disciplina. Tente novamente.")
