// Cria uma nova tarefa acadêmica
// Cria uma nova tarefa acadêmica vinculada ao usuário autenticado e a uma disciplina.
query "add-task" verb=POST {
  api_group = "Academic Task Management"
  auth = "user"

  input {
    int subject_id
    text title
    text description?
    text data
    enum status_tarefa?=pendente {
      values = ["pendente", "completa", "em_progresso"]
    }
    enum prioridade?=media {
      values = ["baixa", "media", "alta"]
    }
  }

  stack {
    // Adiciona o registro na tabela academic_tasks
    db.add academic_tasks {
      data = {
        user_id      : $auth.id
        subject_id   : $input.subject_id
        title        : $input.title
        description  : $input.description
        data         : $input.data
        status_tarefa: $input.status_tarefa
        prioridade   : $input.prioridade
        created_at   : now
      }
    } as $new_task
  }

  response = $new_task
}