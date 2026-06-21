import streamlit as st
from utils.api_client import (
    get_dashboard_subjects,
    get_dashboard_tasks,
    is_task_overdue,
    task_due_date_str,
    STATUS_LABELS,
    PRIORITY_LABELS,
)
from utils.theme import subject_color


def render_dashboard_page():
    """Renderiza a página do Dashboard."""
    st.title("🏠 Dashboard")

    subjects = get_dashboard_subjects() or []
    tasks = get_dashboard_tasks() or []

    if not subjects:
        render_welcome_screen()
        return

    active_subjects = [s for s in subjects if s.get('status') != 'arquivado']
    total_tasks = len(tasks)
    pending_tasks = sum(1 for t in tasks if t.get('status_tarefa') != 'completa')
    overdue_tasks = sum(1 for t in tasks if is_task_overdue(t))

    # Progresso geral: média da taxa de conclusão de tarefas de cada disciplina.
    # Ex: 3 disciplinas com 1 tarefa cada, sendo 1 completa => (1 + 0 + 0) / 3 = 33%
    progresso_disciplinas = []
    for subject in active_subjects:
        subject_tasks = [t for t in tasks if t.get('subject_id') == subject.get('id')]
        if subject_tasks:
            concluidas = sum(1 for t in subject_tasks if t.get('status_tarefa') == 'completa')
            progresso_disciplinas.append((subject, concluidas, len(subject_tasks)))

    if progresso_disciplinas:
        overall_progress = sum(c / total for _, c, total in progresso_disciplinas) / len(progresso_disciplinas)
    else:
        overall_progress = 0.0

    # ==================================================
    # PROGRESSO GERAL (destaque)
    # ==================================================
    with st.container(border=True):
        st.markdown("##### 🎯 Progresso Geral")
        st.progress(overall_progress, text=f"{overall_progress * 100:.0f}% das tarefas concluídas")

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ==================================================
    # NÚMEROS RÁPIDOS
    # ==================================================
    col1, col2, col3, col4 = st.columns(4)
    with col1, st.container(border=True):
        st.metric("📚 Disciplinas", len(active_subjects))
    with col2, st.container(border=True):
        st.metric("📝 Tarefas", total_tasks)
    with col3, st.container(border=True):
        st.metric("⏳ Pendentes", pending_tasks)
    with col4, st.container(border=True):
        st.metric("🔴 Atrasadas", overdue_tasks)

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ==================================================
    # STATUS E PRIORIDADE
    # ==================================================
    col_status, col_prioridade = st.columns(2)
    with col_status, st.container(border=True):
        st.markdown("##### 📈 Tarefas por Status")
        if not tasks:
            st.caption("Nenhuma tarefa cadastrada ainda.")
        else:
            render_chips({
                label: sum(1 for t in tasks if t.get('status_tarefa') == status)
                for status, label in STATUS_LABELS.items()
            })

    with col_prioridade, st.container(border=True):
        st.markdown("##### 🚦 Tarefas por Prioridade")
        if not tasks:
            st.caption("Nenhuma tarefa cadastrada ainda.")
        else:
            render_chips({
                label: sum(1 for t in tasks if t.get('prioridade', 'media') == priority)
                for priority, label in PRIORITY_LABELS.items()
            })

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ==================================================
    # DISCIPLINAS
    # ==================================================
    with st.container(border=True):
        st.markdown("##### 📊 Disciplinas")
        if not progresso_disciplinas:
            st.caption("Cadastre disciplinas e tarefas para acompanhar seu progresso aqui.")
        else:
            for subject, concluidas, total in progresso_disciplinas:
                pct = concluidas / total
                col_nome, col_barra = st.columns([1, 2])
                with col_nome:
                    st.markdown(
                        f"<span style='color:{subject_color(subject)};'>●</span> "
                        f"**{subject.get('name', 'Sem nome')}**",
                        unsafe_allow_html=True,
                    )
                with col_barra:
                    st.progress(pct, text=f"{concluidas}/{total} ({pct * 100:.0f}%)")

    st.markdown("<div style='height:0.6em;'></div>", unsafe_allow_html=True)

    # ==================================================
    # PRÓXIMAS TAREFAS
    # ==================================================
    with st.container(border=True):
        st.markdown("##### 📅 Próximas Tarefas")

        pendentes = sorted(
            (t for t in tasks if t.get('status_tarefa') != 'completa' and task_due_date_str(t)),
            key=task_due_date_str
        )

        if not pendentes:
            st.caption("Nenhuma tarefa pendente. 🎉")
        else:
            for task in pendentes[:5]:
                label = STATUS_LABELS.get(task.get('status_tarefa'), task.get('status_tarefa'))
                priority_label = PRIORITY_LABELS.get(task.get('prioridade', 'media'), task.get('prioridade'))
                badge = " · :red[🔴 Atrasada]" if is_task_overdue(task) else ""
                st.markdown(
                    f"- **{task.get('title', 'Sem título')}** "
                    f"({task.get('subject_name') or 'Sem disciplina'}) — "
                    f"📅 {task_due_date_str(task)} · {label} · {priority_label}{badge}"
                )


def render_chips(counts):
    """Renderiza um dicionário {rótulo: quantidade} como badges arredondados lado a lado."""
    chips_html = "".join(
        "<span style='background:#F4F1FE; color:#5C3FBF; border-radius:999px; "
        "padding:0.35em 0.9em; margin:0.2em; display:inline-block; font-size:0.9em;'>"
        f"{label}: <b>{count}</b></span>"
        for label, count in counts.items()
    )
    st.markdown(chips_html, unsafe_allow_html=True)


def render_welcome_screen():
    """Tela de boas-vindas para usuários sem disciplinas cadastradas ainda."""
    st.markdown("<div style='height:1.5em;'></div>", unsafe_allow_html=True)

    col_esq, col_centro, col_dir = st.columns([1, 2, 1])
    with col_centro:
        st.markdown(
            "<h2 style='text-align:center;'>🎉 Bem-vindo(a) ao EduTrack AI!</h2>"
            "<p style='text-align:center;color:#71717a;'>"
            "Vamos organizar sua vida acadêmica em 3 passos rápidos."
            "</p>",
            unsafe_allow_html=True,
        )

        with st.container(border=True):
            st.markdown("**1️⃣ Cadastre suas disciplinas**")
            st.caption("Nome, professor e carga horária de cada matéria que você está cursando.")
            st.markdown("**2️⃣ Adicione suas tarefas**")
            st.caption("Provas, trabalhos e atividades, com prazo e status de cada uma.")
            st.markdown("**3️⃣ Acompanhe seu progresso**")
            st.caption("Veja aqui no Dashboard quantas tarefas estão pendentes, em atraso ou concluídas.")

            st.divider()

            if st.button(
                "📚 Cadastrar minha primeira disciplina",
                type="primary",
                use_container_width=True,
            ):
                st.session_state.pending_nav = "Disciplinas"
                st.rerun()
