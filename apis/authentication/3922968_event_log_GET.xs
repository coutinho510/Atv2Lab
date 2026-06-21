// Query all event_log records
query event_log verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query event_log {
      return = {type: "list"}
    } as $model
  }

  response = $model
}