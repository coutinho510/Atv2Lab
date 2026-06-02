api academic_activities {
  // Entradas: subject_id (opcional)
  // Saída: Uma lista de atividades

  // Pré-condição: Apenas usuários autenticados podem listar
  precondition "auth"

  // Busca todos os registros da tabela
  let activities = db.query("academic_activities")

  // Filtra por subject_id se o parâmetro for fornecido
  if $inputs.subject_id then
    activities.where(subject_id==$inputs.subject_id)
  endif
}