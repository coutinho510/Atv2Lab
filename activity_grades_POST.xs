api activity_grades {
  // Autenticação é necessária para acessar este endpoint.
  auth();

  // Definição dos parâmetros de entrada para o endpoint.
  input {
    // ID da atividade acadêmica que está sendo avaliada.
    int activity_id;
    // ID do aluno que receberá a nota.
    int student_id;
    // Nota numérica atribuída.
    int grade;
    // Feedback opcional em formato de texto.
    text feedback?;
  }

  // 1. Busca a atividade acadêmica para obter o ID da disciplina (subject_id).
  var academic_activity = db.get("academic_activities", $input.activity_id);

  // 2. Verifica se o usuário autenticado tem permissão para lançar notas nesta disciplina.
  // A permissão é concedida se o usuário for 'instructor' ou 'admin' na disciplina.
  var enrollment = db.query("subject_enrollment")
    .where("subject_id", "==", academic_activity.subject_id)
    .where("user_id", "==", @auth.id)
    .whereIn("subject_role", ["instructor", "admin"])
    .first();

  // Se não encontrar uma matrícula com a permissão necessária, lança um erro de acesso negado.
  if !is_defined(enrollment) {
    throw "accessdenied" "Você não tem permissão para lançar notas nesta disciplina.";
  }

  // 3. Verifica se o aluno está matriculado na disciplina.
  var student_enrollment = db.query("subject_enrollment")
    .where("subject_id", "==", academic_activity.subject_id)
    .where("user_id", "==", $input.student_id)
    .first();

  // Se o aluno não estiver matriculado, lança um erro de validação.
  if !is_defined(student_enrollment) {
    throw "inputerror" "O aluno não está matriculado nesta disciplina.";
  }

  // 4. Cria o registro da nota na tabela 'activity_grades'.
  var new_grade = db.add("activity_grades", {
    activity_id: $input.activity_id,
    student_id: $input.student_id,
    grade: $input.grade,
    feedback: $input.feedback,
    graded_by: @auth.id // Registra o ID do usuário que está lançando a nota.
  });

  return new_grade;
}