addon subjects {
  input {
  }

  stack {
    db.query subject {
      return = {type: "list"}
    }
  }
}