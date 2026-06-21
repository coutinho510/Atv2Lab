// Update user record
query "user/{user_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int user_id? filters=min:1
    dblink {
      table = "user"
    }
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $input.user_id
      enforce_hidden_fields = false
      data = {
        name          : $input.name
        email         : $input.email
        password      : $input.password
        account_id    : $input.account_id
        password_reset: $input.password_reset
      }
    } as $model
  }

  response = $model
}