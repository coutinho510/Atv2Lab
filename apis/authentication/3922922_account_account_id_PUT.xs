// Update account record
query "account/{account_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int account_id? filters=min:1
    dblink {
      table = "account"
    }
  }

  stack {
    db.edit account {
      field_name = "id"
      field_value = $input.account_id
      enforce_hidden_fields = false
      data = {
        name       : $input.name
        description: $input.description
        location   : $input.location
      }
    } as $model
  }

  response = $model
}