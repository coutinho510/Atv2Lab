// Get disciplinas record
query "disciplinas/{disciplinas_id}" verb=GET {
  api_group = "Authentication"

  input {
    int disciplinas_id? filters=min:1
  }

  stack {
    db.get "" {
      field_name = "id"
      field_value = $input.disciplinas_id
    } as $disciplinas
  
    precondition ($disciplinas != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $disciplinas
}