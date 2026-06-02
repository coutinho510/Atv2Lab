api activity_grades {
  // O ID do registro de nota é passado como um parâmetro na URL (ex: /activity_grades/123).
  path_param int id;

  // Autenticação é obrigatória para acessar este endpoint.
  auth();

  // Define os campos que podem ser atualizados. São opcionais.
  input {
    int grade?;
    text feedback?;
  }

  // 1. Busca o registro da nota original pelo ID fornecido.
  var grade_record = db.get("activity_grades", $id);

  // 2. A partir da nota, busca a atividade acadêmica para encontrar a disciplina (subject).
  var academic_activity = db.get("academic_activities", grade_record.activity_id);

  // 3. Verifica se o usuário autenticado tem permissão para editar notas nesta disciplina.
  // A permissão é concedida apenas para usuários com papel de 'instructor' ou 'admin'.
  var enrollment = db.query("subject_enrollment")
    .where("subject_id", "==", academic_activity.subject_id)
    .where("user_id", "==", @auth.id)
    .whereIn("subject_role", ["instructor", "admin"])
    .first();

  // 4. Se não encontrar uma matrícula com a permissão adequada, lança um erro de acesso negado.
  if !is_defined(enrollment) {
    throw "accessdenied" "Você não tem permissão para editar notas nesta disciplina.";
  }

  // 5. Atualiza o registro da nota no banco de dados com os novos valores.
  // A função 'edit' inteligentemente ignora os campos de entrada que não foram fornecidos (são nulos).
  db.edit("activity_grades", $id, {
    grade: $input.grade,
    feedback: $input.feedback
  });

  // 6. Retorna o registro da nota atualizado.
  return db.get("activity_grades", $id);
}