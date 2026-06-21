// Query all account records
query account verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query account {
      return = {type: "list"}
    } as $model
  }

  response = $model
}