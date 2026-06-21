// Retorna a lista de tarefas acadêmicas do usuário autenticado
// Lista todas as tarefas acadêmicas do usuário autenticado com detalhes da disciplina
query "Tarefas-dashboard" verb=GET {
  api_group = "Dashboard"
  auth = "user"

  input {
  }

  stack {
    // Consulta a tabela academic_tasks filtrando pelo ID do usuário autenticado
    // Realiza join com a tabela subject para obter o nome da disciplina vinculada
    db.query academic_tasks {
      join = {
        subject: {
          table: "subject"
          where: $db.academic_tasks.subject_id == $db.subject.id
        }
      }
    
      where = $db.academic_tasks.user_id == $auth.id
      sort = {created_at: "desc"}
      eval = {subject_name: $db.subject.name}
      return = {type: "list"}
    } as $tasks
  }

  response = $tasks
}