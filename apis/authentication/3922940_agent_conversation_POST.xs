// Add agent_conversation record
query agent_conversation verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "agent_conversation"
    }
  }

  stack {
    db.add agent_conversation {
      enforce_hidden_fields = false
      data = {
        created_at     : "now"
        owner_user     : $input.owner_user
        title          : $input.title
        last_message_at: $input.last_message_at
      }
    } as $model
  }

  response = $model
}