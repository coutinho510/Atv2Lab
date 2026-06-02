api activity_grades {
  // Autenticação é necessária para acessar este endpoint.
  auth();

  // Definição dos parâmetros de entrada opcionais.
  input {
    // ID da atividade acadêmica para filtrar as notas.
    int activity_id?;
  }

  // Inicia a construção da query na tabela 'activity_grades'.
  var query = db.query("activity_grades");

  // Adiciona um 'addon' para buscar e incluir os dados do aluno em cada registro de nota.
  query.addAddon("student", {
    from: "user",
    where: { id: "activity_grades.student_id" },
    return: "single"
  });

  // Verifica se o 'activity_id' foi fornecido para determinar a lógica de permissão.
  if is_defined($input.activity_id) {
    // Busca a atividade para obter o 'subject_id'.
    var academic_activity = db.get("academic_activities", $input.activity_id, {
      "not_found_error": false
    });

    // Se a atividade existir, verifica a permissão do usuário.
    if is_defined(academic_activity) {
      var enrollment = db.query("subject_enrollment")
        .where("subject_id", "==", academic_activity.subject_id)
        .where("user_id", "==", @auth.id)
        .whereIn("subject_role", ["instructor", "admin"])
        .first();

      // Se for instrutor/admin, filtra as notas pela atividade.
      if is_defined(enrollment) {
        query.where("activity_id", "==", $input.activity_id);
      } else {
        // Se não for instrutor, filtra pelas próprias notas naquela atividade.
        query.where("activity_id", "==", $input.activity_id)
             .where("student_id", "==", @auth.id);
      }
    }
  } else {
    // Se nenhum 'activity_id' for fornecido, retorna apenas as notas do usuário logado.
    query.where("student_id", "==", @auth.id);
  }

  // Executa a query com paginação e retorna a lista de notas.
  return query.getPage();
}