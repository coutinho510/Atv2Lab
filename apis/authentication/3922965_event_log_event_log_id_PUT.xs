// Update event_log record
query "event_log/{event_log_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int event_log_id? filters=min:1
    dblink {
      table = "event_log"
    }
  }

  stack {
    db.edit event_log {
      field_name = "id"
      field_value = $input.event_log_id
      enforce_hidden_fields = false
      data = {
        user_id   : $input.user_id
        account_id: $input.account_id
        action    : $input.action
        metadata  : $input.metadata
      }
    } as $model
  }

  response = $model
}