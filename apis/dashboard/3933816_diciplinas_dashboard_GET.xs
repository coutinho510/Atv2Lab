// Retorna a lista de disciplinas do usuário autenticado
// Lista todas as disciplinas criadas pelo usuário autenticado
query "Diciplinas-dashboard" verb=GET {
  api_group = "Dashboard"
  auth = "user"

  input {
  }

  stack {
    // Consulta a tabela subject filtrando pelo ID do usuário autenticado
    db.query subject {
      where = $db.subject.user_id == $auth.id
      sort = {created_at: "desc"}
      return = {type: "list"}
    } as $subjects
  }

  response = $subjects
}