table academic_activities {
  // Relacionamento com a disciplina à qual a atividade pertence
  table_reference subject_id {
    ref = "subjects"
    delete_cascade = true
  }

  // Relacionamento com o usuário que criou a atividade
  table_reference created_by {
    ref = "user"
  }

  // Nome da atividade
  text name {
    search
  }

  // Descrição detalhada da atividade
  text description?

  // Data de entrega da atividade
  timestamp due_date?

}