// Delete agent_conversation record
query "agent_conversation/{agent_conversation_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int agent_conversation_id? filters=min:1
  }

  stack {
    db.del agent_conversation {
      field_name = "id"
      field_value = $input.agent_conversation_id
    }
  }

  response = null
}