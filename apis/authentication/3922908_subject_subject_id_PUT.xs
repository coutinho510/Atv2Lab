// Update subject record
query "subject/{subject_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int subject_id? filters=min:1
    dblink {
      table = "subject"
    }
  }

  stack {
    db.edit subject {
      field_name = "id"
      field_value = $input.subject_id
      enforce_hidden_fields = false
      data = {
        name        : $input.name
        professor   : $input.description
        cargahoraria: $input.credits
        status      : $input.status
        account_id  : $input.account_id
      }
    } as $model
  }

  response = $model
}