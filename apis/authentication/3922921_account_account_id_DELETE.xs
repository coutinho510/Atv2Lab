// Delete account record
query "account/{account_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int account_id? filters=min:1
  }

  stack {
    db.del account {
      field_name = "id"
      field_value = $input.account_id
    }
  }

  response = null
}