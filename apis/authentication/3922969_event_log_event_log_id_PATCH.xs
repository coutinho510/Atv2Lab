// Edit event_log record
query "event_log/{event_log_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int event_log_id? filters=min:1
    dblink {
      table = "event_log"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch event_log {
      field_name = "id"
      field_value = $input.event_log_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $model
  }

  response = $model
}