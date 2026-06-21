// Update agent_conversation record
query "agent_conversation/{agent_conversation_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int agent_conversation_id? filters=min:1
    dblink {
      table = "agent_conversation"
    }
  }

  stack {
    db.edit agent_conversation {
      field_name = "id"
      field_value = $input.agent_conversation_id
      enforce_hidden_fields = false
      data = {
        owner_user     : $input.owner_user
        title          : $input.title
        last_message_at: $input.last_message_at
      }
    } as $model
  }

  response = $model
}