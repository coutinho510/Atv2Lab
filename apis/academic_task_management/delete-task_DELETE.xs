// Remove uma tarefa acadêmica
// Remove permanentemente uma tarefa acadêmica.
query "delete-task/{academic_tasks_id}" verb=DELETE {
  api_group = "Academic Task Management"
  auth = "user"

  input {
    int academic_tasks_id
  }

  stack {
    // Verifica se a tarefa existe e se o usuário é o dono
    db.get academic_tasks {
      field_name = "id"
      field_value = $input.academic_tasks_id
    } as $task

    precondition ($task != null) {
      error_type = "notfound"
      error = "Tarefa não encontrada."
    }

    precondition ($task.user_id == $auth.id) {
      error_type = "accessdenied"
      error = "Você não tem permissão para excluir esta tarefa."
    }

    // Deleta o registro
    db.del academic_tasks {
      field_name = "id"
      field_value = $input.academic_tasks_id
    }
  }

  response = {message: "Tarefa excluída com sucesso."}
}
