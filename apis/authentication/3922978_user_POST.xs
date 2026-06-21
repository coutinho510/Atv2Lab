// Add user record
query user verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "user"
    }
  }

  stack {
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        name          : $input.name
        email         : $input.email
        password      : $input.password
        account_id    : $input.account_id
        role          : ""
        password_reset: $input.password_reset
      }
    } as $model
  }

  response = $model
}