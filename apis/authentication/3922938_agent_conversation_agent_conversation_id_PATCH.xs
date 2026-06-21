// Edit agent_conversation record
query "agent_conversation/{agent_conversation_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int agent_conversation_id? filters=min:1
    dblink {
      table = "agent_conversation"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch agent_conversation {
      field_name = "id"
      field_value = $input.agent_conversation_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $model
  }

  response = $model
}