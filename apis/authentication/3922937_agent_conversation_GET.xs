// Query all agent_conversation records
query agent_conversation verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query agent_conversation {
      return = {type: "list"}
    } as $model
  }

  response = $model
}