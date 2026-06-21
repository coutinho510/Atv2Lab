// Query all disciplinas records
query disciplinas verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query "" {
      return = {type: "list"}
    } as $disciplinas
  }

  response = $disciplinas
}