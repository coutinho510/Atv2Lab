// Delete event_log record
query "event_log/{event_log_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int event_log_id? filters=min:1
  }

  stack {
    db.del event_log {
      field_name = "id"
      field_value = $input.event_log_id
    }
  }

  response = null
}