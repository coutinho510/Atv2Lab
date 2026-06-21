// Get account record
query "account/{account_id}" verb=GET {
  api_group = "Authentication"

  input {
    int account_id? filters=min:1
  }

  stack {
    db.get account {
      field_name = "id"
      field_value = $input.account_id
    } as $model
  
    precondition ($model != null) {
      error_type = "notfound"
      error = "Not Found"
    }
  }

  response = $model
}