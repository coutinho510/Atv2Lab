api academic_activities {
  // Entradas: subject_id, name, description, due_date
  // Saída: O registro da atividade criada

  // Pré-condição: Apenas usuários autenticados podem criar
  precondition "auth"

  // Adiciona o registro no banco de dados, associando ao usuário logado
  db.add("academic_activities", created_by=$auth.id, ...)
}