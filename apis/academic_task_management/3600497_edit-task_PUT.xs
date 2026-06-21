// Atualiza uma tarefa acadêmica existente
// Atualiza os dados de uma tarefa acadêmica existente.
query "edit-task/{academic_tasks_id}" verb=PUT {
  api_group = "Academic Task Management"
  auth = "user"

  input {
    int academic_tasks_id
    int subject_id?
    text title?
    text description?
    text data?
    enum status_tarefa? {
      values = ["pendente", "completa", "em_progresso"]
    }
    enum prioridade? {
      values = ["baixa", "media", "alta"]
    }
  }

  stack {
    // Primeiro verifica se a tarefa existe e se o usuário tem permissão para editá-la
    db.get academic_tasks {
      field_name = "id"
      field_value = $input.academic_tasks_id
    } as $task
  
    precondition ($task != null) {
      error_type = "notfound"
      error = "Tarefa não encontrada."
    }
  
    // Verifica se o usuário é o dono da tarefa
    precondition ($task.user_id == $auth.id) {
      error_type = "accessdenied"
      error = "Você não tem permissão para editar esta tarefa."
    }
  
    // Constrói o objeto de atualização dinamicamente
    var $updates {
      value = {}
    }
  
    conditional {
      if ($input.subject_id != null) {
        var.update $updates {
          value = $updates
            |set:"subject_id":$input.subject_id
        }
      }
    }
  
    conditional {
      if ($input.title != null) {
        var.update $updates {
          value = $updates|set:"title":$input.title
        }
      }
    }
  
    conditional {
      if ($input.description != null) {
        var.update $updates {
          value = $updates
            |set:"description":$input.description
        }
      }
    }
  
    conditional {
      if ($input.data != null) {
        var.update $updates {
          value = $updates|set:"data":$input.data
        }
      }
    }
  
    conditional {
      if ($input.status_tarefa != null) {
        var.update $updates {
          value = $updates
            |set:"status_tarefa":$input.status_tarefa
        }
      }
    }

    conditional {
      if ($input.prioridade != null) {
        var.update $updates {
          value = $updates
            |set:"prioridade":$input.prioridade
        }
      }
    }

    // Aplica as atualizações se houver alguma
    db.patch academic_tasks {
      field_name = "id"
      field_value = $input.academic_tasks_id
      data = $updates
    } as $updated_task
  }

  response = $updated_task
}