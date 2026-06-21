"""
Módulo de Gestão de Tarefas
Responsável pela interface e lógica de gerenciamento de tarefas acadêmicas do usuário autenticado.

Funcionalidades:
- Cadastrar nova tarefa (disciplina, título, descrição, data, status)
- Listar todas as tarefas
- Editar tarefa
- Deletar tarefa
- Buscar por título
"""

from datetime import datetime, date

import streamlit as st
from utils.api_client import (
    get_subjects,
    get_tasks,
    create_task,
    update_task,
    delete_task,
    is_task_overdue,
    task_due_date_str,
    STATUS_LABELS,
    STATUS_OPTIONS,
)
from utils.theme import subject_color_by_id


def render_tarefas_page():
    """Renderiza a página completa de gestão de tarefas."""

    st.title("📝 Gestão de Tarefas")
    st.markdown("Gerencie suas tarefas acadêmicas de forma simples e eficiente.")

    # Inicializar estado da sessão
    if 'task_edit_mode_id' not in st.session_state:
        st.session_state.task_edit_mode_id = None
    if 'task_confirm_delete_id' not in st.session_state:
        st.session_state.task_confirm_delete_id = None

    subjects = get_subjects() or []

    # ==================================================
    # ABAS: Listar, Criar, Buscar
    # ==================================================
    aba1, aba2, aba3 = st.tabs(
        ["📋 Minhas Tarefas", "➕ Nova Tarefa", "🔍 Buscar"]
    )

    # ==================================================
    # ABA 1: LISTAR TAREFAS
    # ==================================================
    with aba1:
        st.subheader("📋 Todas as Minhas Tarefas")

        if st.button("🔄 Atualizar Lista", key="btn_refresh_tasks"):
            st.cache_data.clear()
            st.rerun()

        tasks = get_tasks()

        if not tasks:
            st.info("ℹ️ Você ainda não tem nenhuma tarefa cadastrada. Clique na aba 'Nova Tarefa' para criar uma.")
        else:
            st.success(f"✅ Total de tarefas: {len(tasks)}")

            for task in tasks:
                render_task_card(task, subjects)

    # ==================================================
    # ABA 2: CRIAR NOVA TAREFA
    # ==================================================
    with aba2:
        st.subheader("➕ Cadastrar Nova Tarefa")
        render_create_task_form(subjects)

    # ==================================================
    # ABA 3: BUSCAR TAREFAS
    # ==================================================
    with aba3:
        st.subheader("🔍 Buscar Tarefas por Título")

        search_term = st.text_input(
            "Digite o título da tarefa:",
            placeholder="Ex: Trabalho de Matemática",
            key="search_task_input"
        )

        if search_term:
            term = search_term.lower().strip()
            results = [t for t in get_tasks() if term in t.get('title', '').lower()]

            if not results:
                st.warning(f"❌ Nenhuma tarefa encontrada com o termo '{search_term}'")
            else:
                st.success(f"✅ Encontrados {len(results)} resultado(s)")
                for task in results:
                    render_task_card(task, subjects, key_prefix="search_")
        else:
            st.info("ℹ️ Digite o título de uma tarefa para buscar")


def render_task_card(task, subjects, key_prefix=""):
    """Renderiza um card de tarefa com ações de editar/deletar."""

    task_id = task.get('id')
    title = task.get('title', 'Sem título')
    description = task.get('description', '')
    data = task_due_date_str(task)
    status_tarefa = task.get('status_tarefa', 'pendente')
    subject_name = task.get('subject_name') or 'Disciplina não encontrada'
    color = subject_color_by_id(task.get('subject_id'), subjects)

    with st.container(border=True):
        col1, col2 = st.columns([3, 1])

        with col1:
            if is_task_overdue(task):
                st.markdown(f"### 📌 {title} :red[🔴 Atrasada]")
            else:
                st.markdown(f"### 📌 {title}")
            st.markdown(
                f"<span style='color:{color};'>●</span> **Disciplina:** {subject_name}",
                unsafe_allow_html=True,
            )
            if description:
                st.markdown(f"📝 **Descrição:** {description}")
            if data:
                st.markdown(f"📅 **Data:** {data}")
            st.markdown(f"**Status:** {STATUS_LABELS.get(status_tarefa, status_tarefa)}")

        with col2:
            st.markdown("**Ações:**")
            if st.button("✏️ Editar", key=f"{key_prefix}edit_task_{task_id}"):
                st.session_state.task_edit_mode_id = task_id
                st.rerun()

            if st.button("🗑️ Deletar", key=f"{key_prefix}delete_task_{task_id}"):
                st.session_state.task_confirm_delete_id = task_id
                st.rerun()

            if st.session_state.task_confirm_delete_id == task_id:
                col_confirm1, col_confirm2 = st.columns(2)
                with col_confirm1:
                    if st.button("✅ Confirmar", key=f"{key_prefix}confirm_delete_task_{task_id}"):
                        if delete_task(task_id):
                            st.session_state.task_confirm_delete_id = None
                            st.success(f"✅ Tarefa '{title}' deletada com sucesso!")
                            st.cache_data.clear()
                            st.rerun()
                with col_confirm2:
                    if st.button("❌ Cancelar", key=f"{key_prefix}cancel_delete_task_{task_id}"):
                        st.session_state.task_confirm_delete_id = None
                        st.rerun()

        if st.session_state.task_edit_mode_id == task_id:
            st.divider()
            render_edit_task_form(task, subjects, key_prefix=key_prefix)


def render_create_task_form(subjects):
    """Renderiza o formulário de criação de nova tarefa."""

    if not subjects:
        st.warning("⚠️ Você precisa ter ao menos uma disciplina cadastrada para criar uma tarefa.")
        return

    subject_options = {s.get('name', 'Sem nome'): s.get('id') for s in subjects}

    with st.form("form_create_task", border=True):
        st.markdown("### 📝 Preencha os Dados da Tarefa")

        task_subject_name = st.selectbox(
            "📘 Disciplina *",
            options=list(subject_options.keys())
        )

        task_title = st.text_input(
            "📌 Título da Tarefa *",
            placeholder="Ex: Trabalho de Matemática",
            max_chars=100
        )

        task_description = st.text_area(
            "📝 Descrição",
            placeholder="Detalhes sobre a tarefa (opcional)"
        )

        task_date = st.date_input(
            "📅 Data *",
            value=date.today()
        )

        task_status = st.selectbox(
            "Status",
            options=STATUS_OPTIONS,
            format_func=lambda s: STATUS_LABELS[s],
            index=0
        )

        submitted = st.form_submit_button(
            "✅ Criar Tarefa",
            use_container_width=True,
            type="primary"
        )

        if submitted:
            if not task_title.strip():
                st.error("❌ Por favor, informe o título da tarefa")
                return

            subject_id = subject_options[task_subject_name]
            result = create_task(
                subject_id,
                task_title,
                task_date.isoformat(),
                description=task_description,
                status_tarefa=task_status,
            )

            if result:
                st.success(f"✅ Tarefa '{task_title}' criada com sucesso!")
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao criar tarefa. Tente novamente.")


def render_edit_task_form(task, subjects, key_prefix=""):
    """Renderiza o formulário de edição de tarefa."""

    task_id = task.get('id')
    subject_options = {s.get('name', 'Sem nome'): s.get('id') for s in subjects}
    subject_names = list(subject_options.keys())

    current_subject_id = task.get('subject_id')
    current_index = 0
    for i, name in enumerate(subject_names):
        if subject_options[name] == current_subject_id:
            current_index = i
            break

    try:
        current_date = datetime.strptime(task_due_date_str(task), "%Y-%m-%d").date()
    except (ValueError, TypeError):
        current_date = date.today()

    current_status = task.get('status_tarefa', 'pendente')
    status_index = STATUS_OPTIONS.index(current_status) if current_status in STATUS_OPTIONS else 0

    st.markdown("### ✏️ Editar Tarefa")

    with st.form(f"form_edit_task_{key_prefix}{task_id}", border=True):
        edited_subject_name = st.selectbox(
            "📘 Disciplina",
            options=subject_names,
            index=current_index
        )

        edited_title = st.text_input(
            "📌 Título da Tarefa",
            value=task.get('title', ''),
            max_chars=100
        )

        edited_description = st.text_area(
            "📝 Descrição",
            value=task.get('description', '')
        )

        edited_date = st.date_input(
            "📅 Data",
            value=current_date
        )

        edited_status = st.selectbox(
            "Status",
            options=STATUS_OPTIONS,
            format_func=lambda s: STATUS_LABELS[s],
            index=status_index
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
                st.session_state.task_edit_mode_id = None
                st.rerun()

        if submitted:
            if not edited_title.strip():
                st.error("❌ Por favor, informe o título da tarefa")
                return

            subject_id = subject_options[edited_subject_name]
            result = update_task(
                task_id,
                subject_id,
                edited_title,
                edited_date.isoformat(),
                description=edited_description,
                status_tarefa=edited_status,
            )

            if result:
                st.success("✅ Tarefa atualizada com sucesso!")
                st.session_state.task_edit_mode_id = None
                st.cache_data.clear()
                st.rerun()
            else:
                st.error("❌ Erro ao atualizar tarefa. Tente novamente.")
