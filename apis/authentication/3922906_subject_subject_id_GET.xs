// Get subject record
query "subject/{subject_id}" verb=GET {
  api_group = "Authentication"

  input {
    int subject_id? filters=min:1
  }

  stack {
    db.get subject {
      field_name = "id"
      field_value = $input.subject_id
    } as $model
  
    precondition ($model != null) {
      error_type = "notfound"
      error = "Not Found"
    }
  }

  response = $model
}