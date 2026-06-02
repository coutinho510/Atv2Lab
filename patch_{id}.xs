api academic_activities {
  // Entradas: id da atividade, e campos a serem atualizados
  // Saída: O registro da atividade atualizada

  // Pré-condição: Apenas usuários autenticados podem editar
  precondition "auth"

  // Atualiza o registro no banco de dados
  db.edit("academic_activities", $inputs.id, ...)
}