// Add event_log record
query event_log verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "event_log"
    }
  }

  stack {
    db.add event_log {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        user_id   : $input.user_id
        account_id: $input.account_id
        action    : $input.action
        metadata  : $input.metadata
      }
    } as $model
  }

  response = $model
}