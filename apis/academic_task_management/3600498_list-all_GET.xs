// Lista todas as tarefas acadêmicas com detalhes da disciplina e do usuário
// Retorna uma lista de todas as tarefas acadêmicas, incluindo informações da disciplina e do autor.
query "list-all" verb=GET {
  api_group = "Academic Task Management"
  auth = "user"

  input {
    int page?=1
    int per_page?=25
  }

  stack {
    // Consulta a tabela academic_tasks realizando joins para trazer nomes em vez de apenas IDs
    db.query academic_tasks {
      join = {
        subject         : {
          table: "subject"
          type : "left"
          where: $db.academic_tasks.subject_id == $db.subject.id
        }
        user            : {
          table: "user"
          where: $db.academic_tasks.user_id == $db.user.id
        }
        academic_tasks_2: {
          table: "academic_tasks"
          where: $db.academic_tasks.user_id == $auth.id
        }
      }

      sort = {created_at: "desc"}
      eval = {subject_name: $db.subject.name, user_name: $db.user.name}
      return = {
        type  : "list"
        paging: {
          page    : $input.page
          per_page: $input.per_page
          totals  : true
        }
      }
    } as $tasks
  }

  response = $tasks
}
