// Add account record
query account verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "account"
    }
  }

  stack {
    db.add account {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        name       : $input.name
        description: $input.description
        location   : $input.location
      }
    } as $model
  }

  response = $model
}