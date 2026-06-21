// Stores subjects/courses that belong to an account
table subject {
  auth = false

  schema {
    // Unique identifier for the subject
    int id
  
    // Timestamp when the subject was created
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Timestamp when the subject was last updated
    timestamp updated_at?=now {
      visibility = "private"
    }
  
    int user_id? {
      table = "user"
    }
  
    // Name of the subject
    text name filters=trim
  
    text professor? filters=trim
  
    // Number of credits associated with the subject (non-negative)
    int cargahoraria? filters=min:0
  
    // Status of the subject (draft, active, or archived)
    enum status?=active {
      values = ["rascunho", "ativo", "arquivado"]
    }

    // Período/semestre da disciplina (ex.: "2026.1")
    text periodo? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["xano:quick-start"]
}