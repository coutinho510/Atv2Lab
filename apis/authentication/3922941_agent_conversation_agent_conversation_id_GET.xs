// Get agent_conversation record
query "agent_conversation/{agent_conversation_id}" verb=GET {
  api_group = "Authentication"

  input {
    int agent_conversation_id? filters=min:1
  }

  stack {
    db.get agent_conversation {
      field_name = "id"
      field_value = $input.agent_conversation_id
    } as $model
  
    precondition ($model != null) {
      error_type = "notfound"
      error = "Not Found"
    }
  }

  response = $model
}