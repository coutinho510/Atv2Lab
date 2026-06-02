api academic_activities {
  // Entradas: id da atividade a ser excluída
  // Saída: Sucesso ou falha

  // Pré-condição: Apenas usuários autenticados podem excluir
  precondition "auth"

  // Exclui o registro do banco de dados
  db.delete("academic_activities", $inputs.id)
}