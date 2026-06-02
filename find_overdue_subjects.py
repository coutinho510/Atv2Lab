import argparse
import json
from datetime import datetime, timezone

def find_overdue_subject_ids(tasks_json_string):
    """
    Analisa uma string JSON de tarefas, identifica as tarefas atrasadas
    e retorna uma lista de IDs de disciplina únicos para essas tarefas.
    """
    try:
        tasks = json.loads(tasks_json_string)
    except json.JSONDecodeError:
        # Lida com JSON inválido de forma elegante, retornando uma lista vazia.
        return []

    overdue_subject_ids = set()
    now = datetime.now(timezone.utc)

    for task in tasks:
        if 'due_date' in task and task['due_date']:
            try:
                # Converte a data do formato ISO 8601 para um objeto datetime ciente do fuso horário
                due_date_str = task['due_date'].replace('Z', '+00:00')
                due_date = datetime.fromisoformat(due_date_str)

                if due_date < now:
                    overdue_subject_ids.add(task.get('subject_id'))
            except (ValueError, TypeError):
                # Ignora tarefas com formato de data inválido
                continue
    
    # Remove None caso algum subject_id seja nulo e converte o conjunto para lista
    return list(filter(None, overdue_subject_ids))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Encontra IDs de disciplinas com tarefas atrasadas a partir de um JSON.")
    parser.add_argument("--tasks-json", type=str, required=True, help="String JSON de uma lista de tarefas com 'due_date' e 'subject_id'.")
    args = parser.parse_args()
    
    ids = find_overdue_subject_ids(args.tasks_json)
    print(json.dumps({"overdue_subject_ids": ids}))