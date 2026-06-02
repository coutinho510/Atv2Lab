// description = "Retorna uma disciplina específica do usuário autenticado."
// group = "subjects"

auth.require_login();

input subject_id int;

db.get subjects {
    id: $subject_id,
    user_id: $auth.id
};