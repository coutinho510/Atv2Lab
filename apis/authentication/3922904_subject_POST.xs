// Add subject record
query subject verb=POST {
  api_group = "Authentication"

  input {
    text nome? filters=trim
    text professor_? filters=trim
    int cargahoraria_?
    int user_id? {
      table = "user"
    }
  }

  stack {
    db.add subject {
      enforce_hidden_fields = false
      data = {
        name        : $input.nome
        professor   : $input.professor_
        cargahoraria: $input.cargahoraria_
        created_at  : "now"
        updated_at  : "now"
        user_id     : $input.user_id
      }
    } as $model
  }

  response = $model
}