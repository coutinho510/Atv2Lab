table activity_grades {
  // Relacionamento com a atividade acadêmica
  table_reference activity_id {
    ref = "academic_activities"
    delete_cascade = true
  }

  // Relacionamento com o aluno que recebeu a nota
  table_reference student_id {
    ref = "user"
  }

  // Relacionamento com o instrutor que lançou a nota
  table_reference graded_by {
    ref = "user"
  }

  // Nota numérica (ex: 0 a 100)
  integer grade;

  // Feedback em texto para o aluno
  text feedback?;

  // Garante que um aluno só pode ter uma nota por atividade
  unique(activity_id, student_id);
}