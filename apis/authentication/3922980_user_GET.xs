// Query all user records
query user verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query user {
      return = {type: "list"}
    } as $model
  }

  response = $model
}