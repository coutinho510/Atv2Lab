// Get event_log record
query "event_log/{event_log_id}" verb=GET {
  api_group = "Authentication"

  input {
    int event_log_id? filters=min:1
  }

  stack {
    db.get event_log {
      field_name = "id"
      field_value = $input.event_log_id
    } as $model
  
    precondition ($model != null) {
      error_type = "notfound"
      error = "Not Found"
    }
  }

  response = $model
}