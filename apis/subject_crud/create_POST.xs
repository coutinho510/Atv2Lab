// Create a new subject
// Adds a new record to the subject table.
// Create a new subject
query create verb=POST {
  api_group = "Subject CRUD"
  auth = "user"

  input {
    // Name of the subject
    text name filters=trim

    // Professor name
    text professor? filters=trim

    // Workload in hours
    int cargahoraria? filters=min:0

    // Status of the subject
    enum status?=ativo {
      values = ["rascunho", "ativo", "arquivado"]
    }

    // Período/semestre da disciplina (ex.: "2026.1")
    text periodo? filters=trim
  }

  stack {
    db.add subject {
      data = {
        created_at  : now
        updated_at  : now
        user_id     : $auth.id
        name        : $input.name
        professor   : $input.professor
        cargahoraria: $input.cargahoraria
        status      : $input.status
        periodo     : $input.periodo
      }
    } as $new_subject
  }

  response = $new_subject
}
