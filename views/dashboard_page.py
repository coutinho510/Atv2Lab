import streamlit as st
from utils.api_client import (
    get_dashboard_subjects,
    get_dashboard_tasks,
    is_task_overdue,
    task_due_date_str,
    STATUS_LABELS,
)


def render_dashboard_page():
    """Renderiza a página do Dashboard."""
    st.title("🏠 Dashboard")

    subjects = get_dashboard_subjects() or []
    tasks = get_dashboard_tasks() or []

    total_active_subjects = sum(1 for s in subjects if s.get('status', 'ativo') == 'ativo')
    total_pending_tasks = sum(1 for t in tasks if t.get('status') != 'completa')

    # Progresso geral: média da taxa de conclusão de tarefas de cada disciplina.
    # Ex: 3 disciplinas com 1 tarefa cada, sendo 1 completa => (1 + 0 + 0) / 3 = 33%
    progresso_disciplinas = []
    for subject in subjects:
        subject_tasks = [t for t in tasks if t.get('subject_id') == subject.get('id')]
        if subject_tasks:
            concluidas = sum(1 for t in subject_tasks if t.get('status') == 'completa')
            progresso_disciplinas.append((subject, concluidas, len(subject_tasks)))

    if progresso_disciplinas:
        overall_progress = sum(c / total for _, c, total in progresso_disciplinas) / len(progresso_disciplinas)
    else:
        overall_progress = 0.0

    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("📚 Disciplinas Ativas", total_active_subjects)
    with col2:
        st.metric("📝 Tarefas Pendentes", total_pending_tasks)
    with col3:
        st.metric("🎯 Progresso Geral", f"{overall_progress * 100:.0f}%")

    st.divider()

    # ==================================================
    # TAREFAS POR STATUS
    # ==================================================
    st.subheader("📈 Tarefas por Status")

    if not tasks:
        st.info("ℹ️ Nenhuma tarefa cadastrada ainda.")
    else:
        status_cols = st.columns(len(STATUS_LABELS))
        for col, (status, label) in zip(status_cols, STATUS_LABELS.items()):
            count = sum(1 for t in tasks if t.get('status') == status)
            col.metric(label, count)

    st.divider()

    # ==================================================
    # PROGRESSO POR DISCIPLINA
    # ==================================================
    st.subheader("📊 Progresso por Disciplina")

    if not progresso_disciplinas:
        st.info("ℹ️ Cadastre disciplinas e tarefas para acompanhar seu progresso aqui.")
    else:
        for subject, concluidas, total in progresso_disciplinas:
            pct = concluidas / total
            icone = "✅" if pct == 1 else "🔄" if pct > 0 else "⏳"
            with st.container(border=True):
                st.markdown(f"**{icone} {subject.get('name', 'Sem nome')}**")
                st.progress(pct, text=f"{concluidas}/{total} tarefas concluídas ({pct * 100:.0f}%)")

    st.divider()

    # ==================================================
    # PRÓXIMAS TAREFAS
    # ==================================================
    st.subheader("📅 Próximas Tarefas")

    pendentes = sorted(
        (t for t in tasks if t.get('status') != 'completa' and task_due_date_str(t)),
        key=task_due_date_str
    )

    if not pendentes:
        st.info("ℹ️ Nenhuma tarefa pendente. 🎉")
    else:
        for task in pendentes[:5]:
            label = STATUS_LABELS.get(task.get('status'), task.get('status'))
            badge = " · :red[🔴 Atrasada]" if is_task_overdue(task) else ""
            st.markdown(
                f"- **{task.get('title', 'Sem título')}** "
                f"({task.get('subject_name') or 'Sem disciplina'}) — "
                f"📅 {task_due_date_str(task)} · {label}{badge}"
            )
