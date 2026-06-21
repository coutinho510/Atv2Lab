from datetime import date, timedelta

import pandas as pd
import streamlit as st
from utils.api_client import (
    get_subjects,
    get_tasks,
    task_due_date_str,
    is_task_overdue,
    STATUS_LABELS,
    PRIORITY_LABELS,
)
from utils.theme import subject_color, render_chips


def render_relatorios_page():
    """Renderiza a página de Relatórios e Progresso."""
    st.title("📈 Relatórios e Progresso")
    st.markdown("Histórico de tarefas por período, progresso por disciplina e exportação dos seus dados.")

    subjects = get_subjects() or []
    tasks = get_tasks() or []

    # ==================================================
    # HISTÓRICO DE TAREFAS POR PERÍODO
    # ==================================================
    st.subheader("📋 Histórico de Tarefas por Período")

    col1, col2, col3, col4 = st.columns(4)
    with col1:
        data_inicio = st.date_input("De", value=date.today() - timedelta(days=90), key="relatorio_data_inicio")
    with col2:
        data_fim = st.date_input("Até", value=date.today(), key="relatorio_data_fim")
    with col3:
        nomes_disciplinas = ["Todas"] + sorted({s.get('name', 'Sem nome') for s in subjects})
        filtro_disciplina = st.selectbox("Disciplina", options=nomes_disciplinas, key="relatorio_filtro_disciplina")
    with col4:
        opcoes_status = ["Todos"] + list(STATUS_LABELS.keys())
        filtro_status = st.selectbox(
            "Status",
            options=opcoes_status,
            format_func=lambda s: "Todos" if s == "Todos" else STATUS_LABELS[s],
            key="relatorio_filtro_status",
        )

    tarefas_no_periodo = []
    for task in tasks:
        task_date_str = task_due_date_str(task)
        if not task_date_str:
            continue
        try:
            task_date = date.fromisoformat(task_date_str)
        except ValueError:
            continue
        if not (data_inicio <= task_date <= data_fim):
            continue
        if filtro_disciplina != "Todas" and task.get('subject_name') != filtro_disciplina:
            continue
        if filtro_status != "Todos" and task.get('status_tarefa') != filtro_status:
            continue
        tarefas_no_periodo.append(task)

    if not tarefas_no_periodo:
        st.info("ℹ️ Nenhuma tarefa encontrada com os filtros selecionados.")
    else:
        total_periodo = len(tarefas_no_periodo)
        concluidas_periodo = sum(1 for t in tarefas_no_periodo if t.get('status_tarefa') == 'completa')
        atrasadas_periodo = sum(1 for t in tarefas_no_periodo if is_task_overdue(t))

        m1, m2, m3, m4 = st.columns(4)
        m1.metric("📝 Total", total_periodo)
        m2.metric("✅ Concluídas", concluidas_periodo)
        m3.metric("⏳ Pendentes", total_periodo - concluidas_periodo)
        m4.metric("🔴 Atrasadas", atrasadas_periodo)

        tabela = pd.DataFrame([
            {
                "Disciplina": t.get('subject_name') or 'Sem disciplina',
                "Título": t.get('title', 'Sem título'),
                "Status": STATUS_LABELS.get(t.get('status_tarefa'), t.get('status_tarefa')),
                "Prioridade": PRIORITY_LABELS.get(t.get('prioridade', 'media'), t.get('prioridade')),
                "Data": task_due_date_str(t),
            }
            for t in sorted(tarefas_no_periodo, key=task_due_date_str)
        ])
        st.dataframe(tabela, use_container_width=True, hide_index=True)

    st.divider()

    # ==================================================
    # TAREFAS POR PRIORIDADE
    # ==================================================
    st.subheader("🚦 Tarefas por Prioridade")

    if not tasks:
        st.info("ℹ️ Nenhuma tarefa cadastrada ainda.")
    else:
        with st.container(border=True):
            render_chips({
                label: sum(1 for t in tasks if t.get('prioridade', 'media') == priority)
                for priority, label in PRIORITY_LABELS.items()
            })

    st.divider()

    # ==================================================
    # PROGRESSO POR DISCIPLINA
    # ==================================================
    st.subheader("📊 Progresso por Disciplina")

    if not subjects:
        st.info("ℹ️ Cadastre disciplinas e tarefas para acompanhar o progresso aqui.")
    else:
        for subject in subjects:
            if subject.get('status') == 'arquivado':
                continue
            subject_tasks = [t for t in tasks if t.get('subject_id') == subject.get('id')]
            total = len(subject_tasks)
            concluidas = sum(1 for t in subject_tasks if t.get('status_tarefa') == 'completa')
            pct = (concluidas / total) if total else 0.0

            with st.container(border=True):
                st.markdown(
                    f"<span style='color:{subject_color(subject)};'>●</span> "
                    f"**{subject.get('name', 'Sem nome')}**",
                    unsafe_allow_html=True,
                )
                st.progress(pct, text=f"{concluidas}/{total} tarefas concluídas ({pct * 100:.0f}%)")

                if subject_tasks:
                    render_chips({
                        label: sum(1 for t in subject_tasks if t.get('status_tarefa') == status)
                        for status, label in STATUS_LABELS.items()
                    })

    st.divider()

    # ==================================================
    # EXPORTAÇÃO DE DADOS (CSV)
    # ==================================================
    st.subheader("📥 Exportar Dados")

    col_exp1, col_exp2 = st.columns(2)

    with col_exp1:
        disciplinas_csv = pd.DataFrame([
            {
                "Nome": s.get('name'),
                "Professor": s.get('professor'),
                "Carga Horária": s.get('cargahoraria'),
                "Período": s.get('periodo'),
                "Status": s.get('status', 'ativo'),
            }
            for s in subjects
        ]).to_csv(index=False).encode('utf-8-sig')

        st.download_button(
            "📥 Exportar Disciplinas (CSV)",
            data=disciplinas_csv,
            file_name="disciplinas.csv",
            mime="text/csv",
            use_container_width=True,
            disabled=not subjects,
        )

    with col_exp2:
        tarefas_csv = pd.DataFrame([
            {
                "Disciplina": t.get('subject_name'),
                "Título": t.get('title'),
                "Descrição": t.get('description'),
                "Status": STATUS_LABELS.get(t.get('status_tarefa'), t.get('status_tarefa')),
                "Prioridade": PRIORITY_LABELS.get(t.get('prioridade', 'media'), t.get('prioridade')),
                "Data": task_due_date_str(t),
            }
            for t in tasks
        ]).to_csv(index=False).encode('utf-8-sig')

        st.download_button(
            "📥 Exportar Tarefas (CSV)",
            data=tarefas_csv,
            file_name="tarefas.csv",
            mime="text/csv",
            use_container_width=True,
            disabled=not tasks,
        )
