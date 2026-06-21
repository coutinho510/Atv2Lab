// Query all subject records
query subject verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query subject {
      return = {type: "list"}
      output = [
        "id"
        "name"
        "professor"
        "cargahoraria"
        "status"
        "created_at"
        "updated_at"
        "user_id"
      ]
    } as $model
  }

  response = $model
}