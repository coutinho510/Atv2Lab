// meu primeiro comentario via vScode 
addon user {
  input {
    int user_id? {
      table = "user"
    }
  }

  stack {
    db.query "" {
      where = $db.user.id == $input.user_id
      return = {type: "list"}
    }
  }
}