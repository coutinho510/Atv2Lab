// Delete disciplinas record.
query "disciplinas/{disciplinas_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int disciplinas_id? filters=min:1
  }

  stack {
    db.del "" {
      field_name = "id"
      field_value = $input.disciplinas_id
    }
  }

  response = null
}