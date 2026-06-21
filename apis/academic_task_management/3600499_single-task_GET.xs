// Obtém uma única tarefa acadêmica por ID com detalhes
// Retorna os detalhes de uma única tarefa acadêmica pelo seu ID.
query "single-task/{academic_tasks_id}" verb=GET {
  api_group = "Academic Task Management"
  auth = "user"

  input {
    int academic_tasks_id
  }

  stack {
    // Busca o registro único incluindo joins para dados legíveis
    db.query academic_tasks {
      join = {
        subject: {
          table: "subject"
          type : "left"
          where: $db.academic_tasks.subject_id == $db.subject.id
        }
        user   : {
          table: "user"
          where: $db.academic_tasks.user_id == $db.user.id
        }
      }

      where = $db.academic_tasks.id == $input.academic_tasks_id
      eval = {subject_name: $db.subject.name, user_name: $db.user.name}
      return = {type: "single"}
    } as $task

    // Verifica se a tarefa foi encontrada
    precondition ($task != null) {
      error_type = "notfound"
      error = "Tarefa não encontrada."
    }

    precondition ($task.user_id == $auth.id) {
      error_type = "accessdenied"
      error = "Está tarefa não é sua."
    }
  }

  response = $task
}
